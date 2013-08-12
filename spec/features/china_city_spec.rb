require 'spec_helper'

feature 'china city', js: true do
  scenario 'select' do
    visit '/china_city'
    within '.rails-helper' do
      select '广东省'
      select '深圳市'
      select '南山区'
    end
    within '.html-tag' do
      select '广东省'
      select '深圳市'
      select '南山区'
    end
  end

  scenario 'clean' do
    visit '/china_city'
    within '.rails-helper' do
      select '广东省'
      select '深圳市'
      select '南山区'
      select '--城市--'
      # save_and_open_page
      expect(find('.city-district').value).to be_blank

      select '深圳市'
      select '南山区'
      select '--省份--'
      expect(find('.city-city').value).to be_blank
      expect(find('.city-district').value).to be_blank
    end
  end
end
