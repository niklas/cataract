class String
  def escape_quotes
    gsub(/'/, %q['\\\''])
  end
end
