class Country < ApplicationRecord
  has_and_belongs_to_many :protected_areas

  belongs_to :region
  belongs_to :region_for_index, -> { select('regions.id, regions.name') }, :class_name => 'Region', :foreign_key => 'region_id'

  has_many :sub_locations
  has_many :designations, -> { uniq }, through: :protected_areas

  belongs_to :parent, class_name: "Country", foreign_key: :country_id, optional: true
  has_many :children, class_name: "Country"

  has_and_belongs_to_many :pame_evaluations
end
