class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |t|
      t.string :data_title
      t.string :resp_party
      t.integer :year
      t.string :language

      t.timestamps
    end
  end
end
