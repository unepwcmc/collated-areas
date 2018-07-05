class CreateEvaluations < ActiveRecord::Migration[5.1]
  def change
    create_table :evaluations do |t|
      t.references :site, foreign_key: true
      t.integer :metadata_id, null: false
      t.string :url, null: false
      t.integer :year, null: false
      t.string :methodology, null: false

      t.timestamps
    end
  end
end
