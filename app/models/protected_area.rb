class ProtectedArea < ActiveRecord::Base
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :countries_for_index, -> { select(:id, :name, :iso_3, :region_id).includes(:region_for_index) }, :class_name => 'Country'
  has_and_belongs_to_many :sources

  has_many :pame_evaluations

  belongs_to :designation
  delegate :jurisdiction, to: :designation, allow_nil: true
end
