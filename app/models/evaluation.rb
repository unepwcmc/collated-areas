require 'csv'

class Evaluation < ApplicationRecord
  belongs_to :site
  belongs_to :source
  validates :metadata_id, :url, :year, :methodology, presence: true

  TABLE_ATTRIBUTES = [
    {
      title: 'Name',
      field: 'name'
    },
    {
      title: 'Designation',
      field: 'designation'
    },
    {
      title: 'WDPA ID',
      field: 'wdpa_id'
    },
    {
      title: 'Assessment ID',
      field: 'id'
    },
    {
      title: 'ISO3/Country',
      field: 'iso3'
    },
    {
      title: 'Methodology',
      field: 'methodology'
    },
    {
      title: 'Year of assessment',
      field: 'year'
    },
    {
      title: 'Link To Assessment',
      field: 'url'
    },
    {
      title: 'Metadata ID',
      field: 'metadata_id'
    }
  ]

  SORTING = ['']

  def self.paginate_evaluations(json=nil, order=nil)
    json_params = json.nil? ? nil : JSON.parse(json)
    page = json_params.present? ? json_params["requested_page"].to_i : 1

    order = (order && ['ASC', 'DESC'].include?(order.upcase)) ? order : 'DESC'
    evaluations = generate_query(page, json_params["filters"])
    items = serialise(evaluations)
    structure_data(page, items)
  end

  def self.structure_data(page, items)
    {
      current_page: page,
      per_page: 100,
      total_entries: items.total_entries,
      total_pages: items.total_pages,
      items: items
    }
  end

  def self.generate_query(page, filter_params)
    # if params are empty then return the paginated results without filtering
    return Evaluation.order('id ASC').paginate(page: page || 1, per_page: 100) if filter_params.empty?

    filters = filter_params.select { |hash| hash["options"].present? }

    where_params = parse_filters(filters)
    run_query(page, where_params)
  end

  def self.parse_filters(filters)
    site_ids = []
    where_params = {sites: "", methodology: "", year: ""}
    filters.each do |filter|
      options = filter["options"]
      case filter['name']
      when 'iso3'
        countries = options
        site_ids << countries.map{ |iso3| Country.find_by(iso3: iso3).sites.pluck(:id) }
        where_params[:sites] = "site_id IN (#{site_ids.join(',')})" unless options.empty?
      when 'methodology'
        options = options.map{ |e| "'#{e}'" }
        where_params[:methodology] = "#{filter["name"]} IN (#{options.join(',')})" unless options.empty?
      when 'year'
        where_params[:year] = "#{filter["name"]} IN (#{options.join(',')})" unless options.empty?
      end
    end
    where_params
  end

  def self.run_query(page, where_params)
    if where_params[:sites].present?
      Evaluation
      .joins(:site)
      .where(where_params[:sites])
      .where(where_params[:methodology])
      .where(where_params[:year])
      .paginate(page: page || 1, per_page: 100).order('id ASC')
    else
      Evaluation
      .where(where_params[:methodology])
      .where(where_params[:year])
      .paginate(page: page || 1, per_page: 100).order('id ASC')
    end
  end

  def self.serialise(evaluations)
    evaluations.to_a.map! do |evaluation|
      {
        current_page: evaluations.current_page,
        per_page: evaluations.per_page,
        total_entries: evaluations.total_entries,
        total_pages: evaluations.total_pages,
        id: evaluation.id,
        wdpa_id: evaluation.site.wdpa_id,
        iso3: evaluation.site.countries.pluck(:iso3).sort,
        methodology: evaluation.methodology,
        year: evaluation.year.to_s,
        url: evaluation.url,
        metadata_id: evaluation.metadata_id,
        source_id: evaluation.source.id,
        name: evaluation.site.name,
        designation: evaluation.site.designation,
        data_title: evaluation.source.data_title,
        resp_party: evaluation.source.resp_party,
        language: evaluation.source.language,
        source_year: evaluation.source.year
      }
    end
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
    unique_year = Evaluation.pluck(:year).uniq.map(&:to_s).sort

    [
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

  def self.run_csv_query(where_params)
    if where_params[:sites].present?
      Evaluation
      .joins(:site)
      .where(where_params[:sites])
      .where(where_params[:methodology])
      .where(where_params[:year])
    else
      Evaluation
      .where(where_params[:methodology])
      .where(where_params[:year])
    end
  end

  def self.generate_csv(evaluations)
    csv_string = CSV.generate do |csv_line|

      evaluation_columns = Evaluation.new.attributes.keys
      evaluation_columns << "evaluation_id"

      excluded_attributes = ["created_at", "updated_at", "id", "site_id", "source_id"]

      evaluation_columns.delete_if { |k, v| excluded_attributes.include? k }

      additional_columns = ["wpda_id", "iso3", "name", "designation", "source_data_title", "source_resp_party", "source_year", "source_language"]
      evaluation_columns << additional_columns.map{ |e| "#{e}" }

      csv_line << evaluation_columns.flatten

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

        evaluation_attributes = evaluation_attributes.values.map{ |e| "#{e}" }
        csv_line << evaluation_attributes
      end
    end
    csv_string
  end

  def self.to_csv(json = nil)
    json_params = json.nil? ? nil : JSON.parse(json)
    filter_params = json_params["_json"].nil? ? nil : json_params["_json"]

    if filter_params.nil?
      # this will never be reached currently, need to fix.
      evaluations = Evaluation.order(id: :asc)
    else
      where_params = parse_filters(filter_params)
      evaluations = run_csv_query(where_params)
    end
    generate_csv(evaluations)
  end
end
