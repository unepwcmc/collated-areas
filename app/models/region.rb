class Region < ApplicationRecord
    # include GeometryConcern

    has_many :countries
    has_many :protected_areas, through: :countries
    has_many :designations, -> { uniq }, through: :protected_areas
    #has_many :iucn_categories, through: :protected_areas

  end