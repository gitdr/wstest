require 'sinatra/base'

class Main < Sinatra::Base
  set :public_folder, 'public'

  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end
end
