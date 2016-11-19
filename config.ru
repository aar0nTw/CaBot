$LOAD_PATH.unshift File.expand_path("../src", __FILE__)
require 'cabot'
$stdout.sync = true
run Sinatra::Application

