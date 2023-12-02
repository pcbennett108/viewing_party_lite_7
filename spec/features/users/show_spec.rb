# frozen_string_literal: true
require 'rails_helper'

RSpec.describe '#show', type: :feature do
  before :each do
    @user1 = User.create!(name: 'Brendan', email: 'brendan@turing.edu')
    @user2 = User.create!(name: 'Paul', email: 'paul@turing.edu')
    @user3 = User.create!(name: 'Sooyung', email: 'sooyung@turing.edu')
  end
  it 'shows the name of the user next to dashboard' do
    visit user_path(@user1.id)
    expect(page).to have_content("#{@user1.name}'s Dashboard")
  end
  it 'has a discover movies button' do
    visit user_path(@user2.id)
    expect(page).to have_button('Discover Movies')
  end
  it 'has a viewing party list' do
    visit user_path(@user3.id)
    expect(page).to have_content("Viewing Parties")
  end
  describe 'clicking discover movies' do
    it 'takes you to the discover page' do
      visit user_path(@user1.id)
      click_button 'Discover Movies'
      expect(current_path).to eq(discover_user_path(@user1.id))
    end
  end

  describe 'when I visit /users/:user_id/discover' do
    it 'has a home link and discover movies title' do
      visit discover_user_path(@user1)
      expect(page).to have_link('Home')
      expect(page).to have_content('Discover Movies')
    end

    it 'has a discover movies title and a button to top rated movies' do
      VCR.use_cassette('top_movies') do
        visit discover_user_path(@user1)
        expect(page).to have_button('Find Top Rated Movies')
        click_button('Find Top Rated Movies')
        expect(current_path).to eq(user_movies_path(@user1))
      end
    end

    it 'has a text field to search movie by title' do
      visit discover_user_path(@user1)
      expect(page).to have_field('search')
    end

    it 'has a button to find movie' do
      visit discover_user_path(@user1)
      expect(page).to have_button('Find Movies')
    end
  end

  describe 'When I visit the users show page' do
    before(:each) do
      test_data
      visit "/users/#{@user_1.id}"
    end

    context 'displaying viewing parties', :vcr do
      it 'has a section for viewing parties' do
        expect(page).to have_css('#hosted-parties')
      end

      it 'displays cards for each viewing party the user has created' do
        within("#party-#{@party_1.id}") do
          page.has_css?("img[src*='themoviedb']")
          expect(page).to have_content('Dune')
          expect(page).to have_content('Dec 01, 2024')
          expect(page).to have_content('07:23 AM')
          expect(page).to have_content("Host: #{@user_1.name}")
          expect(page).to have_content("Guest List: #{@user_2.name}")
        end
      end

      it 'displays cards for each viewing party the user has been invited to' do
        within("#party-#{@party_2.id}") do
          page.has_css?("img[src*='themoviedb']")
          expect(page).to have_content('Dune')
          expect(page).to have_content('09:23 AM')
          expect(page).to have_content("Guest List: #{@user_1.name}")
        end

        within("#party-#{@party_3.id}") do
          page.has_css?("img[src*='themoviedb']")
          expect(page).to have_content('Dune')
          expect(page).to have_content('01:09 PM')
          expect(page).to have_content("Guest List: #{@user_1.name}")
        end
      end
    end
  end
end
