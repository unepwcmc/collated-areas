class Country < ApplicationRecord
  has_and_belongs_to_many :sites, class_name: "Site", join_table: 'site_countries'
  validates :name, :iso3, presence: true
  validates :name, :iso3, uniqueness: true  
end
