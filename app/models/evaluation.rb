class Evaluation < ApplicationRecord
  belongs_to :site
  belongs_to :source
  validates :metadata_id, :url, :year, :methodology, presence: true

  TABLE_ATTRIBUTES = [
    {
      title: 'WDPAID',
      field: 'wdpa_id'
    },
    {
      title: 'AssessmentID',
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
      title: 'LinkToAssessment',
      field: 'url'
    },
    {
      title: 'MetadataID',
      field: 'metadata_id'
    }
  ]

  SORTING = ['']

  def self.paginate_evaluations(json=nil, order=nil)
    json_params = JSON.parse(json) unless json.nil?
    page = json_params.present? ? json_params["requested_page"].to_i : 1
    page = page == 0 ? 1 : page
    order = (order && ['ASC', 'DESC'].include?(order.upcase)) ? order : 'DESC'
    evaluations = generate_query(page, json_params["filters"]) if json_params.present?
    {
      current_page: page,
      per_page: 100,
      total_entries: Evaluation.count,
      total_pages: (Evaluation.count / 10).round,
      items: serialise(evaluations)
    }
  end

  def self.generate_query(page, filter_params)
    # if params are empty then return the paginated results without filtering
    return Evaluation.order('id ASC').paginate(page: page || 1, per_page: 100) if filter_params.empty?

    site_ids = []
    where_params = {}
    where_params[:methodology] = ""
    where_params[:year] = ""
    filters = filter_params.select { |hash| hash["options"].present? }
    filters.each do |filter|
      options = filter["options"]
      case filter['name']
      when 'iso3'
        countries = options
        site_ids << countries.map{ |iso3| Country.find_by(iso3: iso3).sites.pluck(:id) }
        where_params[:sites] = "site_id IN (#{site_ids.join(',')})"
      when 'methodology'
        options = options.map{ |e| "'#{e}'" }
        where_params[:methodology] = "#{filter["name"]} IN (#{options.join(',')})"
      when 'year'
        where_params[:year] = "#{filter["name"]} IN (#{options.join(',')})"
      end
    end

    run_query(page, where_params)
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
        title: evaluation.site.name,
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
end
