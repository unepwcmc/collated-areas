class Site < ApplicationRecord
  has_and_belongs_to_many :countries, class_name: 'Country', join_table: 'site_countries'
  has_many :evaluations
  validates :name, :wdpa_id, :designation, presence: true
  validates :wdpa_id, uniqueness: true
end
