class AddSourceRefToEvaluations < ActiveRecord::Migration[5.1]
  def change
    add_reference :evaluations, :source, foreign_key: true
  end
end
