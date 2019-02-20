class Hash

  def to_uncluttered_string_limited(limit)
    arr = []
    self.each do |k, v|
      arr << "#{k}: #{v}"
    end
    arr.to_uncluttered_string_limited(limit)
  end

end
