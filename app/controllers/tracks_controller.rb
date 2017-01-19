class TracksController < ApplicationController
  include TracksHelper

  def index
    @genres = ["Alternative/Indie", "Blues", "Cast Recordings/Cabaret", "Christian/Gospel", "Children's",
              "Classical/Opera", "Comedy/Spoken Word", "Country", "Electronica/Dance", "Folk",
              "Jazz", "Latin", "New Age", "Pop", "Rap/Hip Hop", "Reggae/Ska", "Rock", "Seasonal", "Soul/R&B",
              "Soundtracks", "Vocals", "World"]
  end

#Search just by keyword(s)
  def search
    cookies[:feeling] = ""
    cookies[:search] = params[:word]

    @tracks = TracksHelper::Track.lyrics_keywords(params[:word])


    respond_to do |format|
      if @tracks.length > 0
        format.html {render :show, layout: false}
        format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
      else
        flash[:danger] = 'There was a problem'
        format.html { render :_no_results, layout: false }
      end
    end
  end

  #Search by keyword and sentiment
  def search_with_sentiment
    cookies[:search] = params[:word]
    cookies[:feeling] = params[:feeling]

    @form_feeling = params[:feeling]
    @tracks = TracksHelper::Track.lyrics_keywords(params[:word], 20).select{ |t| t.match_sentiment(@form_feeling)}
    respond_to do |format|
      if @tracks.length > 0
        format.html {render :show, layout: false}
        format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
      else
        flash[:danger] = 'There was a problem'
        format.html { render :_no_results, layout: false }
        format.json { }
      end
    end
  end

  # Search by the type of day you are having
  def feelings_search
    cookies[:feeling] = ""
    cookies[:search] = params[:feeling]


    # feelings_day(params[:feeling], params[:day])
    require 'googleauth'
    # Get the environment configured authorization
    scopes =  ['https://www.googleapis.com/auth/cloud-platform',
               'https://www.googleapis.com/auth/compute']
    authorization = Google::Auth.get_application_default(scopes)

    # Add the the access token obtained using the authorization to a hash, e.g
    # headers.
    some_headers = {}
    authorization.apply(some_headers)

    @day_feeling = params[:day]
    @tracks = TracksHelper::Track.lyrics_keywords(params[:feeling], 20)

    require "google/cloud/language"
    language = Google::Cloud::Language.new
    content = @day_feeling
    document = language.document content
    annotation = document.annotate


    respond_to do |format|
      if @tracks.length > 0
        @songs = []
        @tracks.each do |track|
          if track.track_spotify_id != nil
            song = RSpotify::AudioFeatures.find(track.track_spotify_id)
            if song.valence < 0.2 && annotation.sentiment.score < -(0.4)
              @songs << track
            elsif (song.valence > 0.2 && song.valence < 0.4) && (annotation.sentiment.score < 0 && annotation.sentiment.score > -(0.4))
              @songs << track
            elsif (song.valence > 0.4 && song.valence < 0.6) && (annotation.sentiment.score < 0.5 && annotation.sentiment.score > 0)
              @songs << track
            elsif (song.valence > 0.6 && song.valence <= 1) && (annotation.sentiment.score > 0.5 && annotation.sentiment.score <= 1)
              @songs << track
            end

          else
            if annotation.sentiment.score < -(0.4)
              @songs << track
            elsif annotation.sentiment.score < 0 && annotation.sentiment.score > -(0.4)
              @songs << track
            elsif annotation.sentiment.score < 0.5 && annotation.sentiment.score > 0
              @songs << track
            elsif annotation.sentiment.score <= 1 && annotation.sentiment.score > 0.5
              @songs << track
            end
          end

        end
        format.html {render :feelings, layout: false}
        format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
      else
        flash[:danger] = 'There was a problem'
        format.html { render :_no_results, layout: false }
        format.json { }
      end
    end
  end

  #Search by what you want to do on what kind of weather day
  def weather_search
    cookies[:feeling] = ""
    cookies[:search] = params[:weather]

    @tracks = TracksHelper::Track.lyrics_keywords(params[:weather], 20).select{ |t| t.match_weather(params[:want_to])}

    respond_to do |format|
      if @tracks.length > 0
        format.html {render :show, layout: false}
        format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
      else
        flash[:danger] = 'There was a problem'
        format.html { render :_no_results, layout: false }
        format.json { }
      end
    end
  end

  #Search by age and sentiment
def search_with_age
  cookies[:feeling] = ""
  cookies[:search] = params[:age]

  @form_feeling = params[:feeling]
  @tracks = TracksHelper::Track.lyrics_keywords(params[:age], 20).select{ |t| t.match_sentiment(@form_feeling)}
  respond_to do |format|
    if @tracks.length > 0
      format.html {render :show, layout: false}
      format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
    else
      flash[:danger] = 'There was a problem'
      format.html { render :_no_results, layout: false }
      format.json { }
    end
  end
end

  def search_for_party
    cookies[:feeling] = ""
    cookies[:search] = params[:word]

    @tracks = TracksHelper::Track.lyrics_keywords(params[:word], 30).select{|t| (t.audio_features.valence > 0.6)==true && (t.audio_features.danceability > 0.6)==true}
    respond_to do |format|
      if @tracks.length > 0
        format.html {render :show, layout: false}
        format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
      else
        flash[:danger] = 'There was a problem'
        format.html { render :_no_results, layout: false }
        format.json { }
      end
    end
  end

  def search_for_dance
    cookies[:feeling] = ""
    cookies[:search] = params[:word]

    @tracks = TracksHelper::Track.lyrics_keywords(params[:word], 30).select{|t| (t.audio_features.tempo > 0.6)==true && (t.audio_features.danceability > 0.6)==true}
    respond_to do |format|
      if @tracks.length > 0
        format.html {render :show, layout: false}
        format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
      else
        flash[:danger] = 'There was a problem'
        format.html { render :_no_results, layout: false }
        format.json { }
      end
    end
  end

  def search_with_genre
    cookies[:feeling] = ""
    cookies[:search] = params[:word]

    @tracks = TracksHelper::Track.lyrics_keywords(params[:word], 20, params[:genre])
      respond_to do |format|
        if @tracks.length > 0
          format.html {render :show, layout: false}
          format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
        else
          flash[:danger] = 'There was a problem'
          format.html { render :_no_results, layout: false }
          format.json { }
        end
      end
  end

  def see_more
    if cookies[:feeling] != ""
      @tracks = TracksHelper::Track.lyrics_keywords(cookies[:search], 20, "", 20).select{ |t| t.match_sentiment(cookies[:feeling])}

    else
      @tracks = TracksHelper::Track.lyrics_keywords(cookies[:search], 20, "", 20)
    end

    respond_to do |format|
      if @tracks.length > 0
        format.html {render :_more_results, layout: false}
        format.json {render json: @tracks.map{|track| track.as_json.slice("title", "artist_name", "track_spotify_id")}}
      else
        flash[:danger] = 'There was a problem'
        format.html { render :_no_results, layout: false }
        format.json { }
      end
    end

  end

end
