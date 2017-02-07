class Article < ApplicationRecord
  before_save :slugify
  
  private
    def slugify
      self.slug = self.title.parameterize
    end
end
