require_relative "../classes/Guess.rb"
require_rel "../classes/DataObjects"

module Deduction
  def find_all_must_letters(wt)

  end

  def self.find_must_letters(word)
    indeces_of_unsolved = word.x_string.get_indices_of_uppers
    list_of_strings = word.likely_solutions
    indeces_of_unsolved.each do |i|
      add = true
      letter = nil
      list_of_strings.each do |str|
        if letter && letter != str[i]
          add = false
          next
        end
        letter = str[i]
      end
      if add == false
        next
      else
        binding.pry
        #i don't think this ever runs
        arr << Guess.new(:letter, word.cryp_text[i], letter, 90)
      end
    end
    return arr
  end

  #Make many consanants in a row smell fishy even for unknown words
end
