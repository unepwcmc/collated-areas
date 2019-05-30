require 'rails_helper'

RSpec.feature "Filters", type: :feature do
  feature "can filter countries" do
    scenario "by country" do
      visit root_path
      #click_on(class: "filter__button button filter__button--active")
      #check('usa')
      find('.filter').click
      #click('Apply')
      #expect(page).to have_content('USA')
      #expect(page).to_not have_content('JPN')
    end

    scenario "by year"

    scenario "by methodology"

    scenario "by multiple criteria"
  end
end
