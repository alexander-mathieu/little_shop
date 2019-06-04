require 'rails_helper'

RSpec.describe 'Profile Addresses page', type: :feature do
  before :each do
    @user_1 = create(:user)
    @user_2 = create(:user)

    @merchant = create(:merchant)
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

    describe "when I click 'Add an Address'" do
      it "I'm navigated to the new address path'" do
        click_link 'Add an Address'

        expect(current_path).to eq(new_profile_address_path)
      end

      it "and create a new address, I see that address on my address index" do
        click_link 'Add an Address'

        fill_in :address_zip, with: 'zip 1'
        fill_in :address_city, with: 'city 1'
        fill_in :address_state, with: 'state 1'
        fill_in :address_address, with: 'address 1'
        fill_in :address_nickname, with: 'nickname 1'

        click_button 'Save Address'

        address = Address.last

        within "#address-#{address.id}" do
          expect(page).to have_content(address.nickname)
          expect(page).to have_content("#{address.address} #{address.city}, #{address.state} #{address.zip}")
        end
      end
    end
  end

  context 'as a registered user with multiple addresses' do
    before :each do
      @address_1 = @user_1.addresses.create!(zip: "Zip 1", address: "Address 1", state: "State 1", city: "City 1")
      @address_2 = @user_1.addresses.create!(zip: "Zip 2", address: "Address 2", state: "State 2", city: "City 2", nickname: "Nickname 2")
      @address_3 = @user_1.addresses.create!(zip: "Zip 3", address: "Address 3", state: "State 3", city: "City 3", nickname: "Nickname 3")
      @address_4 = @user_1.addresses.create!(zip: "Zip 4", address: "Address 4", state: "State 4", city: "City 4", nickname: "Nickname 4")

      @i1, @i2, @i3, @i4 = create_list(:item, 4, user: @merchant)

      @o1 = create(:order, address: @address_1)
      @o2 = create(:order, address: @address_2)
      @o5 = create(:order, address: @address_3)
      @o6 = create(:order, address: @address_4)
      @o3 = create(:shipped_order, address: @address_1)
      @o4 = create(:cancelled_order, address: @address_2)

      create(:order_item, order: @o1, item: @i1, quantity: 1, price: 2)
      create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
      create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
      create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
      create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
      create(:order_item, order: @o5, item: @i3, quantity: 8, price: 2)
      create(:order_item, order: @o5, item: @i4, quantity: 10, price: 2)
      create(:order_item, order: @o6, item: @i3, quantity: 8, price: 2)
      create(:order_item, order: @o6, item: @i4, quantity: 12, price: 2)
    end

    it 'the page should display all addresses for the user' do
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

      it 'the page should display a link to edit addresses that have not been used in completed orders' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

        visit profile_addresses_path

        within "#address-#{@address_1.id}" do
          expect(page).to_not have_link('Edit')
        end

        within "#address-#{@address_2.id}" do
          expect(page).to have_link('Edit')
        end

        within "#address-#{@address_3.id}" do
          expect(page).to have_link('Edit')
        end

        within "#address-#{@address_4.id}" do
          expect(page).to have_link('Edit')
        end
      end

      it 'the page should display a link to delete addresses that have not been used in completed orders' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

        visit profile_addresses_path

        within "#address-#{@address_1.id}" do
          expect(page).to_not have_link('Delete')
        end

        within "#address-#{@address_2.id}" do
          expect(page).to have_link('Delete')
        end

        within "#address-#{@address_3.id}" do
          expect(page).to have_link('Delete')
        end

        within "#address-#{@address_4.id}" do
          expect(page).to have_link('Delete')
        end
      end

      describe "and click 'Edit' beside an address name" do
        it "I'm brought to an edit form for that address" do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

          visit profile_addresses_path

          within "#address-#{@address_2.id}" do
            click_link 'Edit'
          end

          expect(current_path).to eq(edit_profile_address_path(@address_2.id))
        end

        describe "and fill out all the form correctly" do
          before :each do
            @updated_zip = 'updated zip'
            @updated_city = 'updated city'
            @updated_state = 'updated state'
            @updated_address = 'updated address'
            @updated_nickname = 'updated nickname'
          end

          it "I see a notifcation and the updated information on my address list" do
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

            visit profile_addresses_path

            within "#address-#{@address_2.id}" do
              click_link 'Edit'
            end

            fill_in :address_zip, with: @updated_zip
            fill_in :address_city, with: @updated_city
            fill_in :address_state, with: @updated_state
            fill_in :address_address, with: @updated_address
            fill_in :address_nickname, with: @updated_nickname

            click_button 'Save Address'

            expect(current_path).to eq (profile_addresses_path)

            expect(page).to have_content("Address updated.")

            within "#address-#{@address_2.id}" do
              expect(page).to have_content(@updated_nickname)
              expect(page).to have_content("#{@updated_address} #{@updated_city}, #{@updated_state} #{@updated_zip}")
            end
          end
        end

        describe "and fill out the edit form partially" do
          before :each do
            @updated_zip = 'updated zip'
            @updated_city = 'updated city'
            @updated_state = 'updated state'
            @updated_address = 'updated address'
            @updated_nickname = 'updated nickname'
          end

          it "I see a notifcation and the updated information on my address list" do
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

            visit profile_addresses_path

            within "#address-#{@address_2.id}" do
              click_link 'Edit'
            end

            fill_in :address_zip, with: @updated_zip
            fill_in :address_address, with: @updated_address
            fill_in :address_nickname, with: @updated_nickname

            click_button 'Save Address'

            expect(page).to have_content(@updated_nickname)
            expect(page).to have_content("#{@updated_address} #{@address_2.city}, #{@address_2.state} #{@updated_zip}")
          end
        end
      end

      describe "and click 'Delete' beside an address name" do
        it "I no longer see that address on my address list" do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

          visit profile_addresses_path

          within "#address-#{@address_2.id}" do
            click_link 'Delete'
          end

          expect(page).to have_content("Address deleted.")
          expect(page).to_not have_css("#address-#{@address_2.id}")

          expect(@user_1.addresses.count).to eq(3)
      end
    end
  end
end
