require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Profile Orders page', type: :feature do
  before :each do
    @user = create(:user)
    @one_address_user = create(:user)

    @admin = create(:admin)

    @address = @user.addresses.create!(nickname: 'Nickname 1', address: 'Address 1', city: 'City 1', state: 'State 1', zip: 'Zip 1')
    @new_address = @user.addresses.create!(nickname: 'Nickname 2', address: 'Address 2', city: 'City 2', state: 'State 2', zip: 'Zip 2')
    @one_address = @one_address_user.addresses.create!(address: 'Address 3', city: 'City 3', state: 'State 3', zip: 'Zip 3')

    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @item_1 = create(:item, user: @merchant_1)
    @item_2 = create(:item, user: @merchant_2)
  end

  context 'as a registered user' do
    describe 'should show a message when user no orders' do
      scenario 'when logged in as user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
        visit profile_orders_path

        expect(page).to have_content('You have no orders yet')
      end
    end

    describe 'should show information about each order when I do have orders' do
      before :each do
        yesterday = 1.day.ago
        @order = create(:order, user: @user, created_at: yesterday, address: @address)

        @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 1, created_at: yesterday, updated_at: yesterday)
        @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: 2.hours.ago)
      end

      scenario 'when logged in as user' do
        @user.reload
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_orders_path
      end

      after :each do
        expect(page).to_not have_content('You have no orders yet')

        within "#order-#{@order.id}" do
          expect(page).to have_link("Order ID #{@order.id}")
          expect(page).to have_content("Created: #{@order.created_at}")
          expect(page).to have_content("Last Update: #{@order.updated_at}")
          expect(page).to have_content("Status: #{@order.status}")
          expect(page).to have_content("Item Count: #{@order.total_item_count}")
          expect(page).to have_content("Total Cost: #{@order.total_cost}")
        end
      end
    end

    describe 'should show a single order show page' do
      before :each do
        yesterday = 1.day.ago
        @order = create(:order, user: @user, created_at: yesterday)

        @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
        @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 5, created_at: yesterday, updated_at: 2.hours.ago)
      end

      scenario 'when logged in as user' do
        @user.reload
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_order_path(@order)
      end

      after :each do
        expect(page).to have_content("Order ID #{@order.id}")
        expect(page).to have_content("Created: #{@order.created_at}")
        expect(page).to have_content("Last Update: #{@order.updated_at}")
        expect(page).to have_content("Status: #{@order.status}")
        expect(page).to have_content("Shipping Address: #{@order.address.nickname} - #{@order.address.address}, #{@order.address.city}, #{@order.address.state} #{@order.address.zip}")

        within "#oitem-#{@oi_1.id}" do
          expect(page).to have_content(@oi_1.item.name)
          expect(page).to have_content(@oi_1.item.description)
          expect(page.find("#item-#{@oi_1.item.id}-image")['src']).to have_content(@oi_1.item.image)
          expect(page).to have_content("Merchant: #{@oi_1.item.user.name}")
          expect(page).to have_content("Price: #{number_to_currency(@oi_1.price)}")
          expect(page).to have_content("Quantity: #{@oi_1.quantity}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@oi_1.price*@oi_1.quantity)}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@oi_1.price*@oi_1.quantity)}")
          expect(page).to have_content("Fulfilled: No")
        end

        within "#oitem-#{@oi_2.id}" do
          expect(page).to have_content(@oi_2.item.name)
          expect(page).to have_content(@oi_2.item.description)
          expect(page.find("#item-#{@oi_2.item.id}-image")['src']).to have_content(@oi_2.item.image)
          expect(page).to have_content("Merchant: #{@oi_2.item.user.name}")
          expect(page).to have_content("Price: #{number_to_currency(@oi_2.price)}")
          expect(page).to have_content("Quantity: #{@oi_2.quantity}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@oi_2.price*@oi_2.quantity)}")
          expect(page).to have_content("Fulfilled: Yes")
        end

        expect(page).to have_content("Item Count: #{@order.total_item_count}")
        expect(page).to have_content("Total Cost: #{number_to_currency(@order.total_cost)}")

        expect(page).to have_button("Cancel Order")
        expect(page).to have_button("Change Shipping Address")
      end
    end

    describe "clicking 'Change Shipping Address'" do
      before :each do
        yesterday = 1.day.ago
        @order = create(:order, user: @user, created_at: yesterday)
        @one_address_order = create(:order, user: @one_address_user, created_at: yesterday, address: @one_address)
        @shipped_order = create(:shipped_order, user: @user, created_at: yesterday, address: @address)
        @cancelled_order = create(:cancelled_order, user: @user, created_at: yesterday, address: @address)

        @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
        @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 5, created_at: yesterday, updated_at: 2.hours.ago)
        @oi_3 = create(:fulfilled_order_item, order: @one_address_order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: yesterday)
        @oi_4 = create(:fulfilled_order_item, order: @shipped_order, item: @item_2, price: 2, quantity: 1, created_at: yesterday)
        @oi_5 = create(:order_item, order: @cancelled_order, item: @item_2, price: 2, quantity: 1, created_at: yesterday)
      end

      it 'shows an address change page' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_order_path(@order)

        click_button "Change Shipping Address"

        expect(current_path).to eq(order_address_path(@order))
      end

      it "allows me to change an order address of an order" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_order_path(@order)

        click_button "Change Shipping Address"

        within "#address-#{@new_address.id}" do
          click_button "Use Address"
        end

        @order.reload

        expect(current_path).to eq(profile_order_path(@order))

        expect(page).to have_content("Shipping address updated!")

        expect(page).to have_content("Order ID #{@order.id}")
        expect(page).to have_content("Created: #{@order.created_at}")
        expect(page).to have_content("Last Update: #{@order.updated_at}")
        expect(page).to have_content("Status: #{@order.status}")
        expect(page).to have_content("Shipping Address: #{@new_address.nickname} - #{@new_address.address}, #{@new_address.city}, #{@new_address.state} #{@new_address.zip}")
      end

      it "doesn't allow me to change an address if an order has been cancelled/shipped" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_order_path(@shipped_order)

        expect(page).to_not have_button("Change Shipping Address")

        visit profile_order_path(@cancelled_order)

        expect(page).to_not have_button("Change Shipping Address")
      end

      it "doesn't allow me to change an address on an order if I only have one address" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@one_address_user)

        visit profile_order_path(@one_address_order)

        expect(page).to_not have_button("Change Shipping Address")
      end
    end
  end
end
