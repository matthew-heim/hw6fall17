class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(search_string)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      search_results = Tmdb::Movie.find(search_string)
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
    
    array_of_movies = []
    
    if !search_results.nil?
      search_results.each do |m|
        current_movie = {}
        current_movie[:tmdb_id] = m.id
        current_movie[:title] = m.title
        movie_releases = Tmdb::Movie.releases(m.id)["countries"]
        
        if !(movie_releases.blank?)
          movie_releases.each do |ratings|
            if ratings.has_value?('US') and ratings["certification"] != ""
              current_movie[:rating] = ratings["certification"]
              break
            end
          end
        else
          current_movie["rating"] = 'No rating'
        end
                
        accepted_ratings = Set.new ['R', 'PG-13', 'PG', 'G', 'NC-17', 'NR']

        if not accepted_ratings.include?(current_movie[:rating])
          current_movie[:rating] = 'NR'
        end
        
        current_movie[:release_date] = m.release_date
        array_of_movies << current_movie
      end
    end
    
    return array_of_movies
  end

  def self.create_from_tmdb(list_of_IDs)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    list_of_IDs.each do |id|
      search_result = Tmdb::Movie.detail(id.to_i)
      movies = {}
      movies[:title] = search_result['title']
      
      movie_releases = Tmdb::Movie.releases(id.to_i)["countries"]
        
      if not movie_releases.blank?
        movie_releases.each do |ratings|
          if ratings.has_value?('US') and ratings["certification"] != ""
            movies[:rating] = ratings["certification"]
            break
          end
        end
      else
        movies[:rating] = 'no rating'
      end
      
      accepted_ratings = Set.new ['R', 'PG-13', 'PG', 'G', 'NC-17', 'NR']
        
      if not accepted_ratings.include?(movies[:rating])
        movies[:rating] = 'NR'
      end
      
      movies[:release_date] = search_result['release_date']
      self.create!(movies)
    end
  end

end