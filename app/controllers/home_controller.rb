class HomeController < ApplicationController
  def index
    @table_attributes = Evaluation::TABLE_ATTRIBUTES.to_json
    @filters = Evaluation.filters_to_json
    @sources = Evaluation.sources_to_json
    @evaluations = Evaluation.evaluations_to_json params[:page] || 1
  end

  def list
    @evaluations = Evaluation.evaluations_to_json params[:page] || 1

    render json: @evaluations
  end
end
