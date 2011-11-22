# coding: utf-8
describe Hallon::Album do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:album:1xvnWMz2PNFf7mXOSRuLws" }
  end

  let(:album) { Hallon::Album.new(mock_album) }
  subject { album }

  its(:name) { should eq "Finally Woken" }
  its(:release_year) { should be 2004 }
  its(:type) { should be :single }
  its(:browse) do
    mock_session { should eq Hallon::AlbumBrowse.new(album) }
  end

  it { should be_available }
  it { should be_loaded }

  describe "artist" do
    it "should be nil if there is no artist" do
      Spotify.should_receive(:album_artist).and_return(null_pointer)
      album.artist.should be_nil
    end

    it "should be an artist if it exists" do
      album.artist.should eq Hallon::Artist.new(mock_artist)
    end
  end

  describe "cover" do
    it "should be nil if there is no image" do
      Spotify.should_receive(:album_cover).and_return(null_pointer)
      album.cover.should be_nil
    end

    it "should be an image if it exists" do
      mock_session { album.cover.id.should eq mock_image_hex }
    end

    it "should be a link if requested" do
      album.cover(false).to_str.should eq "spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450"
    end
  end

  describe ".types" do
    specify { Hallon::Album.types.should_not be_empty }
  end
end