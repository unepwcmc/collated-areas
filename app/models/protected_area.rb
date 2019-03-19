class ProtectedArea < ActiveRecord::Base
  # include GeometryConcern

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :countries_for_index, -> { select(:id, :name, :iso_3, :region_id).includes(:region_for_index) }, :class_name => 'Country'
  # has_and_belongs_to_many :sub_locations
  has_and_belongs_to_many :sources

  # has_many :networks_protected_areas, dependent: :destroy
  # has_many :networks, through: :networks_protected_areas
  has_many :pame_evaluations

  # belongs_to :legal_status
  # belongs_to :iucn_category
  # belongs_to :governance
  # belongs_to :management_authority
  # belongs_to :no_take_status
  belongs_to :designation
  delegate :jurisdiction, to: :designation, allow_nil: true
  # belongs_to :wikipedia_article

end
