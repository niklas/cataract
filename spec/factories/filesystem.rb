FactoryGirl.define do
  factory :directory do
    sequence(:name) { |i| "Directory ##{i}" }
    sequence(:path) { |i| "/tmp/directory_#{i}" }
    watched false
  end
end
