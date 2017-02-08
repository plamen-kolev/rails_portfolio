class CreateSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :skills do |t|
      t.string :title
      t.text :body
      t.string :date
      t.string :skill_type
      t.timestamps
    end
  end
end
