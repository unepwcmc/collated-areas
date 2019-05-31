require 'rails_helper'

RSpec.feature "Filters", type: :feature do
  feature "can filter countries" do
    scenario "by country" do
      visit root_path
      find('.filter', text: 'Country').click
      save_screenshot
      find('.filter__option', text: 'USA', visible: false).check
      save_screenshot
      click_on('Apply')
      save_screenshot
      expect(page).to have_content('USA')
      expect(page).to_not have_content('JPN')
    end

    scenario "by year"

    scenario "by methodology"

    scenario "by multiple criteria"
  end
end
