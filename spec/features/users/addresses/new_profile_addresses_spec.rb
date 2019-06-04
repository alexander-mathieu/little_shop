require 'rails_helper'

RSpec.describe "as a registered user" do
  describe "when I visit the new address path" do
    before :each do
      @user = create(:user)

      @address = @user.addresses.create!(address: "address", zip: "zip", city: "city", state: "state", nickname: "nickname")

      @zip = "zip 1"
      @city = "city 1"
      @state = "state 1"
      @address = "address 1"
      @nickname = "nickname 1"
      @duplicate_nickname = "nickname"

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit new_profile_address_path
    end

    it "I see a form to create a new address" do
      expect(page).to have_field(:address_zip)
      expect(page).to have_field(:address_city)
      expect(page).to have_field(:address_state)
      expect(page).to have_field(:address_address)
      expect(page).to have_field(:address_nickname)
    end

    describe "and fill in the form correctly and click 'Save Address'" do
      it "a new address is created on my account" do
        fill_in :address_zip, with: @zip
        fill_in :address_city, with: @city
        fill_in :address_state, with: @state
        fill_in :address_address, with: @address
        fill_in :address_nickname, with: @nickname

        click_button 'Save Address'

        expect(@user.addresses.second.zip).to eq(@zip)
        expect(@user.addresses.second.city).to eq(@city)
        expect(@user.addresses.second.state).to eq(@state)
        expect(@user.addresses.second.address).to eq(@address)
        expect(@user.addresses.second.nickname).to eq(@nickname)
      end
    end

    describe "and fill in the form incorrectly and click 'Save Address'" do
      it "the page shows an error" do
        fill_in :address_zip, with: @zip
        fill_in :address_city, with: @city
        fill_in :address_state, with: @state
        fill_in :address_nickname, with: @nickname

        click_button 'Save Address'

        expect(page).to have_content("Address can't be blank")

        fill_in :address_zip, with: @zip
        fill_in :address_city, with: @city
        fill_in :address_state, with: @state
        fill_in :address_address, with: @address
        fill_in :address_nickname, with: @duplicate_nickname

        click_button 'Save Address'

        expect(page).to have_content("Nickname has already been taken")
      end
    end
  end
end
