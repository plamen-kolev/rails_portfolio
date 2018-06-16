class CreativesController < ApplicationController
  def index
    @artworks = Artwork.all    
    # expires_in 3.days, :public => true
    # fresh_when @artworks
  end
end
