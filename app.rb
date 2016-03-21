require './sapp'
require 'faye/websocket'
require 'permessage_deflate'
require 'pp'

options = {:extensions => [PermessageDeflate], :ping => 5}

wapp = lambda do |env|

  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env, ['irc', 'xmpp'], options)
    p [:open, ws.url, ws.version, ws.protocol]
    ws.on :message do |event|
      ws.send(event.data)
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
    end

    # Return async Rack response
    ws.rack_response
  else

    # Normal HTTP request
    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  
  end

end

App = Rack::Builder.new do
  # use Rack::CommonLogger
  # use Rack::ShowExceptions
  map "/" do
    # use Rack::Lint
    run SApp.new
  end
  map "/ws" do
    # use Rack::Lint
    run wapp
  end
end