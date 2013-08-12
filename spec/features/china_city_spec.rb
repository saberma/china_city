require 'spec_helper'

feature 'china city' do
  scenario 'select', js: true do
    visit '/china_city'
    save_and_open_page
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
end
