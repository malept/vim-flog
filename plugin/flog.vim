" File:        flog.vim
" Description: Ruby cyclomatic complexity analizer
" Author:      Max Vasiliev <vim@skammer.name>
" Author:      Jelle Vandebeeck <jelle@fousa.be>
" Licence:     WTFPL
" Version:     0.0.2

if !has('signs') || !has('ruby')
  finish
endif

let s:medium_limit     = 10
let s:high_limit       = 20

if exists("g:flog_medium_limit")
  let s:medium_limit = g:flog_medium_limit
endif

if exists("g:flog_high_limit")
  let s:high_limit = g:flog_high_limit
endif

ruby << EOF
$VERBOSE = nil # turn of those pesky warnings...
begin
  require 'rubygems'
  require 'flog'
  FLOG_LOADED = true
rescue LoadError
  FLOG_LOADED = false
end

class Flog
  def flog_snippet(code, file = __FILE__)
    @parser = RubyParser.new

    begin
      ast = @parser.process(code, file)
    rescue
      return false
    end

    mass[file] = ast.mass
    process ast
    return true
  rescue RubyParser::SyntaxError, Racc::ParseError => e
    return false
  end

  def return_report
    complexity_results = {}
    max = option[:all] ? nil : total * THRESHOLD
    each_by_score max do |class_method, score, call_list|
      location = @method_locations[class_method]
      if location then
        line = location.match(/.+:(\d+)/).to_a[1]
        complexity_results[line] = [score, class_method]
      end
    end
    complexity_results
  ensure
    self.reset
  end
end

def show_complexity(results = {})
  VIM.command ":silent sign unplace *"
  medium_limit = VIM::evaluate('s:medium_limit')
  high_limit = VIM::evaluate('s:high_limit')

  results.each do |line_number, (score, method)|
    complexity = case score
      when 0..medium_limit          then "LowComplexity"
      when medium_limit..high_limit then "MediumComplexity"
      else                               "HighComplexity"
    end
    value = score >= 100 ? "9+" : score.to_i
		VIM.command ":sign define #{value} text=#{value} texthl=Sign#{complexity}"
    VIM.command ":sign place #{line_number} line=#{line_number} name=#{value} file=#{VIM::Buffer.current.name}"
  end
end

EOF

function! ShowComplexity()
ruby << EOF
  options = {
    :quiet    => true,
    :all      => true
  }

  if FLOG_LOADED
    buffer = ::VIM::Buffer.current
    # nasty hack, but there is no read all...
    code = (1..buffer.count).map{|i| buffer[i]}.join("\n")

    flogger = Flog.new options
    if flogger.flog_snippet code, buffer.name
    #flogger.flog ::VIM::Buffer.current.name
      show_complexity flogger.return_report
    end
  end
EOF
endfunction

if !exists("g:flog_enable") || g:flog_enable
  au bufnewfile,bufread,InsertLeave *.rb call ShowComplexity()
endif
