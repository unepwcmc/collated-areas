class HomeController < ApplicationController
  def index
    @table_attributes = Evaluation::TABLE_ATTRIBUTES.to_json
    @filters = Evaluation.filters_to_json
    @sources = Evaluation.sources_to_json
    @evaluations = Evaluation.paginate_evaluations(params[:page]).to_json
  end

  def list
    @evaluations = Evaluation.paginate_evaluations(params[:page])

    render json: @evaluations
  end
end
