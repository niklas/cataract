FactoryGirl.define do
  factory :torrent do
    sequence(:title)    { |i| "Torrent ##{i}" }
    sequence(:filename) { |i| "#{i}.torrent" }
  end
end
