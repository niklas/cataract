module SettingsDefaults
  DEFAULTS = {
    :history_dir => '[must be configured]',
    :torrent_dir => '[must be configured]',
    :target_dir  => '[must be configured]',
    :min_port    => 6881,
    :max_port    => 6889,
    :interval    => 42,
    :max_up_rate => 5,
    :queue_manager_url => "druby://127.0.0.1:5523"
  }
end

