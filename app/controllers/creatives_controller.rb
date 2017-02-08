class CreativesController < ApplicationController
  def index
    @artworks = Artwork.all    
  end
end
