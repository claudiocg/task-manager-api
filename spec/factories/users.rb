FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "996633"
    password_confirmation "996633"
  end
end