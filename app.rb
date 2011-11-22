require 'sinatra'
require 'json'

require './config/config'


if settings.is_heroku 
  puts 'running on heroku........'
  require './heroku/spotify_heroku'
end


require 'hallon'


appkey = IO.read('./config/spotify_appkey.key')
session = Hallon::Session.initialize(appkey, settings_path: "tmp/settings", cache_path: "tmp/spotifycache") do
#session = Hallon::Session.initialize IO.read('./config/spotify_appkey.key') do
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

before do

  content_type :json, :charset => 'utf-8'

end



get '/playlist/:playlisturi' do


  begin

  playlist = Hallon::Playlist.new(params[:playlisturi])
  session.wait_for { playlist.loaded? }
  
  #http://yehudakatz.com/2010/05/05/ruby-1-9-encodings-a-primer-and-the-solution-for-rails/
  js_tracks = Array.new
  playlist.tracks.each_with_index do |track, i|

        session.wait_for { track.loaded? }

        album = track.album
        session.wait_for { album.loaded? }
        
        #Spotify::Pointer address=0x00000000000000> is not a valid spotify link URI or pointer
        #js_album = {:title=> album.name, :image=> album.cover(false).to_str }    
        js_album = { :title=> album.name.force_encoding("UTF-8") }    

        js_artists = Array.new
        track.artists.each_with_index do |artist, j|
          session.wait_for { artist.loaded? }
          
          js_artists.push( { :title=> artist.name.force_encoding("UTF-8")} )

        end

       js_tracks.push( { :title=> track.name.force_encoding("UTF-8"), :uri=> track.to_link.to_str, :album=> js_album, :artists=>js_artists} )

  end

    #{:uri=> playlist.to_link.to_str, :title=> playlist.name.force_encoding("UTF-8"), :tracks => js_tracks}.to_json
    #{  :title=> playlist.name }.to_json
  
    puts 'ending.............................here...'

  rescue => e
     puts e.message
     puts e.backtrace

     halt 404

  end

  {:uri=> playlist.to_link.to_str, :title=> playlist.name.force_encoding("UTF-8"), :tracks => js_tracks}.to_json

end

# TODO: using heroku logs
