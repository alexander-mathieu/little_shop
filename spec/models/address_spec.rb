require 'rails_helper'

RSpec.describe Address, type: :model do
  describe "validations" do
    it { should validate_presence_of :zip }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :address }
    it { should validate_presence_of :nickname }
  end

  describe "relationships" do
    it { should belong_to :user }
    it { should have_many :orders }
  end

  describe "instance methods" do
    before :each do
      @merchant = create(:merchant)
      @user = create(:user)

      @address_1 = @user.addresses.create(nickname: "Nickname 1", address: 'Address 1', city: 'City 1', state: 'State 1', zip: 'Zip 1')
      @address_2 = @user.addresses.create(nickname: "Nickname 2", address: 'Address 2', city: 'City 2', state: 'State 2', zip: 'Zip 2')

      @i1, @i2, @i3, @i4 = create_list(:item, 4, user: @merchant)

      @o1 = create(:order, address: @address_1)
      @o2 = create(:order, address: @address_2)
      @o5 = create(:order, address: @address_1)
      @o6 = create(:order, address: @address_2)
      @o3 = create(:shipped_order, address: @address_1)
      @o4 = create(:cancelled_order, address: @address_1)

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

    it ".not_ordered?" do
      expect(@address_2.not_ordered?).to eq(true)
      expect(@address_1.not_ordered?).to eq(false)
    end
  end
end
