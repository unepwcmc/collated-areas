require 'csv'

class PameEvaluation < ApplicationRecord
  belongs_to :protected_area
  belongs_to :pame_source

  validates :methodology, :year, :protected_area, :metadata_id, :url, presence: true

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
      title: 'Country',
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
    return PameEvaluation.order('id ASC').paginate(page: page || 1, per_page: 100) if filter_params.empty?

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
        site_ids << countries.map{ |iso3| Country.find_by(iso_3: iso3).protected_areas.pluck(:id) }
        where_params[:sites] = options.empty? ? nil : "protected_area_id IN (#{site_ids.join(',')})"
      when 'methodology'
        options = options.map{ |e| "'#{e}'" }
        where_params[:methodology] = options.empty? ? nil : "#{filter["name"]} IN (#{options.join(',')})"
      when 'year'
        where_params[:year] = options.empty? ? nil : "#{filter["name"]} IN (#{options.join(',')})"
      end
    end
    where_params
  end

  def self.run_query(page, where_params)
    if where_params[:sites].present?
      PameEvaluation
      .joins(:protected_area)
      .where(where_params[:sites])
      .where(where_params[:methodology])
      .where(where_params[:year])
      .paginate(page: page || 1, per_page: 100).order('id ASC')
    else
      PameEvaluation
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
        wdpa_id: evaluation.protected_area.wdpa_id,
        iso3: evaluation.protected_area.countries.pluck(:iso_3).sort,
        methodology: evaluation.methodology,
        year: evaluation.year.to_s,
        url: evaluation.url,
        metadata_id: evaluation.metadata_id,
        source_id: evaluation.pame_source.id,
        name: evaluation.protected_area.name,
        designation: evaluation.protected_area.designation.name,
        data_title: evaluation.pame_source.data_title,
        resp_party: evaluation.pame_source.resp_party,
        language: evaluation.pame_source.language,
        source_year: evaluation.pame_source.year
      }
    end
  end

  def self.sources_to_json
    sources = PameSource.all.order(id: :asc)
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
    unique_methodologies = PameEvaluation.pluck(:methodology).uniq.sort
    unique_iso3 = Country.pluck(:iso_3).uniq.sort
    unique_year = PameEvaluation.pluck(:year).uniq.map(&:to_s).sort

    [
      {
        name: 'methodology',
        title: 'Methodology',
        options: unique_methodologies,
        type: 'multiple'
      },
      {
        name: "iso3",
        title: "Country",
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

  def self.generate_csv(where_statement)
    where_statement = where_statement.empty? ? '' : "WHERE #{where_statement}"
    query = <<-SQL
      SELECT e.id AS id,
             e.metadata_id AS metadata_id,
             e.url AS url,
             e.year AS evaluation_year,
             e.methodology AS methodology,
             protected_areas.wdpa_id AS wdpa_id,
             ARRAY_TO_STRING(ARRAY_AGG(countries.iso_3),';') AS countries,
             sites.name AS site_name,
             sites.designation AS designation,
             pame_sources.data_title AS data_title,
             pame_sources.resp_party AS resp_party,
             pame_sources.year AS source_year,
             pame_sources.language AS language
             FROM evaluations e
             INNER JOIN sites ON e.site_id = sites.id
             INNER JOIN sources ON e.pame_source_id = pame_sources.id
             INNER JOIN site_countries ON sites.id = site_countries.site_id
             INNER JOIN countries ON site_countries.country_id = countries.id
             #{where_statement}
             GROUP BY e.id, sites.wdpa_id, sites.name, sites.designation, sources.data_title,
                      sources.resp_party, sources.year, sources.language;
    SQL

    # INNER JOIN sites ON e.site_id = sites.id
    # INNER JOIN sources ON e.pame_source_id = pame_sources.id
    # INNER JOIN site_countries ON sites.id = site_countries.site_id
    # INNER JOIN countries ON site_countries.country_id = countries.id

    evaluations = ActiveRecord::Base.connection.execute(query)
    csv_string = CSV.generate(encoding: 'UTF-8') do |csv_line|

      evaluation_columns = PameEvaluation.new.attributes.keys
      evaluation_columns << "evaluation_id"

      excluded_attributes = ["created_at", "updated_at", "id", "site_id", "source_id"]

      evaluation_columns.delete_if { |k, v| excluded_attributes.include? k }

      additional_columns = ["wpda_id", "iso3", "name", "designation", "source_data_title", "source_resp_party", "source_year", "source_language"]
      evaluation_columns << additional_columns.map{ |e| "#{e}" }

      csv_line << evaluation_columns.flatten

      evaluations.each do |evaluation|
        evaluation_attributes = Evaluation.new.attributes
        evaluation_attributes.delete_if { |k, v| excluded_attributes.include? k }

        evaluation_attributes["evaluation_id"] = evaluation['id']
        evaluation_attributes["metadata_id"] = evaluation["metadata_id"]
        evaluation_attributes["url"] = evaluation["url"]
        evaluation_attributes["year"] = evaluation["evaluation_year"]
        evaluation_attributes["methodology"] = evaluation["methodology"]
        evaluation_attributes["wdpa_id"] = evaluation['wdpa_id']
        evaluation_attributes["iso_3"] = evaluation['countries']
        evaluation_attributes["name"] = evaluation['site_name']
        evaluation_attributes["designation"] = evaluation['designation']
        evaluation_attributes["source_data_title"] = evaluation['data_title']
        evaluation_attributes["source_resp_party"] = evaluation['resp_party']
        evaluation_attributes["source_year"] = evaluation['source_year']
        evaluation_attributes["source_language"] = evaluation['language']

        evaluation_attributes = evaluation_attributes.values.map{ |e| "#{e}" }
        csv_line << evaluation_attributes
      end
    end
    csv_string
  end

  def self.to_csv(json = nil)
    json_params = json.nil? ? nil : JSON.parse(json)
    filter_params = json_params["_json"].nil? ? nil : json_params["_json"]

    where_statement = []
    where_params = parse_filters(filter_params)
    where_params.map do |k, v|
      where_statement << where_fields(k,v) unless v.nil?
    end

    where_statement = where_statement.join(' AND ')
    generate_csv(where_statement)
  end

  def self.where_fields(k,v)
    return "e.#{v}" if [:year, :sites].include? (k)
    return v
  end
end
