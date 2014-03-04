class PulStore::Lae::GenresController < ApplicationController
  respond_to :json

  # GET /lae/genres.json
  def index
    @lae_genres = PulStore::Lae::Genre.all
  end

  # GET /lae/genres/1.json
  def show
    @lae_genre = PulStore::Lae::Genre.find(params[:id])
  end

end
