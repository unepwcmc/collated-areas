class Country < ActiveRecord::Base
  has_and_belongs_to_many :protected_areas

  # has_one :country_statistic
  # has_one :pame_statistic

  belongs_to :region
  belongs_to :region_for_index, -> { select('regions.id, regions.name') }, :class_name => 'Region', :foreign_key => 'region_id'

  has_many :sub_locations
  has_many :designations, -> { uniq }, through: :protected_areas
  # has_many :iucn_categories, through: :protected_areas

  belongs_to :parent, class_name: "Country", foreign_key: :country_id
  has_many :children, class_name: "Country"
end
