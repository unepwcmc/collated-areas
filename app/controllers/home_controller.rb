class HomeController < ApplicationController
  def index

    @filters = Evaluation.filters_to_json
    @sources = Evaluation.sources_to_json
    @evaluations = Evaluation.evaluations_to_json params[:page] || 1

  end

  def download
    send_data Evaluation.to_csv(params[:ids]&.split(",")), {
              type: "text/csv; charset=iso-8859-1; header=present",
              disposition: "attachment",
              filename: "protectedplanet-pame-#{Date.today}.csv" }
  end
end
