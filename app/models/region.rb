class Region < ApplicationRecord
  has_many :countries
  has_many :protected_areas, through: :countries
  has_many :designations, -> { uniq }, through: :protected_areas
end