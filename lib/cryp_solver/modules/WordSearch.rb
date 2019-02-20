require_rel "basics"
require_relative "Vocab.rb"

module WordSearch

#returns with an integer, 0-100 of it's likelihood of being a word
  def self.word_likelihood(string)
    if Vocab::ALL_COMMON_FORMS.include?(string.delete(".,-?!:;\"\'"))
      return 100
    elsif
      Vocab::SO_MANY_WORDS.include?(string)
      return 99
    else
      return 0
    end
  end

  def self.common_word?(string)
    if Vocab::ALL_COMMON_FORMS.include?(string.delete(".,-?!:;\"\'"))
      return true
    else
      return false
    end
  end

end
