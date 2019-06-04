require 'rails_helper'

RSpec.describe "merchant index workflow", type: :feature do
  describe "As a visitor" do
    describe "displays all active merchant information" do
      before :each do
        @merchant_1 = create(:merchant)
        @merchant_2 = create(:merchant)
        @inactive_merchant = create(:inactive_merchant)

        @address_1 = @merchant_1.addresses.create!(zip: "Zip 1", address: "Address 1", state: "State 1", city: "City 1")
        @address_2 = @merchant_2.addresses.create!(zip: "Zip 2", address: "Address 2", state: "State 2", city: "City 2")
        @address_3 = @inactive_merchant.addresses.create!(zip: "Zip 3", address: "Address 3", state: "State 3", city: "City 3")
      end

      scenario 'as a visitor' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
        @am_admin = false
      end

      scenario 'as an admin' do
        admin = create(:admin)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        @am_admin = true
      end

      after :each do
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_content(@merchant_1.name)
          expect(page).to have_content("#{@merchant_1.home_address.city}, #{@merchant_1.home_address.state}")
          expect(page).to have_content("Registered Date: #{@merchant_1.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        within("#merchant-#{@merchant_2.id}") do
          expect(page).to have_content(@merchant_2.name)
          expect(page).to have_content("#{@merchant_2.home_address.city}, #{@merchant_2.home_address.state}")
          expect(page).to have_content("Registered Date: #{@merchant_2.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        if @am_admin
          within("#merchant-#{@inactive_merchant.id}") do
            expect(page).to have_button('Enable Merchant')
          end
        else

          expect(page).to_not have_content(@inactive_merchant.name)
        end
      end
    end

    describe 'admins can enable/disable merchants' do
      before :each do
        @merchant_1 = create(:merchant)
        @admin = create(:admin)

        @address = @merchant_1.addresses.create!(zip: "Zip 1", address: "Address 1", state: "State 1", city: "City 1")
      end

      it 'allows an admin to disable a merchant' do
        login_as(@admin)

        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Disable Merchant')
        end

        expect(current_path).to eq(merchants_path)

        visit logout_path

        login_as(@merchant_1)

        expect(current_path).to eq(login_path)

        expect(page).to have_content('Your account is inactive, contact an admin for help')

        visit logout_path

        login_as(@admin)

        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Enable Merchant')
        end

        visit logout_path

        login_as(@merchant_1)

        expect(current_path).to eq(dashboard_path)

        visit logout_path

        login_as(@admin)

        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_button('Disable Merchant')
        end
      end
    end

    describe "shows merchant statistics" do
      before :each do
        u1 = create(:user)
        u3 = create(:user)
        u2 = create(:user)
        u4 = create(:user)
        u5 = create(:user)
        u6 = create(:user)

        @a1 = u1.addresses.create(zip: "Zip 1", address: "Address 1", state: "CO", city: "Fairfield")
        @a2 = u2.addresses.create(zip: "Zip 2", address: "Address 2", state: "IA", city: "Fairfield")
        @a3 = u3.addresses.create(zip: "Zip 3", address: "Address 3", state: "OK", city: "OKC")
        @a4 = u4.addresses.create(zip: "Zip 4", address: "Address 4", state: "IA", city: "Des Moines")
        @a5 = u5.addresses.create(zip: "Zip 5", address: "Address 5", state: "IA", city: "Des Moines")
        @a6 = u6.addresses.create(zip: "Zip 6", address: "Address 6", state: "IA", city: "Des Moines")

        @m1 = create(:merchant)
        @m2 = create(:merchant)
        @m3 = create(:merchant)
        @m4 = create(:merchant)
        @m5 = create(:merchant)
        @m6 = create(:merchant)
        @m7 = create(:merchant)

        @am1 = @m1.addresses.create(zip: "Zip 1", address: "Address 1", state: "CO", city: "Fairfield")
        @am2 = @m2.addresses.create(zip: "Zip 2", address: "Address 2", state: "IA", city: "Fairfield")
        @am3 = @m3.addresses.create(zip: "Zip 3", address: "Address 3", state: "OK", city: "OKC")
        @am4 = @m4.addresses.create(zip: "Zip 4", address: "Address 4", state: "IA", city: "Des Moines")
        @am5 = @m5.addresses.create(zip: "Zip 5", address: "Address 5", state: "IA", city: "Des Moines")
        @am6 = @m6.addresses.create(zip: "Zip 6", address: "Address 6", state: "IA", city: "Des Moines")
        @am7 = @m7.addresses.create(zip: "Zip 7", address: "Address 7", state: "IA", city: "Des Moines")

        i1 = @m1.items.create!(name: "Item Name 1", description: "Description 1", image: "https://picsum.photos/200/300?image=1", price: 3, inventory: 4)
        i2 = @m2.items.create!(name: "Item Name 2", description: "Description 2", image: "https://picsum.photos/200/300?image=2", price: 4.5, inventory: 6)
        i3 = @m3.items.create!(name: "Item Name 3", description: "Description 3", image: "https://picsum.photos/200/300?image=3", price: 6, inventory: 8)
        i4 = @m4.items.create!(name: "Item Name 4", description: "Description 4", image: "https://picsum.photos/200/300?image=4", price: 7.50, inventory: 10)
        i5 = @m5.items.create!(name: "Item Name 5", description: "Description 5", image: "https://picsum.photos/200/300?image=5", price: 9, inventory: 12)
        i6 = @m6.items.create!(name: "Item Name 6", description: "Description 6", image: "https://picsum.photos/200/300?image=6", price: 10.50, inventory: 14)
        i7 = @m7.items.create!(name: "Item Name 7", description: "Description 7", image: "https://picsum.photos/200/300?image=7", price: 12, inventory: 16)

        @o1 = create(:shipped_order, user: u1, address: @a1)
        @o2 = create(:shipped_order, user: u2, address: @a2)
        @o3 = create(:shipped_order, user: u3, address: @a3)
        @o4 = create(:shipped_order, user: u1, address: @a1)
        @o5 = create(:cancelled_order, user: u5, address: @a5)
        @o6 = create(:shipped_order, user: u6, address: @a6)
        @o7 = create(:shipped_order, user: u6, address: @a6)

        oi1 = create(:fulfilled_order_item, item: i1, order: @o1, created_at: 5.minutes.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: @o2, created_at: 53.5.hours.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: @o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: @o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: @o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: @o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: @o7, created_at: 2.hours.ago)
      end

      it "top 3 merchants by price and quantity, with their revenue" do
        visit merchants_path

        within("#top-three-merchants-revenue") do
          expect(page).to have_content("#{@m7.name}: $192.00")
          expect(page).to have_content("#{@m6.name}: $147.00")
          expect(page).to have_content("#{@m3.name}: $48.00")
        end
      end

      it "top 3 merchants who were fastest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#top-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m1.name}: 00 hours 05 minutes")
          expect(page).to have_content("#{@m7.name}: 02 hours 00 minutes")
          expect(page).to have_content("#{@m2.name}: 2 days 05 hours 30 minutes")
        end
      end

      it "worst 3 merchants who were slowest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#bottom-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m3.name}: 6 days 00 hours 00 minutes")
          expect(page).to have_content("#{@m6.name}: 3 days 00 hours 00 minutes")
          expect(page).to have_content("#{@m2.name}: 2 days 05 hours 30 minutes")
        end
      end

      it "top 3 states where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-states-by-order") do
          expect(page).to have_content("IA: 3 orders")
          expect(page).to have_content("CO: 2 orders")
          expect(page).to have_content("OK: 1 order")
          expect(page).to_not have_content("OK: 1 orders")
        end
      end

      it "top 3 cities where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-cities-by-order") do
          expect(page).to have_content("Des Moines, IA: 2 orders")
          expect(page).to have_content("Fairfield, CO: 2 orders")
          expect(page).to have_content("Fairfield, IA: 1 order")
          expect(page).to_not have_content("Fairfield, IA: 1 orders")
        end
      end

      it "top 3 orders by quantity of items shipped, plus their quantities" do
        visit merchants_path

        within("#top-orders-by-items-shipped") do
          expect(page).to have_content("Order #{@o7.id}: 16 items")
          expect(page).to have_content("Order #{@o6.id}: 14 items")
          expect(page).to have_content("Order #{@o3.id}: 8 items")
        end
      end
    end
  end
end
