require 'spec_helper'
require 'rails_helper'

describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect(Tmdb::Movie).to receive(:find).with('Forest Gump')
        Movie.find_in_tmdb('Forest Gump')
      end
      
      it 'should return a non-empty array with valid search option' do
        return_val = Movie.find_in_tmdb('American Sniper')
        expect(return_val).not_to be_empty
      end
      
      it 'should return an empty array with a nonsense search option' do
        return_val = Movie.find_in_tmdb('How I Failed SELT')
        expect(return_val).to be_empty
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Forest Gump') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  describe 'creating movie from TMDb' do
    it 'should call Tmdb::Movie.detail method with the right values' do
      database_query_hash = {"adult"=>false, "backdrop_path"=>"/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg", "belongs_to_collection"=>nil, "budget"=>63000000, "genres"=>[{"id"=>18, "name"=>"Drama"}], "homepage"=>"http://www.foxmovies.com/movies/fight-club", "id"=>550, "imdb_id"=>"tt0137523", "original_language"=>"en", "original_title"=>"Fight Club", "overview"=>"A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.", "popularity"=>53.915716, "poster_path"=>"/adw6Lq9FiC9zjYEpOqfq03ituwp.jpg", "production_companies"=>[{"name"=>"Twentieth Century Fox Film Corporation", "id"=>306}, {"name"=>"Regency Enterprises", "id"=>508}, {"name"=>"Fox 2000 Pictures", "id"=>711}, {"name"=>"Taurus Film", "id"=>20555}, {"name"=>"Linson Films", "id"=>54050}, {"name"=>"Atman Entertainment", "id"=>54051}, {"name"=>"Knickerbocker Films", "id"=>54052}], "production_countries"=>[{"iso_3166_1"=>"DE", "name"=>"Germany"}, {"iso_3166_1"=>"US", "name"=>"United States of America"}], "release_date"=>"1999-10-15", "revenue"=>100853753, "runtime"=>139, "spoken_languages"=>[{"iso_639_1"=>"en", "name"=>"English"}], "status"=>"Released", "tagline"=>"Mischief. Mayhem. Soap.", "title"=>"Fight Club", "video"=>false, "vote_average"=>8.3, "vote_count"=>9715}
      expect(Tmdb::Movie).to receive(:detail).with(550).and_return(database_query_hash)
      expect(Tmdb::Movie).to receive(:detail).with(941).and_return(database_query_hash) 
      expect(Tmdb::Movie).to receive(:detail).with(255).and_return(database_query_hash)
      
      Movie.create_from_tmdb(['550', '941', '255'])
    end
    
    it 'should call Movie create with a parameter hash' do
      fale_return_hash = {'title' => 'Fight Club', 'release_date' => '1999-10-15'}
      expected_hash = {:title => 'Fight Club', :rating => 'R', :release_date => '1999-10-15'}
      expect(Tmdb::Movie).to receive(:detail).with(550).and_return(fale_return_hash)
      expect(Movie).to receive(:create!).with(expected_hash)
      Movie.create_from_tmdb(['550'])
    end
    
    it 'should correctly parse search results and call create with valid hash' do
      expected_hash = {:title => 'Fight Club', :rating => 'R', :release_date => '1999-10-15'}
      database_query_hash = {"adult"=>false, "backdrop_path"=>"/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg", "belongs_to_collection"=>nil, "budget"=>63000000, "genres"=>[{"id"=>18, "name"=>"Drama"}], "homepage"=>"http://www.foxmovies.com/movies/fight-club", "id"=>550, "imdb_id"=>"tt0137523", "original_language"=>"en", "original_title"=>"Fight Club", "overview"=>"A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.", "popularity"=>53.915716, "poster_path"=>"/adw6Lq9FiC9zjYEpOqfq03ituwp.jpg", "production_companies"=>[{"name"=>"Twentieth Century Fox Film Corporation", "id"=>306}, {"name"=>"Regency Enterprises", "id"=>508}, {"name"=>"Fox 2000 Pictures", "id"=>711}, {"name"=>"Taurus Film", "id"=>20555}, {"name"=>"Linson Films", "id"=>54050}, {"name"=>"Atman Entertainment", "id"=>54051}, {"name"=>"Knickerbocker Films", "id"=>54052}], "production_countries"=>[{"iso_3166_1"=>"DE", "name"=>"Germany"}, {"iso_3166_1"=>"US", "name"=>"United States of America"}], "release_date"=>"1999-10-15", "revenue"=>100853753, "runtime"=>139, "spoken_languages"=>[{"iso_639_1"=>"en", "name"=>"English"}], "status"=>"Released", "tagline"=>"Mischief. Mayhem. Soap.", "title"=>"Fight Club", "video"=>false, "vote_average"=>8.3, "vote_count"=>9715}
      expect(Tmdb::Movie).to receive(:detail).with(550).and_return(database_query_hash)
      expect(Movie).to receive(:create!).with(expected_hash)
      Movie.create_from_tmdb(['550'])
    end
  end

end