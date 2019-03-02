class AddDescToBook < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :desc, :string
  end
end
