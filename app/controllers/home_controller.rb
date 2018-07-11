class HomeController < ApplicationController
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
    @json = Evaluation.paginate_evaluations(DEFAULT_PARAMS).to_json
  end

  def list
    @evaluations = Evaluation.paginate_evaluations(params.to_json)
    render json: @evaluations
  end

  def download
    send_data Evaluation.to_csv(params[:ids]&.split(",")), {
              type: "text/csv; charset=iso-8859-1; header=present",
              disposition: "attachment",
              filename: "protectedplanet-pame-#{Date.today}.csv" }
  end
end
