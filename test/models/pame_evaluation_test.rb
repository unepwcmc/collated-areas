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

  test "returns single restricted evaluation" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, restricted: true)
    assert_equal true, pe.restricted
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal 1, result[:total_entries]
  end

  test "returns csv of single visible evaluation" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, visible: true)
    assert_equal true, pe.visible
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    puts result
    assert_equal 1, result
  end

  test "returns csv of single restricted evaluation" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, restricted: true)
    assert_equal true, pe.restricted
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    puts result
    assert_equal 1, result
  end

  test "returns csv without single not-visible evaluation" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, visible: false)
    assert_equal false, pe.visible
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    puts result
    assert_includes "methodology,year,metadata_id,url,wdpa_id,name,evaluation_id,iso3,designation,source_data_title,source_resp_party,source_year,source_language\n",
                 result
  end

end
