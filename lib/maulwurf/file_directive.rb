class Maulwurf::FileDirective < Maulwurf::Directive
  # ignoring given (left) mime tipe
  def responsible_for?(uri, page)
    page.is_a? Mechanize::File
  end
end

