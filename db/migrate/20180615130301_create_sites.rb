class CreateSites < ActiveRecord::Migration[5.1]
  def change
    create_table :sites do |t|
      t.integer :wdpa_id, null: false
      t.string :name, null: false
      t.string :designation, null: false

      t.timestamps
    end
  end
end
