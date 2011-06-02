require 'erb'
require 'sinatra'
require 'net/http'
#require 'net/https'
require 'uri'


get '/' do
  erb :index
end

get '/status' do
  erb :status
end

get '/success' do
  erb :success
end

get '/error' do
  erb :error
end

# *** REMOVE THIS
post '/status' do
  erb :success
end

#  *** change back to '/status'
post '/otherstatus' do
  host = 'na9.salesforce.com'
  service =  '/services/data/v22.0/chatter/feeds/news/me/feed-items/'
  if sfConnectSSL(host, service,  params[:token], params[:text])
    erb :success
  else
    erb :error
  end
end

get '/sf_test' do
  host = 'na9.salesforce.com'
  service =  '/services/data/v22.0/chatter/feeds/news/me/feed-items/'
  if sfConnectSSL(host, service,  params[:token], params[:text])
    erb :success
  else
    erb :error
  end
end

def sfConnect (endpoint, token, text)
  "sfConnect"
  url = URI.parse(endpoint)
  req = Net::HTTP::Post.new(url.path)
  req.add_field("Authorization", "OAuth " + token)
  req.set_form_data({'text' => text}, ';')
  res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
  case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts res.body
      return true
    else
      puts "ERROR connecting to saleforce: " + res.code
      return false
  end
end

def sfConnectSSL (host, service, token, text)
  http = Net::HTTP.new(host, 443)
  http.use_ssl = true

  data = 'text=' + text
  headers = { 'Authorization', 'OAuth ' + token }
  resp, data = http.post(service, data, headers)

  # Output on the screen 
  puts 'Code = ' + resp.code
  puts 'Message = ' + resp.message
  resp.each {|key, val| puts key + ' = ' + val}
  puts data
end



