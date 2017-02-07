class CreateArtworks < ActiveRecord::Migration[5.0]
  def change
    create_table :artworks do |t|
      t.string :thumbnail

      t.timestamps
    end
  end
end
