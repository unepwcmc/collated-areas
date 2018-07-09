class HomeController < ApplicationController
  def index
    @table_attributes = Evaluation::TABLE_ATTRIBUTES.to_json
    @filters = Evaluation.filters_to_json
    @sources = Evaluation.sources_to_json
    @evaluations = Evaluation.paginate_evaluations(params[:page]).to_json

    @json = {
      current_page: 1,
      per_page: 100,
      total_entries: Evaluation.count,
      total_pages: (Evaluation.count / 10).round,
      items: Evaluation.paginate_evaluations(1)
    }.to_json
  end

  def list
    @evaluations = Evaluation.paginate_evaluations(params[:page])

    render json: @evaluations
  end
end
