RSpec::Matchers.define :be_auto_targeted_by do |attrs|
  def targeted(attrs)
    torrent = build :torrent, attrs.reverse_merge(filename: nil)
    move    = build :move, torrent: torrent, target_directory: nil
    move.auto_target!
    move.target_directory
  end
  match do |expected|
    targeted(attrs) == expected
  end

  failure_message_for_should do |expected|
    "#{attrs} should auto-target_directory #{expected.inspect}, but did #{targeted(attrs).inspect}"
  end
end
