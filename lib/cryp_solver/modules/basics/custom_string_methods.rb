module UsefulStrings

#returns a score out of 100, 100 meaning the strings are exactly the same
  def similarity(other)
    ocs = other.chars
    same_count = 0
    self.chars.each_with_index do |char, i|
      same_count += 1 if ocs[i] == char
    end
    same_count * 100 / self.length
  end

  def is_upper?
    self == self.upcase
  end

  def is_lower?
    self == self.downcase
  end

  def letter?
    x = self =~ /[[:alpha:]]/
    if x == 0
      return true
    else
      return false
    end
  end

  def delete_and_return(str)
    wanted = ""
    str.chars.each do |c|
      if self.include?(c)
        wanted += c
      end
    end
    self.delete!(str)
    return wanted
  end

  def delete_after(index)
    self.slice(0..index)
  end

  #returns true if there are any characters besides the ones listed in the argument
  def has_chars_besides?(*c)
    if self.delete(c.join).length > 0
      return true
    else
      return false
    end
  end

  #gets all indices of a 'c'har in a string
  def get_indices_of_letter(c)
    self.chars.each_with_index.map { |a, i| a == c ? i : nil }.compact
  end

  #finds an 'o'ld string or char, and if it's there, replaces all instances of it with a 'n'ew one
  def find_replace(o,n)
    count = self.count(o)
    if o != 0
      count.times do
        i = self.index(o)
        self[i] = n
      end
    end
    return self
  end

  #returns the string with all its letters replaced by X's 'exc'luding given letters
  def x_out_except(*exc)
    exc += ('0'..'9').to_a
    exc.flatten!
    return self.chars.map { |ch| exc.include?(ch) ? ch: "X" }.join
  end

  # given a 'c'har and an 'a'rray of indeces, returns a new string where chars in string are replaced at indeces
  def insert_at_indices(c,a)
    new_string = self.clone
    a.each do |x|
      new_string[x] = c
    end
    return new_string
  end

  # given an 'a'rray of indeces, removes chars in string at indeces
  # doesn't work for strings that contain '#'
  def remove_at_indices(a)
    a.each do |x|
      self[x] = '#'
    end
    return self.delete('#')
  end



  #if any letters are used more than once in a string, returns a unique list of those letters in an array
  def get_repeater_chars
    char_list = []
    r_chars = []
    self.chars.each do |x|
      if char_list.include?(x) && x.letter?
        r_chars << x
      end
      char_list << x
    end
    return r_chars.uniq
  end


  def has_repeater_chars?(*not_counting)
    char_list = []
    self.chars.each do |x|
      if char_list.include?(x) && x.letter?
        unless not_counting.include?(x)
          return true
        end
      end
      char_list << x
    end
    return false
  end

  # if string has no 'a', will return 'a', if it has an 'a' but no 'b', will return 'b'. Has "ab", but no c? C is returned. And so on.
  def next_available_char
    ('a'..'z').each do |char|
      unless self.downcase.include?(char)
        return char
      end
    end
  end

  #takes a word with repeat letters and replaces all non-repeat letters with X's. Upcases others.
  #debugged so when a string has a repeating x in it, the x is replaced so the data isn't lost
  def x_out_nonrepeaters
    if self.downcase.include?('x')
      x_safe = self.gsub('x', self.next_available_char)
    else
      x_safe = self
    end
    return x_safe.x_out_except(x_safe.get_repeater_chars, "'").upcase
  end

  #borrowed this from stack overflow. gets the indeces of a regular expression
  def indices e
    start, result = -1, []
    result << start while start = (self.index e, start + 1)
    result
  end

  #returns list of indices (as array (or nested arrays if multiple repeating characters)) of characters that repeat
  # "Yell" would return [2,3] because those are the positions of the repeating lls
  # "marketer" would return [[2,7][4,6]]
  def get_indices_of_repeaters(*exceptions)
    #if self.get_repeater_chars == [] then return [] end
    #In this program, 'X' is generally the exception. It repeats in words, but isn't counted
    arr = []
    repchars = self.get_repeater_chars
    repchars.delete(*exceptions) unless exceptions == []
    repchars.each do |x|
      arr << get_indices_of_letter(x)
    end
    return arr
  end

  def get_indices_of_uppers
    arr =[]
    self.chars.each do |c|
      if c.is_upper?
        arr << self.index(c)
      end
    end
  end


  def split_off_attribution
    if self == ""
      return self
    end
    arr = self.split(/ /)
    first_name = ""
    names = []
    num = 6
    if num > arr.length - 1
      num = arr.length - 1
    end
    arr[num..-1].each do | x |
      if x[0] == ('-') || x[0] == ('—')
        if [".","?","!"].include?(arr[arr.index(x) - 1][-1])
          first_name = x
          break
        end
      end
    end
    unless first_name
      return self
    end
    if first_name != ""
      n = arr.index(first_name)
      q = arr.length - n
      for i in (1..q)
        names << arr[n]
        arr.delete_at(n)
      end
    end
    return [arr.join(" "), names.join(" ")]
  end

end

module DatableStrings
# returns the previous item's string, not the item object itself. Ignores strings
# that never get turned into items such as ... and retrieves the string one further back
# (In this case it would be "as")
  def find_prev_item_string(storarray, items, index, number_back = 0)
    prev_item_s = items[index - 1 - number_back]
    if prev_item_s == ""
      number_back += 1
      prev_item_s = find_prev_item_string(storarray, items, index, number_back)
    end
    # binding.pry if index == 45

    return prev_item_s
  end

  def split_into_dataObjects (options = {})

    if self.include?(" ")
      default = :word
    else
      default = :letter
    end
    by = options[:by] || by = default
    if by == :word
      items = self.downcase.split(/ /)
      return_hash = items.remove_hyphenation
      items = return_hash[:new_arr]
      hys_posns = return_hash[:hys_posns]
      proper = false
      quote_locs = items.remove_quote_marks
    elsif by == :letter
      items = self.downcase.chars
    end
    storarray = []
    prev_item = nil
    rel_location = 0
    items.each_with_index do |item, index|
      if by == :letter
        if item == " "
          rel_location = 0
        end
        unless item.letter?
          next
        end
      end
      if by == :word
        info = Grammar.get_info_from_punc_on_word(item, prev_word: prev_item)
        rel_location = info[:rel_location] || rel_location = rel_location
        sentence_type = info[:sentence_type] || sentence_type = nil
        proper = info[:proper] || proper = proper
        attribution = info[:attribution] || attribution = 0
        if index == 0
          word_or_name = :word
        end
      end
      punct = item.delete_and_return("-?;:,.!()")
      if item == ""
        next
      end
      if index > 0

        prev_item_s = find_prev_item_string(storarray, items, index)
        prev_item = storarray.return_object_with(:cryp_text, prev_item_s)

        if by == :word
          #prev_end = storarray.return_object_with("abs_location", [index - 1])
          if prev_item && prev_item.rel_location[-1] == :end
            rel_location = 0
          end
          if prev_item.attribution && attribution > 60 || prev_item.attribution[-1] > 60
            word_or_name = :name
          else
            word_or_name = :word
          end
        end
      end

      if by == :letter
        space_ind = self.index(" ", index)
        if !space_ind
          space_ind = items.length + 1
        end
        if items.length > 2
          front_loc = rel_location
          back_loc = index - space_ind
          location = [front_loc, back_loc]
        end
      end

      cryp_text = item.clone

      if by == :word
        x_string = cryp_text.x_out_nonrepeaters()
      end
      if storarray == []
        seen_before = false
      elsif storarray.list_attribute("cryp_text").include?(cryp_text)
        seen_before = true
      else
        seen_before = false
      end
      if seen_before == false
        case by
        when :word
          storarray << WordData.new(cryp_text, x_string: x_string, abs_location: index, rel_location: rel_location, prev_word: prev_item_s, attribution: attribution, word_or_name: word_or_name)
        when :letter
          storarray << LetterData.new(cryp_text, locations: [location], prev_letter: [prev_item_s])
        end
      elsif seen_before == true
        twin = storarray.return_object_with("cryp_text", cryp_text)
        case by
        when :word
          twin.abs_location.concat << index
          twin.rel_location << rel_location
          twin.prev_word.concat << prev_item_s
        when :letter
          twin.locations << location
          twin.prev_letter << prev_item_s
        end
        twin.freq += 1
      end

      if rel_location.is_a? Integer
        rel_location += 1
      end
    end

    return storarray

  end

end




class String
  include UsefulStrings
  include DatableStrings
end
