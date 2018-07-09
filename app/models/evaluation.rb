require 'csv'

class Evaluation < ApplicationRecord
  belongs_to :site
  belongs_to :source
  validates :metadata_id, :url, :year, :methodology, presence: true

  def self.evaluations_to_json page
    evaluations = Evaluation.paginate(page: page, per_page: 100).order('id ASC')
    evaluations.to_a.map! do |evaluation|
      {
        current_page: evaluations.current_page,
        per_page: evaluations.per_page,
        total_entries: evaluations.total_entries,
        total_pages: evaluations.total_pages,
        items:
          {
            id: evaluation.id,
            wdpa_id: evaluation.site.wdpa_id,
            iso3: evaluation.site.countries.pluck(:iso3).sort,
            methodology: evaluation.methodology,
            year: evaluation.year,
            url: evaluation.url,
            metadata_id: evaluation.metadata_id,
            source_id: evaluation.source.id,
            name: evaluation.site.name,
            designation: evaluation.site.designation
          }
      }
    end.to_json
  end

  def self.sources_to_json
    sources = Source.all.order(id: :asc)
    sources.to_a.map! do |source|
      {
        id: source.id,
        data_title: source.data_title,
        resp_party: source.resp_party,
        year: source.year,
        language: source.language
      }
    end.to_json
  end

  def self.filters_to_json
    unique_methodologies = Evaluation.pluck(:methodology).uniq.sort
    unique_iso3 = Country.pluck(:iso3).uniq.sort
    unique_year = Evaluation.pluck(:year).uniq.sort

    filters = [
      {
        name: 'methodology',
        title: 'Methodology',
        options: unique_methodologies,
        type: 'multiple'
      },
      {
        name: "iso3",
        title: "ISO3/Country",
        options: unique_iso3,
        type: 'multiple'
      },
      {
        name: "year",
        title: "Year of assessment",
        options: unique_year,
        type: 'multiple'
      }
    ].to_json
  end

  def self.to_csv(ids = [])

    csv = ''

    evaluation_columns = Evaluation.new.attributes.keys
    evaluation_columns << "evaluation_id"

    excluded_attributes = ["created_at", "updated_at", "id", "site_id", "source_id"]

    evaluation_columns.delete_if { |k, v| excluded_attributes.include? k }

    additional_columns = ["wpda_id", "iso3", "name", "designation", "source_data_title", "source_resp_party", "source_year", "source_language"]
    evaluation_columns << additional_columns

    csv << evaluation_columns.join(',')

    evaluations = Evaluation.where(id: ids).order(id: :asc)

    evaluations.to_a.each do |evaluation|
      evaluation_attributes = evaluation.attributes
      evaluation_attributes.delete_if { |k, v| excluded_attributes.include? k }

      evaluation_attributes["evaluation_id"] = evaluation.id
      evaluation_attributes["wdpa_id"] = evaluation.site.wdpa_id
      evaluation_attributes["iso3"] = evaluation.site.countries.pluck(:iso3).uniq.join(',').to_s
      evaluation_attributes["name"] = evaluation.site.name
      evaluation_attributes["designation"] = evaluation.site.designation
      evaluation_attributes["source_data_title"] = evaluation.source.data_title
      evaluation_attributes["source_resp_party"] = evaluation.source.resp_party
      evaluation_attributes["source_year"] = evaluation.source.year
      evaluation_attributes["source_language"] = evaluation.source.language

      evaluation_attributes = evaluation_attributes.values.map{ |e| "\"#{e}\"" }
      csv << evaluation_attributes.join(',').to_s
    end

  csv.to_csv

  end
end
