if FLOG_LOADED
  VIM.command ":redir @a"
  VIM.command ":silent sign place file=#{VIM::Buffer.current.name}"
  VIM.command ":redir END"
  placed_signs = VIM.evaluate "@a"
  placed_signs.lines.map(&:chomp).select{|s| s.include? 'id='}.each do |sign|
    id = Hash[*sign.split(' ').map{|s| s.split('=')}.flatten]['id']
    VIM.command ":sign unplace #{id} file=#{VIM::Buffer.current.name}"
  end
end
