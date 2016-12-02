require 'sinatra'
require 'cabot/cabot'
# Plug-in require
%w(nba fy av stock dice youtube).each do |plugin|
  require File.dirname(__FILE__) + "/handlers/#{plugin}.rb"
end

def cabot
  @cabot ||= Cabot::Cabot.new ENV["LINE_CHANNEL_SECRET"], ENV["LINE_CHANNEL_TOKEN"]
end

post '/callback' do
  cabot.handle request
  "OK"
end
