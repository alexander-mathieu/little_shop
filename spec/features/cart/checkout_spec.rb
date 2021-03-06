require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe "Checking out" do
  before :each do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @item_1 = create(:item, user: @merchant_1, inventory: 3)
    @item_2 = create(:item, user: @merchant_2)
    @item_3 = create(:item, user: @merchant_2)

    visit item_path(@item_1)
    click_on "Add to Cart"

    visit item_path(@item_2)
    click_on "Add to Cart"

    visit item_path(@item_3)
    click_on "Add to Cart"

    visit item_path(@item_3)
    click_on "Add to Cart"
  end

  context "as a logged in regular user" do
    before :each do
      @user = create(:user)
      @no_address_user = create(:user)

      @address_1 = @user.addresses.create(nickname: "Nickname 1", address: "Address 1", state: "State 1", city: "City 1", zip: "Zip 1")
      @address_2 = @user.addresses.create(nickname: "Nickname 2", address: "Address 2", state: "State 2", city: "City 2", zip: "Zip 2")
    end

    it "should have buttons to checkout with a specific address" do
      login_as(@user)

      visit cart_path

      expect(page).to have_button("Checkout with #{@user.addresses.first.address}")
      expect(page).to have_button("Checkout with #{@user.addresses.second.address}")
    end

    it "should create a new order" do
      login_as(@user)

      visit cart_path

      click_button "Checkout with #{@user.addresses.first.address}"

      @new_order = Order.last

      expect(current_path).to eq(profile_orders_path)

      expect(page).to have_content("Your order has been created!")
      expect(page).to have_content("Cart: 0")

      within("#order-#{@new_order.id}") do
        expect(page).to have_link("Order ID #{@new_order.id}")
        expect(page).to have_content("Status: pending")
      end
    end

    it "should create order items" do
      login_as(@user)

      visit cart_path

      click_button "Checkout with #{@user.addresses.first.address}"

      @new_order = Order.last

      visit profile_order_path(@new_order)

      within("#oitem-#{@new_order.order_items.first.id}") do
        expect(page).to have_content(@item_1.name)
        expect(page).to have_content(@item_1.description)

        expect(page.find("#item-#{@item_1.id}-image")['src']).to have_content(@item_1.image)
        expect(page).to have_content("Merchant: #{@merchant_1.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_1.price)}")
        expect(page).to have_content("Quantity: 1")
        expect(page).to have_content("Fulfilled: No")
      end

      within("#oitem-#{@new_order.order_items.second.id}") do
        expect(page).to have_content(@item_2.name)
        expect(page).to have_content(@item_2.description)
        expect(page.find("#item-#{@item_2.id}-image")['src']).to have_content(@item_2.image)
        expect(page).to have_content("Merchant: #{@merchant_2.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_2.price)}")
        expect(page).to have_content("Quantity: 1")
        expect(page).to have_content("Fulfilled: No")
      end

      within("#oitem-#{@new_order.order_items.third.id}") do
        expect(page).to have_content(@item_3.name)
        expect(page).to have_content(@item_3.description)
        expect(page.find("#item-#{@item_3.id}-image")['src']).to have_content(@item_3.image)
        expect(page).to have_content("Merchant: #{@merchant_2.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_3.price)}")
        expect(page).to have_content("Quantity: 2")
        expect(page).to have_content("Fulfilled: No")
      end
    end

    it "should prompt users with no address to create an address to checkout" do
      login_as(@no_address_user)

      visit item_path(@item_1)
      click_on "Add to Cart"

      visit item_path(@item_2)
      click_on "Add to Cart"

      visit item_path(@item_3)
      click_on "Add to Cart"

      visit item_path(@item_3)
      click_on "Add to Cart"

      visit cart_path

      expect(page).to have_link("Please add an address to checkout!")
    end

    describe "clicking link 'Please add an address to checkout!'" do
      it "shows a form to create an address" do
        login_as(@no_address_user)

        visit item_path(@item_1)
        click_on "Add to Cart"

        visit item_path(@item_2)
        click_on "Add to Cart"

        visit item_path(@item_3)
        click_on "Add to Cart"

        visit item_path(@item_3)
        click_on "Add to Cart"

        visit cart_path

        click_link "Please add an address to checkout!"

        expect(current_path).to eq(new_profile_address_path)

        expect(page).to have_field(:address_zip)
        expect(page).to have_field(:address_city)
        expect(page).to have_field(:address_state)
        expect(page).to have_field(:address_address)
        expect(page).to have_field(:address_nickname)
      end

      it "redirects to cart path when form is completed" do
        login_as(@no_address_user)

        visit item_path(@item_1)
        click_on "Add to Cart"

        visit item_path(@item_2)
        click_on "Add to Cart"

        visit item_path(@item_3)
        click_on "Add to Cart"

        visit item_path(@item_3)
        click_on "Add to Cart"

        visit cart_path

        click_link "Please add an address to checkout!"

        fill_in :address_zip, with: "first zip"
        fill_in :address_city, with: "first city"
        fill_in :address_state, with: "first state"
        fill_in :address_address, with: "first address"
        fill_in :address_nickname, with: "first nickname"

        click_button "Save Address"

        expect(current_path).to eq(cart_path)
      end
    end
  end

  context "as a visitor" do
    it "should tell the user to login or register" do
      visit cart_path

      expect(page).to have_content("You must register or log in to check out.")
      click_link "register"
      expect(current_path).to eq(registration_path)

      visit cart_path

      click_link "log in"
      expect(current_path).to eq(login_path)
    end
  end
end
