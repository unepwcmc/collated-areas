require 'test_helper'

class PameEvaluationTest < ActiveSupport::TestCase
  DEFAULT_PARAMS =
  {
    requested_page: 1,
    filters: []
  }.to_json

  test "returns nothing for empty evaluation list" do
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal 0, result[:total_entries]
  end

  
  test "returns single visible evaluation" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, visible: true)
    assert_equal true, pe.visible
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal 1, result[:total_entries]
  end

  test "returns two visible evaluations" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, visible: true)
    pe2 = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, visible: true)
    assert_equal true, pe.visible
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal 2, result[:total_entries]
  end

  
  test "hides single not-visible evaluation" do
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, restricted: false,  pame_source: ps)
    assert_equal false, pe.visible
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal 0, result[:total_entries]
  end

end
