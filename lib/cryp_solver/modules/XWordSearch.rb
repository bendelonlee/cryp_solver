require "rubygems"
require "require_all"

require_rel "basics"
# require_relative "../classes/trackers/Trackers"



module XWordSearch


  #returns true if for both words (should be same length), the given letter is
  #in the same positions
  def letter_same_for_both?(w1, w2, c)
    if w1.get_indices_of_letter(c) == w2.get_indices_of_letter(c)
      return true
    else
      return false
    end
  end


  #given a string such as "hXlX" will return an array of all likely words, X's representing any character
  def self.select_words(x_string, arr_of_words, *solved_letters)

    likely_words = arr_of_words.select{|word| x_string.length == word.length}
    likely_words.map! { |x| x.downcase }
    #first handling simplest likely case... XXXXX, for example
    unless x_string.has_chars_besides?("X")
      return likely_words.remove_all_with(solved_letters).reject{|x| x.has_repeater_chars?}
    end
    #now cases where there are solved_letters (but no repeaters...)
    unsolved_repeaters = x_string.chars.reject{|char| char.is_lower? || char == "X"}
    if unsolved_repeaters.length == 0
      return match_likely_with_solved_letters(x_string, likely_words, *solved_letters).reject do |x|
        x.has_repeater_chars?(*x_string.get_repeater_chars)
      end
    else

      #now cases where there are repeating characters
      return match_likely_repeaters(x_string, likely_words, *solved_letters)
    end


  end

  private
  #retuns words where the solved letters are present and in the right places
  def self.match_likely_with_solved_letters(x_string, likely_words, *solved_letters)
    x_string_solved_letters = x_string.chars.reject{|char| char.is_upper?}.uniq
    wordlist_narrowed = []
    likely_words.each do |word|
      if word.length != x_string.length then next end
        if word.include?("'")
          next unless x_string.include?("'")
          unless x_string_solved_letters.include?("'")
            x_string_solved_letters << "'"
          end
          #pp x_string_solved_letters.remove_all_without("'", x.index("'"))
        end
        #if x_string_solved_letters == []; return [] end
        add = true
        x_string_solved_letters.each do |letter|
          unless word.get_indices_of_letter(letter) == x_string.get_indices_of_letter(letter)
            add = false
          end
        end
        if add == true
          wordlist_narrowed << word
        end
      end
      unless x_string.has_repeater_chars?("X")
        wordlist_narrowed.reject!{|x| x.has_repeater_chars?(*x_string_solved_letters)}
      end
      wordlist_narrowed.remove_all_with(solved_letters - x_string_solved_letters)
    end

    def self.match_likely_repeaters(x_string, likely_words, *solved_letters)
      wordlist_narrowed = likely_words.reject{|word| word.get_repeater_chars == []}
      x_string_indices = x_string.get_indices_of_repeaters('X')
      list = []
      likely_words.each do |y|
        if x_string_indices ==  y.get_indices_of_repeaters
          list << y
        end
        # if list.length > 15
        #    return list.length.to_s
        # end
      end
      if x_string.chars.reject{|char| char.is_upper?}.length == 0
        return list.remove_all_with(*solved_letters)
      else
        return match_likely_with_solved_letters(x_string, list, *solved_letters)
      end
    end



    #cows isn't in our dictionary that returns with POS, but cow is. Given cows,
    #it will return a similar word that's in the dictionary: cow. If asked, it will also return
    #what made cows different from cow, ie it was plural.


  end
