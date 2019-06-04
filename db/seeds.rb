require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

OrderItem.destroy_all
Order.destroy_all
Item.destroy_all
User.destroy_all

create(:admin)

merchant_1 = create(:merchant)
merchant_2 = create(:merchant)
merchant_3 = create(:merchant)
merchant_4 = create(:merchant)
inactive_merchant_1 = create(:inactive_merchant)

user_1 = create(:user)
user_2 = create(:user)
user_3 = create(:user)
user_4 = create(:user)
inactive_user_1 = create(:inactive_user)

a11 = user_1.addresses.create(zip: "Zip 1", address: "Address 1", state: "CO", city: "Fairfield")
a12 = user_1.addresses.create(zip: "Zip 2", address: "Address 2", state: "OK", city: "Tulsa")
a21 = user_2.addresses.create(zip: "Zip 3", address: "Address 3", state: "IA", city: "Fairfield")
a22 = user_2.addresses.create(zip: "Zip 2", address: "Address 2", state: "OK", city: "Tulsa")
a31 = user_3.addresses.create(zip: "Zip 3", address: "Address 3", state: "IA", city: "Fairfield")
a32 = user_3.addresses.create(zip: "Zip 4", address: "Address 4", state: "IA", city: "Des Moines")
a41 = user_4.addresses.create(zip: "Zip 5", address: "Address 5", state: "IA", city: "Des Moines")
a41 = user_4.addresses.create(zip: "Zip 6", address: "Address 6", state: "IA", city: "Des Moines")
ai = inactive_user_1.addresses.create(zip: "Zip 12", address: "Address 6", state: "IA", city: "Des Moines")

merchant_1.addresses.create(zip: "Zip 7", address: "Address 1", state: "CO", city: "Fairfield")
merchant_2.addresses.create(zip: "Zip 8", address: "Address 2", state: "OK", city: "Tulsa")
merchant_3.addresses.create(zip: "Zip 9", address: "Address 3", state: "IA", city: "Fairfield")
merchant_4.addresses.create(zip: "Zip 10", address: "Address 4", state: "IA", city: "Des Moines")
inactive_merchant_1.addresses.create(zip: "Zip 11", address: "Address 5", state: "IA", city: "Des Moines")

item_1 = create(:item, user: merchant_1)
item_2 = create(:item, user: merchant_2)
item_3 = create(:item, user: merchant_3)
item_4 = create(:item, user: merchant_4)
create_list(:item, 10, user: merchant_1)

create(:inactive_item, user: merchant_1)
create(:inactive_item, user: inactive_merchant_1)

Random.new_seed
rng = Random.new

order_1 = create(:shipped_order, user: user_1, address: a11)
create(:fulfilled_order_item, order: order_1, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_1, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_1, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_1, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order_2 = create(:shipped_order, user: user_2, address: a21)
create(:fulfilled_order_item, order: order_2, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_2, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_2, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_2, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order_3 = create(:shipped_order, user: user_3, address: a31)
create(:fulfilled_order_item, order: order_3, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_3, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_3, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_3, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order_4 = create(:shipped_order, user: user_4, address: a41)
create(:fulfilled_order_item, order: order_4, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_4, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_4, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_4, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order_5 = create(:order, user: user_1, address: a11)
create(:order_item, order: order_5, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order_5, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).days.ago, updated_at: rng.rand(23).hours.ago)

order_6 = create(:cancelled_order, user: user_2, address: a21)
create(:order_item, order: order_6, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:order_item, order: order_6, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order_7 = create(:shipped_order, user: user_3, address: a31)
create(:fulfilled_order_item, order: order_7, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(4)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_7, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order_8 = create(:packaged_order, user: user_4, address: a41)
create(:fulfilled_order_item, order: order_8, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(4)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order_8, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

puts 'seed data finished'
puts "Users created: #{User.count.to_i}"
# puts "Orders created: #{Order.count.to_i}"
puts "Items created: #{Item.count.to_i}"
# puts "OrderItems created: #{OrderItem.count.to_i}"
