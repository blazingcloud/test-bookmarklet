require 'sinatra'
require 'net/http'
require 'erb'

get '/' do
  erb :index
end

post '/bookmarklet' do
  puts params.inspect

  token = params[:token]
  text = request.body

  

end
