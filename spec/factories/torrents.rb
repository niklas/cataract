FactoryGirl.define do
  factory :torrent do
    sequence(:title)    { |i| "Torrent ##{i}" }
    sequence(:filename) { |i| "#{i}.torrent" }
    status 'remote'
    sequence(:info_hash) { |i| "%0.40d" % i }
  end
end
