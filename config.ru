require 'rubygems'
require 'bundler'

Bundler.requireg

require './playlist'

run Sinatra::Application
