class HomeController < ApplicationController
  DEFAULT_PARAMS =
  {
    requested_page: 1,
    filters: []
  }.to_json

  # Format for this date is: Month (3 letters) and Year (4 digits) 
  UPDATED_AT = "Feb 2019"

  def index
    @table_attributes = Evaluation::TABLE_ATTRIBUTES.to_json
    @filters = Evaluation.filters_to_json
    @sources = Evaluation.sources_to_json
    @evaluations = Evaluation.paginate_evaluations(DEFAULT_PARAMS).to_json
    @json = Evaluation.paginate_evaluations(DEFAULT_PARAMS).to_json
    @updated_at = UPDATED_AT
  end

  def list
    @evaluations = Evaluation.paginate_evaluations(params.to_json)
    render json: @evaluations
  end

  def download
    # send_file Rails.root.join('lib', 'data', 'seed', 'PAME_Data-2018-07-25.csv'), {
    #           type: "text/csv; charset=iso-8859-1; header=present",
    #           disposition: "attachment",
    #           filename: "protectedplanet-pame.csv" }
    # This needs to be uncommented once we have sorted out the CSV generation issue
    # The issue being that the CSV so large that it takes a long time to generate
    send_data Evaluation.to_csv(params.to_json), {
              type: "text/csv; charset=iso-8859-1; header=present",
              disposition: "attachment",
              filename: "protectedplanet-pame.csv" }
  end
end
