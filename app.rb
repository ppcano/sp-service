require 'sinatra'
require 'json'

#require './vendor/hallon-0.9.0/lib/hallon'
# done
# updated:
#    hallon.rb
#    spotify.rb

require './config/spotify_config'


if settings.is_heroku 
  require './heroku/spotify_heroku'
end


require 'hallon'

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


get '/playlist/:playlisturi' do

  playlist_uri = params[:playlisturi]

  begin

  playlist = Hallon::Playlist.new(playlist_uri)


  session.wait_for { playlist.loaded? }

  num_tracks = playlist.tracks.size
  
  js_tracks = Array.new
  playlist.tracks.each_with_index do |track, i|
        session.wait_for { track.loaded? }

        album = track.album
        session.wait_for { album.loaded? }

        js_album = {:title=> album.name, :image=> album.cover(false).to_str }    
        js_artists = Array.new

        track.artists.each_with_index do |artist, j|
          session.wait_for { artist.loaded? }
          
          js_artists.push( { :title=> artist.name} )

        end
        js_tracks.push( { :title=> track.name, :uri=> track.to_link.to_str, :album=> js_album, :artists=>js_artists} )

  end


  content_type :json
    {:uri=> playlist.to_link.to_str, :title=> playlist.name , :tracks => js_tracks}.to_json
  

  rescue => e
     puts e.message

    404

  end




end

# TODO: using heroku logs
