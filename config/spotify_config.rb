
configure do

    set :spotify_username => ENV['SPOTIFY_USERNAME']
    set :spotify_password => ENV['SPOTIFY_PASSWORD']

    set :is_heroku => (ENV['IS_HEROKU']) ? true : false
  
    
end
