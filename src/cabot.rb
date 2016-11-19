require 'sinatra'

def cabot
  @cabot ||= Cabot.new ENV["LINE_CHANNEL_SECRET"], ENV["LINE_CHANNEL_TOKEN"]
end

post '/callback' do
  cabot.handle request
end
