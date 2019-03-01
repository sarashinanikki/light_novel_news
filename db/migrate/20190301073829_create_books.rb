class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :illustrator
      t.string :subtitle
      t.string :img
      t.string :ISBN
      t.string :publish_date
      t.string :price
      t.string :books_url
      t.string :scrape_date
      t.integer :month
      t.timestamps
    end
  end
end
