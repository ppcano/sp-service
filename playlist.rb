require 'sinatra'
require 'hallon'
require './config/spotify_config'

puts "Successfully logged in!"

session = Hallon::Session.initialize IO.read('./config/spotify_appkey.key') do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end

  on(:connection_error) do |error|
    Hallon::Error.maybe_raise(error)
  end

  on(:logged_out) do
    abort "[FAIL] Logged out!"
  end
end

session.login!(settings.spotify_username, settings.spotify_password)

get '/hi' do
  'holasettings.pepe'
end

# TODO: using heroku logs
