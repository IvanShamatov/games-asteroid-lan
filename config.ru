require 'bundler'
Bundler.require
require_relative 'setup_dll'

require_relative 'server'
Server.new.run!
