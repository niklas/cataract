unless defined?(FactoryGirl::Password)
  FactoryGirl::Password = 'secret'
end
FactoryGirl.define do
  factory :user do
    sequence(:email) {|i| "user-#{i}@cataract.local"}
    password FactoryGirl::Password
    password_confirmation FactoryGirl::Password
    factory :registered_user do
    end
  end
end
