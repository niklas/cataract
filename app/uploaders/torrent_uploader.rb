# encoding: utf-8

class TorrentUploader < CarrierWave::Uploader::Base

  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process :set_filename_on_model
  process :set_info_hash

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(torrent)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  private

  def set_filename_on_model
    model.filename = filename
  end

  def set_info_hash
    model.info_hash = model.metainfo.sha1.unpack('H*').first.upcase
  rescue Torrent::FileError => e
    Rails.logger.debug { "could not set info hash from metainfo: #{e.message}" }
  end

end
