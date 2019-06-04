require 'rails_helper'

RSpec.describe 'user profile', type: :feature do
  before :each do
    @user = create(:user)
    @no_address_user = create(:user)

    @address = @user.addresses.create(zip: "Zip 1", address: "Address 1", state: "State 1", city: "City 1")
  end

  describe 'registered user visits their profile' do
    it 'shows user information' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      within '#profile-data' do
        expect(page).to have_content("Role: #{@user.role}")
        expect(page).to have_content("Email: #{@user.email}")

        within '#address-details' do
          expect(page).to have_content("Addresses: #{@user.home_address.address} #{@user.home_address.city}, #{@user.home_address.state} #{@user.home_address.zip}")
          expect(page).to have_content("#{@user.city}, #{@user.state} #{@user.zip}")

          expect(page).to have_link("Edit Addresses")
        end

        expect(page).to have_link('Edit Profile')
      end
    end

    it 'users with no addresses see a notice and a link to create an address' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@no_address_user)

      visit profile_path

      within '#address-details' do
        expect(page).to have_link('Add an Address')
        expect(page).to_not have_link('Edit Addresses')

        click_link 'Add an Address'
      end

      expect(current_path).to eq(new_profile_address_path)
    end

    it "displays a link to 'Edit Addresses'" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      click_link 'Edit Addresses'

      expect(current_path).to eq(profile_addresses_path)
    end
  end

  describe 'registered user edits their profile' do
    describe 'edit user form' do
      it 'pre-fills form with all but password information' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_path

        click_link 'Edit Profile'

        expect(current_path).to eq('/profile/edit')

        expect(find_field('Name').value).to eq(@user.name)
        expect(find_field('Email').value).to eq(@user.email)
        expect(find_field('Password').value).to eq(nil)
        expect(find_field('Password confirmation').value).to eq(nil)
      end
    end

    describe 'user information is updated' do
      before :each do
        @updated_name = 'Updated Name'
        @updated_email = 'updated_email@example.com'
        @updated_password = 'newandextrasecure'
      end

      describe 'succeeds with allowable updates' do
        scenario 'all attributes are updated' do
          login_as(@user)
          old_digest = @user.password_digest

          visit edit_profile_path

          fill_in :user_name, with: @updated_name
          fill_in :user_email, with: @updated_email
          fill_in :user_password, with: @updated_password
          fill_in :user_password_confirmation, with: @updated_password

          click_button 'Submit'

          updated_user = User.find(@user.id)

          expect(current_path).to eq(profile_path)
          expect(page).to have_content("Your profile has been updated")
          expect(page).to have_content("#{@updated_name}")

          within '#profile-data' do
            expect(page).to have_content("Email: #{@updated_email}")
          end

          expect(updated_user.password_digest).to_not eq(old_digest)
        end

        scenario 'works if no password is given' do
          login_as(@user)

          old_digest = @user.password_digest

          visit edit_profile_path

          fill_in :user_name, with: @updated_name
          fill_in :user_email, with: @updated_email

          click_button 'Submit'

          updated_user = User.find(@user.id)

          expect(current_path).to eq(profile_path)
          expect(page).to have_content("Your profile has been updated")
          expect(page).to have_content("#{@updated_name}")

          within '#profile-data' do
            expect(page).to have_content("Email: #{@updated_email}")
          end

          expect(updated_user.password_digest).to eq(old_digest)
        end
      end
    end

    it 'fails with non-unique email address change' do
      create(:user, email: 'megan@example.com')
      login_as(@user)

      visit edit_profile_path

      fill_in :user_email, with: 'megan@example.com'

      click_button 'Submit'

      expect(page).to have_content("Email has already been taken")
    end
  end
end
