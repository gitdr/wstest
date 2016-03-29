require 'sinatra/base'
require 'tilt/haml'
require 'tilt/sass'
require 'bunny'

module Helpers
  def find_template(views, name, engine, &block)
    _, folder = views.detect { |k,v| engine == Tilt[k] }
    folder ||= views[:default]
    super(folder, name, engine, &block)
  end
end

class Main < Sinatra::Base
  
  helpers Helpers

  set :public_folder, 'public'
  set :views, :scss => 'views/scss', :default => 'views'


  get '/css/:file.css' do
    halt 404 unless File.exist?("views/scss/#{params[:file]}.scss")
    time = File.stat("views/scss/#{params[:file]}.scss").ctime
    last_modified(time)
    scss params[:file].intern
  end

  get '/' do
    haml :app
    # send_file File.join(settings.public_folder, 'index.html')
  end

  get '/image/:file' do
    send_file("/tmp/test/#{params[:file]}")
  end

  get '/upload_dialogue' do
    haml :upload_dialogue
  end

  post '/upload' do
    params['myfiles'].each do |file|
      tempfile = file[:tempfile]
      filename = file[:filename]
      FileUtils.copy(tempfile.path, "/tmp/test/#{filename}")
      FileUtils.rm(tempfile.path)
    end

    fnames = params['myfiles'].map {|f| f[:filename] }

    pp fnames

    begin
      conn = Bunny.new("amqp://guest:guest@192.168.1.85")
      conn.start

      ch = conn.create_channel
      x   = ch.fanout("amq.fanout")
      # q = ch.queue("", :auto_delete => true).bind(x)
      # q  = ch.queue('amqpgem.examples.hello_world', auto_delete: true)

      x.publish(fnames.join(','))
      # q.delete
      #, :routing_key => q.name, :persistent => false)
      conn.close
    rescue Bunny::PossibleAuthenticationFailureError => e
      puts "Could not authenticate as #{conn.username}"
    end

    redirect '/upload_dialogue'
  end
end
