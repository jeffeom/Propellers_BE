require './web'
require './key' if File.exists?('key.rb')
# run Sinatra::Application
run PropellerWeb
