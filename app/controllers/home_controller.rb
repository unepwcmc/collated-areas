class HomeController < ApplicationController
  EXAMPLE_PARAMS =
  {
    requested_page: 1,
    filters: [
      {
        name: "year",
        options: [2008, 2009],
        type: 'multiple'
      }
    ]
  }.to_json

  DEFAULT_PARAMS =
  {
    requested_page: 1,
    filters: []
  }.to_json

  def index
    @table_attributes = Evaluation::TABLE_ATTRIBUTES.to_json
    @filters = Evaluation.filters_to_json
    @sources = Evaluation.sources_to_json
    @evaluations = Evaluation.paginate_evaluations(DEFAULT_PARAMS).to_json

    # Andrew please delete this temp json when the real one is set up
    @json = {
      current_page: 1,
      per_page: 100,
      total_entries: Evaluation.count,
      total_pages: (Evaluation.count / 10).round,
      items: Evaluation.paginate_evaluations(DEFAULT_PARAMS)
    }.to_json
  end

  def list
    @evaluations = Evaluation.paginate_evaluations(params.to_json)
    render json: @evaluations
  end
end
