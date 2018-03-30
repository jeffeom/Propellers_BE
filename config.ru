require './web'
require './key' if File.exists?('key.rb')
run PropellerWeb
