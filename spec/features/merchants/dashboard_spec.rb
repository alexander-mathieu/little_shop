require 'rails_helper'

RSpec.describe 'merchant dashboard' do
  before :each do
    @merchant = create(:merchant)
    @admin = create(:admin)
    @user = create(:user)

    @user_address = @user.addresses.create(address: 'User Address', city: 'User City', state: 'User State', zip: 'User Zip')
    @merchant_address = @merchant.addresses.create(address: 'Merchant Address', city: 'Merchant City', state: 'Merchant State', zip: 'Merchant Zip')

    @i1, @i2, @i3, @i4 = create_list(:item, 4, user: @merchant)
    @o1 = create(:order, address: @user_address)
    @o2 = create(:order, address: @user_address)
    @o5 = create(:order, address: @user_address)
    @o6 = create(:order, address: @user_address)
    @o3 = create(:shipped_order, address: @user_address)
    @o4 = create(:cancelled_order, address: @user_address)

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

  describe 'merchant user visits their profile' do
    describe 'shows merchant information' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

        visit dashboard_path

        expect(page).to_not have_button("Downgrade to User")
      end

      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

        visit admin_merchant_path(@merchant)
      end

      after :each do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content("Email: #{@merchant.email}")
        expect(page).to have_content("Address: #{@merchant.home_address.address}")
        expect(page).to have_content("City: #{@merchant.home_address.city}")
        expect(page).to have_content("State: #{@merchant.home_address.state}")
        expect(page).to have_content("Zip: #{@merchant.home_address.zip}")
      end
    end

    describe 'shows to-do list' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

        visit dashboard_path

        expect(page).to have_css(".to-do-list")
      end

      scenario 'as an admin user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

        visit admin_merchant_path(@merchant)

        expect(page).to_not have_css(".to-do-list")
      end
    end
  end

  describe 'merchant user with orders visits their profile' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_path
    end

    it 'shows merchant information' do
      expect(page).to have_content(@merchant.name)
      expect(page).to have_content("Email: #{@merchant.email}")
      expect(page).to have_content("Address: #{@merchant.home_address.address}")
      expect(page).to have_content("City: #{@merchant.home_address.city}")
      expect(page).to have_content("State: #{@merchant.home_address.state}")
      expect(page).to have_content("Zip: #{@merchant.home_address.zip}")
    end

    it 'does not have a link to edit information' do
      expect(page).to_not have_link('Edit')
    end

    it 'shows pending order information' do
      within("#order-#{@o1.id}") do
        expect(page).to have_link(@o1.id)
        expect(page).to have_content(@o1.created_at)
        expect(page).to have_content(@o1.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o1.total_price_for_merchant(@merchant.id))
      end

      within("#order-#{@o2.id}") do
        expect(page).to have_link(@o2.id)
        expect(page).to have_content(@o2.created_at)
        expect(page).to have_content(@o2.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o2.total_price_for_merchant(@merchant.id))
      end
    end

    it 'shows a warning beside pending orders current inventory cannot cover' do
      within("#order-#{@o6.id}") do
        expect(page).to have_content("Insufficient inventory to fulfill!")
      end

      within("#order-#{@o1.id}") do
        expect(page).to_not have_content("Insufficient inventory to fulfill!")
      end

      within("#order-#{@o2.id}") do
        expect(page).to_not have_content("Insufficient inventory to fulfill!")
      end

      within("#order-#{@o5.id}") do
        expect(page).to_not have_content("Insufficient inventory to fulfill!")
      end
    end

    it 'does not show non-pending orders' do
      expect(page).to_not have_css("#order-#{@o3.id}")
      expect(page).to_not have_css("#order-#{@o4.id}")
    end

    it 'shows links to edit pages for items without pictures within to-do list' do
      within '.to-do-list' do
        within '#items-without-pictures' do
          expect(page).to have_content("Add photos for these items to increase sales:")

          expect(page).to have_link(@i1.name)
          expect(page).to have_link(@i2.name)

          click_link "#{@i1.name}"

          expect(current_path).to eq(edit_dashboard_item_path(@i1))
        end
      end
    end

    it 'shows items that have insufficient inventory to fulfill all orders' do
      within '.to-do-list' do
        within '#items-with-insufficient-inventory' do
          expect(page).to have_content("These items have insufficient inventory to fulfill all orders and need to be restocked:")

          expect(page).to have_link(@i3.name)
          expect(page).to have_link(@i4.name)

          expect(page).to_not have_link(@i1.name)
          expect(page).to_not have_link(@i2.name)
        end
      end
    end

    it 'shows a statistic about unfulfilled items and revenue impact' do
      within '.to-do-list' do
        within '#unfulfilled-item-revenue' do
          expect(page).to have_content("You have 4 unfulfilled orders worth $74.00!")
        end
      end
    end

    describe 'shows a link to merchant items' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

        visit dashboard_path

        click_link('Items for Sale')

        expect(current_path).to eq(dashboard_items_path)
      end

      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

        visit admin_merchant_path(@merchant)

        expect(page.status_code).to eq(200)

        click_link('Items for Sale')

        expect(current_path).to eq(admin_merchant_items_path(@merchant))
      end
    end
  end
end
