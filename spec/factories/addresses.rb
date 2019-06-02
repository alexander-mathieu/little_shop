FactoryBot.define do
  factory :address do
    user

    sequence(:nickname) { |n| "Nickname #{n}" }
    sequence(:address) { |n| "Address #{n}" }
    sequence(:state) { |n| "State #{n}" }
    sequence(:city) { |n| "City #{n}" }
    sequence(:zip) { |n| "Zip #{n}" }
  end
end
