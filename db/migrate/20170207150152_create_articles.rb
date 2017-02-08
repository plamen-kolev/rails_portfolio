class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :body, null:false
      t.string :slug, null:false
      t.string :tags, null:false
      t.string :pdf
      t.string :thumbnail

      t.timestamps
    end
  end
end
