RSpec::Matchers.define :be_auto_targeted_by do |attrs|
  def targeted(attrs)
    torrent = build :torrent, attrs.reverse_merge(filename: nil)
    move    = build :move, torrent: torrent, target: nil
    move.auto_target!
    move.target
  end
  match do |expected|
    targeted(attrs) == expected
  end

  failure_message_for_should do |expected|
    "#{attrs} should auto-target #{expected.inspect}, but did #{targeted(attrs).inspect}"
  end
end
