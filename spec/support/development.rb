module DevelopmentSpecHelper
  # rtorrent returns its bytes and rates in i8 (64bit) per xmlrpc, but ruby
  # only accepts i4. There is a patch for it, but not submitted yet
  def needs_64_bit_xmlrpc_patch
    pending "would fail on a ruby without 64bit support for XMLRPC" if ENV['TRAVIS']
  end
end
