require 'sinatra'
require 'cabot/cabot'
require 'handlers/fy'

def cabot
  @cabot ||= Cabot::Cabot.new ENV["LINE_CHANNEL_SECRET"], ENV["LINE_CHANNEL_TOKEN"]
end

post '/callback' do
  cabot.handle request
  "OK"
end
