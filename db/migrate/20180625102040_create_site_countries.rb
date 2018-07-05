class CreateSiteCountries < ActiveRecord::Migration[5.1]
  def change
    create_table :site_countries do |t|
      t.references :site, foreign_key: true
      t.references :country, foreign_key: true

      t.timestamps
    end
  end
end
