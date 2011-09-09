require 'webrick'

config = {
  :Port => 8080,
  :DocumentRoot => './reports'
}

server = WEBrick::HTTPServer.new(config)

['INT', 'TERM'].each do |signal|
  trap(signal){ server.shutdown} 
end

server.start
