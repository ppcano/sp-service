
require 'ffi'

module Spotify
  module Heroku
    # @return [String] path to the libmockspotify C extension binary.
    def self.path
      File.expand_path('../libspotify.so', __FILE__)
    end

    # Overridden to always ffi_lib the right path.
    def ffi_lib(*)
      super(Heroku.path)
    end
  end

  # extend FFI::Library first, so when Spotify extends FFI::Library,
  # it will not override our Heroku#ffi_lib method
  extend FFI::Library

  # now bring in Heroku#ffi_lib method that overrides FFI::Library#ffi_lib,
  # so when Spotify tries to bind to libspotify, it binds to the one we tell
  # it to bind to
  extend Heroku

  # finally, we bring in spotify!
  require 'spotify'
end
