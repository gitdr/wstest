require 'app/main'
require 'faye/websocket'
require 'eventmachine'
require 'permessage_deflate'
require 'amqp'
require 'pp'

options = { extensions: [PermessageDeflate], ping: 5 }

wapp = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env, %w(irc xmpp), options)

    connection = nil

    begin
      EM.schedule do
        connection = AMQP.connect(host: '192.168.1.85')
        channel  = AMQP::Channel.new(connection)

        exchange = channel.fanout("amq.fanout", :nowait => true)
        queue = AMQP::Queue.new(channel, "", :auto_delete => true)

        # queue    = channel.queue(
        #   'amqpgem.examples.hello_world',
        #   auto_delete: true
        # )
        # exchange = channel.default_exchange

        queue.bind(exchange).subscribe do |payload|
          ws.send(payload)
        end
      end
    rescue ex
      pp ex
    end

    # p [:open, ws.url, ws.version, ws.protocol]
    ws.on :message do |event|
      ws.send(event.data)
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
      connection.close
      connection = nil
    end

    # Return async Rack response
    ws.rack_response
  else

    # Normal HTTP request
    [200, { 'Content-Type' => 'text/plain' }, ['Hello']]

  end
end

App = Rack::Builder.new do
  # use Rack::CommonLogger
  # use Rack::ShowExceptions
  map '/' do
    run Main.new
  end
  map '/ws' do
    run wapp
  end
end
