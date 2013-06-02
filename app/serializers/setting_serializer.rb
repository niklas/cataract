class SettingSerializer < BaseSerializer
  attributes :disable_signup
  has_one :incoming_directory

  def attributes
    super.tap do |hash|
      hash['id'] = 'all'
    end
  end
end
