class Artwork < ApplicationRecord
  mount_uploader :image, ArtworkUploader
end
