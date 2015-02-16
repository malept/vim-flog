ignore_files = /_spec/

options = {
  :quiet => true,
  :all   => true
}

if !Vim::Buffer.current.name.match(ignore_files) && FLOG_LOADED
  buffer = ::VIM::Buffer.current

  # nasty hack, but there is no read all...
  code = (1..buffer.count).map { |i| buffer[i] }.join("\n")

  flogger = Flog.new(options)

  if flogger.flog_snippet(code, buffer.name)
    flogger.flog(::VIM::Buffer.current.name)
    show_complexity(flogger.return_report)
  end
end
