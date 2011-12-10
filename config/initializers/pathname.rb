# we want to do Rails.root / "tmp"
Pathname.send :alias_method, :/, :join
