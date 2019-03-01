class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :illustrator
      t.string :subtitle
      t.string :img
      t.string :isbn
      t.string :date
      t.string :price
      t.string :url
      t.int :month
      t.timestamps
    end
  end
end
