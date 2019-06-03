require 'rails_helper'

RSpec.describe 'Profile Addresses page', type: :feature do
  before :each do
    @user_1 = create(:user)
    @user_2 = create(:user)
  end

  context 'as a registered user with no addresses' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_2)

      visit profile_addresses_path
    end

    it 'should show a message when user has no addresses' do
      expect(page).to have_content("You don't have any addresses yet.")
    end

    it 'should display a link to add an address' do
      expect(page).to have_link("Add an Address")
    end
  end

  context 'as a registered user with multiple addresses' do
    before :each do
      @address_1 = @user_1.addresses.create!(zip: "Zip 1", address: "Address 1", state: "State 1", city: "City 1")
      @address_2 = @user_1.addresses.create!(zip: "Zip 2", address: "Address 2", state: "State 2", city: "City 2", nickname: "Nickname 2")
      @address_3 = @user_1.addresses.create!(zip: "Zip 3", address: "Address 3", state: "State 3", city: "City 3", nickname: "Nickname 3")
      @address_4 = @user_1.addresses.create!(zip: "Zip 4", address: "Address 4", state: "State 4", city: "City 4", nickname: "Nickname 4")
    end

    it 'should display all addresses for the user' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit profile_addresses_path

      within "#address-#{@address_1.id}" do
        expect(page).to have_content(@address_1.nickname)
        expect(page).to have_content("#{@address_1.address} #{@address_1.city}, #{@address_1.state} #{@address_1.zip}")
      end

      within "#address-#{@address_2.id}" do
        expect(page).to have_content(@address_2.nickname)
        expect(page).to have_content("#{@address_2.address} #{@address_2.city}, #{@address_2.state} #{@address_2.zip}")
      end

      within "#address-#{@address_3.id}" do
        expect(page).to have_content(@address_3.nickname)
        expect(page).to have_content("#{@address_3.address} #{@address_3.city}, #{@address_3.state} #{@address_3.zip}")
      end

      within "#address-#{@address_4.id}" do
        expect(page).to have_content(@address_4.nickname)
        expect(page).to have_content("#{@address_4.address} #{@address_4.city}, #{@address_4.state} #{@address_4.zip}")
      end
    end
  end
end
