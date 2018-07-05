class HomeController < ApplicationController
  def index

    @filters = Evaluation.filters_to_json
    @sources = Evaluation.sources_to_json
    @evaluations = Evaluation.evaluations_to_json params[:page] || 1

  end
end
