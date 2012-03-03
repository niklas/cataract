# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl'
FactoryGirl.reload

ActionMailer::Base.delivery_method = :test

user = User.find_by_email('cataract@localhost.local') || Factory(:user, :email => 'cataract@localhost.local')

Torrent.transaction do
  Torrent.destroy_all

  if system('fortune')
    60.times do |i|
      Factory :remote_torrent, title: `fortune -s`.split.join(' '), url: "http://localhost.local/#{i}.torrent"
    end
  else
    STDERR.puts "please install fortune to get some nice torrents"
  end
end
