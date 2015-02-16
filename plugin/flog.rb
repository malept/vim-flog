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
      return false unless ast = @parser.process(code, file)
    rescue
      return false
    end

    mass[file] = ast.mass
    process(ast)
    return true
  rescue RubyParser::SyntaxError, Racc::ParseError
    return false
  end

  def return_report
    complexity_results = {}
    each_by_score threshold do |class_method, score, call_list|
      location = @method_locations[class_method]
      next unless location

      line = location.match(/.+:(\d+)/).to_a[1]
      complexity_results[line] = [score, class_method]
    end
    complexity_results
  ensure
    self.reset
  end
end

def show_complexity(results = {})
  medium_limit = VIM::evaluate('s:medium_limit')
  high_limit   = VIM::evaluate('s:high_limit')
  hide_medium  = VIM::evaluate('s:hide_medium')
  hide_low     = VIM::evaluate('s:hide_low')

  VIM.command(":silent sign unplace * file=#{VIM::Buffer.current.name}")
  VIM.command(":sign define FlogDummySign")
  VIM.command(":sign place 9999 line=1 name=FlogDummySign file=#{VIM::Buffer.current.name}")

  results.each do |line_number, (score, _)|
    complexity = case score
      when 0..medium_limit          then "LowComplexity"
      when medium_limit..high_limit then "MediumComplexity"
      else                               "HighComplexity"
    end
    value = score >= 100 ? "9+" : score.to_i
    value = nil if (hide_low == 1 && value < medium_limit) || (hide_medium == 1 && value < high_limit)
    return unless value

    VIM.command(":sign define #{value} text=#{value} texthl=Sign#{complexity}")
    VIM.command(":sign place #{line_number} line=#{line_number} name=#{value} file=#{VIM::Buffer.current.name}")
  end
end
