# encoding: utf-8
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

  describe 'clean' do
    before do
      visit '/china_city'
      within '.rails-helper' do
        select '广东省'
        select '深圳市'
        select '南山区'
      end
    end
    context 'select empty parent' do
      scenario 'city and district' do
        within '.rails-helper' do
          select '--省份--'
          expect(find('.city-city').value).to be_blank
          expect(find('.city-district').value).to be_blank
          sleep 2
          expect(all('.city-city option').size).to eql 1
          expect(all('.city-district option').size).to eql 1
        end
      end
      scenario 'district' do
        within '.rails-helper' do
          select '--城市--'
          expect(find('.city-district').value).to be_blank
          sleep 2
          expect(all('.city-district option').size).to eql 1
        end
      end
    end
    context 'select other parent' do
      scenario 'city and district' do
        within '.rails-helper' do
          select '江苏省'
          expect(find('.city-city').value).to be_blank
          expect(find('.city-district').value).to be_blank
          sleep 2
          expect(all('.city-city option').size).to eql 14
          expect(all('.city-district option').size).to eql 1
        end
      end
      scenario 'district' do
        within '.rails-helper' do
          select '广州市'
          expect(find('.city-district').value).to be_blank
          sleep 2
          expect(all('.city-district option').size).to eql 12
        end
      end
    end
  end
end
