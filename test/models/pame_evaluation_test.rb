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
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps)
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal 1, result[:total_entries]
  end

  test "returns two visible evaluations" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps)
    pe2 = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps)
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal 2, result[:total_entries]
  end

  
  test "hides single nil pa evaluation" do
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, pame_source: ps, protected_area: nil)
    assert_nil pe.protected_area
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
    region = FactoryGirl.create(:region)
    country = FactoryGirl.create(:country, name: "France", iso_3: "FRA", region: region)
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area", countries: [country])
    ps = FactoryGirl.create(:pame_source, data_title: "N/A", resp_party: "Unknown", year: 2016, language: "English")
    pe = FactoryGirl.create(:pame_evaluation, id: 1, protected_area: pa, pame_source: ps, wdpa_id: 1, assessment_is_public: true)
    assert_equal pa, pe.protected_area
    assert_equal 1, pe.wdpa_id
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    actual_csv = File.open('lib/data/seed/test_pame_returns_csv_of_single_visible_evaluation.csv').read
    assert_equal(result, actual_csv)
  end

  test "returns csv of single restricted evaluation" do
    region = FactoryGirl.create(:region)
    country = FactoryGirl.create(:country, name: "France", iso_3: "FRA", region: region)
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area", countries: [country])
    ps = FactoryGirl.create(:pame_source, data_title: "N/A", resp_party: "Unknown", year: 2016, language: "English")
    pe = FactoryGirl.create(:pame_evaluation, id: 1, protected_area: pa, pame_source: ps, restricted: true, wdpa_id: 1,  assessment_is_public: true)
    assert_equal true, pe.restricted
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    actual_csv = File.open('lib/data/seed/test_pame_returns_csv_of_single_restricted_evaluation.csv').read
    assert_equal(result, actual_csv)
  end

  test "returns csv without single not-visible evaluation" do
    pa = nil
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps)
    assert_equal false, pe.protected_area_id.present?
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    actual_csv = File.open('lib/data/seed/test_pame_returns_csv_without_single_not-visible_evaluation.csv').read
    assert_equal(result, actual_csv)
  end

  test "returns a link when assessment_is_public is true and url has a url" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, url: "https://wcmc.io", assessment_is_public: true)
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal "https://wcmc.io",  result[:items].first[:url]
  end

  test "returns not currently public when assessment_is_public is true and url is blank" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, url: "", assessment_is_public: true)
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal "Not currently public",  result[:items].first[:url]
  end

  test "returns not reported when assessment_is_public is false and url is blank" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, url: "", assessment_is_public: false)
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal "Not reported", result[:items].first[:url]
  end

  test "returns not reported when assessment_is_public is false and url has a url" do
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area")
    ps = FactoryGirl.create(:pame_source)
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, url: "https://wcmc.io", assessment_is_public: false)
    result = PameEvaluation.paginate_evaluations(DEFAULT_PARAMS)
    assert_equal "Not reported", result[:items].first[:url]
  end

  test "csv returns a link when assessment_is_public is true and url has a url" do
    region = FactoryGirl.create(:region)
    country = FactoryGirl.create(:country, name: "France", iso_3: "FRA", region: region)
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area", countries: [country])
    ps = FactoryGirl.create(:pame_source, data_title: "N/A", resp_party: "Unknown", year: 2016, language: "English")
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, wdpa_id: 1, id: 1, 
                                              url: "https://wcmc.io", assessment_is_public: true)
    actual_csv = File.open('lib/data/seed/test_pame_csv_returns_a_link_when_assessment_is_public_is_true_and_url_has_a_url.csv').read
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    assert_equal(result, actual_csv)
  end

  test "csv returns not currently public when assessment_is_public is true and url is blank" do
    region = FactoryGirl.create(:region)
    country = FactoryGirl.create(:country, name: "France", iso_3: "FRA", region: region)
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area", countries: [country])
    ps = FactoryGirl.create(:pame_source, data_title: "N/A", resp_party: "Unknown", year: 2016, language: "English")
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, url: "", assessment_is_public: true, id: 1, wdpa_id: 1)
    actual_csv = File.open('lib/data/seed/test_pame_csv_returns_not_currently_public_when_assessment_is_public_is_true_and_url_is_blank.csv').read
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    assert_equal(result, actual_csv)

  end
  
  test "csv returns not reported when assessment_is_public is false and url is blank" do
    region = FactoryGirl.create(:region)
    country = FactoryGirl.create(:country, name: "France", iso_3: "FRA", region: region)
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area", countries: [country])
    ps = FactoryGirl.create(:pame_source, data_title: "N/A", resp_party: "Unknown", year: 2016, language: "English")
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, url: "", assessment_is_public: false, id: 1, wdpa_id: 1)
    actual_csv = File.open('lib/data/seed/test_pame_csv_returns_not_reported_when_assessment_is_public_is_false_and_url_is_blank.csv').read
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    assert_equal(result, actual_csv)    
  end

  test "csv returns not reported when assessment_is_public is false and url has a url" do
    region = FactoryGirl.create(:region)
    country = FactoryGirl.create(:country, name: "France", iso_3: "FRA", region: region)
    pa = FactoryGirl.create(:protected_area, name: "Evaluated Area", countries: [country])
    ps = FactoryGirl.create(:pame_source, data_title: "N/A", resp_party: "Unknown", year: 2016, language: "English")
    pe = FactoryGirl.create(:pame_evaluation, protected_area: pa, pame_source: ps, url: "https://wcmc.io", assessment_is_public: false, id: 1, wdpa_id: 1)
    actual_csv = File.open('lib/data/seed/test_pame_csv_returns_not_reported_when_assessment_is_public_is_false_and_url_has_a_url.csv').read
    result = PameEvaluation.to_csv(DEFAULT_PARAMS)
    assert_equal(result, actual_csv) 
  end  
end
