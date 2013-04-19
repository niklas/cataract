class SettingSerializer < BaseSerializer
  attributes :incoming_directory, :disable_signup

  def attributes
    super.tap do |hash|
      hash['id'] = 'all'
    end
  end
end
