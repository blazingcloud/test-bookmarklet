# Copyright 2011 Blazing Cloud, blazingcloud.net
# @author John Olmstead
# @module Bookmarklet
require 'erb'
require 'sinatra'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

enable :sessions

# Salesforce authentication values
#CONSUMER_KEY = '3MVG9y6x0357Hlee4DL3FGEieIKvD32laT1z5huSmZdEOcM78RomTQS7DjtljGYfrbMVAd.PEOAdoFcYLhFF.'
#CONSUMER_SECRET = '5052838037439823175'
CONSUMER_KEY = '3MVG9y6x0357Hlee4DL3FGEieIP9ypM_SfuWYvMJ.GDk6jyXkxLPC5_fYPXE7x16j4yRNhe1vkuksYxMsGj52'
CONSUMER_SECRET = '4674391701375887569'

# action: get index
#   displays link and instruction
get '/' do
  erb :index
end

# action: get status
#   displays status message form
get '/status' do
  erb :status
end

# action: get success
#   displays success message
get '/success' do
  erb :success
end

# action: get error
#   displays success message
get '/error' do
  erb :error
end

# action: get auth
#   redirects to status if authorized
#   otherwise authenticates using code and credentials prior to redirection
#   redirects to error on fail
#   passed to Saleforce OAuth as redirect_uri
get '/auth' do
  
  if session['access_token'] == nil
    
    # create an SSL connection to the
    http = Net::HTTP.new('login.salesforce.com', 443)
    http.use_ssl = true

    # grab Saleforce code included on redirect query string
    data = 'code=' + params[:code]
    # add required paramaters
    data += '&grant_type=authorization_code'
    data += '&client_id=' + CONSUMER_KEY
    data += '&client_secret=' + CONSUMER_SECRET
    data += '&redirect_uri=' + request.url.split('?').first

    # make the request and handle response
    response, data = http.post('/services/oauth2/token', data, {})
    case response
      when Net::HTTPSuccess
        result = JSON.parse(response.body)
        if !result.has_key? 'access_token' or !result.has_key? 'instance_url'
          redirect '/error'
        end

        # OAuth should return an access token and instance url
        session['access_token'] = result['access_token']
        session['instance_url'] = result['instance_url']
        if (session['access_token'] == nil or session['instance_url'] == nil)
          redirect '/error'
        end

        puts session['access_token']
        puts session['instance_url'] 
        redirect '/status'
      else
        puts "ERROR: "+response.code+" returned from token services"
        puts response.body
        
        redirect '/error'
    end
  end
  puts session['access_token']
  redirect '/status'
end

# action: post status
#   accepts the posted status and posts to the Chatter API
#   redirects to success or fail based on response
post '/status' do
  service =  '/services/data/v22.0/chatter/feeds/news/me/feed-items/'
  if postStatus(service, params[:text])
    erb :success
  else
    erb :error
  end
end

# action: get test
#   tests post to status via get for testing
get '/test' do
  service =  '/services/data/v22.0/chatter/feeds/news/me/feed-items/'
  if postStatus(service, params[:text])
    erb :success
  else
    erb :error
  end
end

# method: postStatus()
#   posts the status message to the Saleforce REST API
#   requires instance_url and access_token to be already set in session
#
#   @param service the path to the REST service
#   @param text the message being posted
#   @returns true/false
def postStatus(service ,text)
 if session['instance_url'] == nil or session['access_token'] == nil
    retrun false
  end

  # the instance url was provided with the access token
  uri = URI.parse(session['instance_url'])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  data = 'text=' + text
  headers = { 'Authorization', 'OAuth ' + session['access_token'] }
  response, data = http.post(service, data, headers)

  case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts response.body
      return true
    else
      puts "ERROR connecting to saleforce: " + response.code
      return false
  end
end



