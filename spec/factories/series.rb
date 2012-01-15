FactoryGirl.define do
  factory :series do
    sequence(:title) { |i| "Serie #{i}" }
  end
end

