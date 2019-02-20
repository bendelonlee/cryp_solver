require_relative "../../modules/Vocab.rb"
require_relative "../../modules/Grammar.rb"
require_relative "../../modules/XWordSearch.rb"

require_rel "../Trackers"
require "pry"


class DataObject
  def print_attributes(attrs)
    list = []
    if attrs == []
      return nil
    elsif attrs.is_a? Array
      attrs.each do |a|
        list << self.public_send(a).to_s
      end
    elsif attrs.is_a? Symbol
      print self.public_send(attrs)
      return
    end
    print self.public_send(list).to_uncluttered_string_limited(40)
  end
  def to_hash
    hash = {}
    self.instance_variables.each do |var|
    end
  end

end

class LetterData < DataObject
  attr_accessor :cryp_text, :name, :locations, :prev_letter, :next_letter
  attr_accessor :solution, :likely_solutions, :likely_not, :freq, :perc_freq

  def initialize(cryp_text, info={})
    @freq = 1
    @name = cryp_text
    @cryp_text = cryp_text
    @locations = info[:locations]
    @prev_letter = info[:prev_letter]
    @likely_not = []
    @solution = nil
  end

  def freq_locs

    locations_with_freq = {}
    locations.each do |location|
      locations_with_freq.merge!({location => 1}) {|key, oldval, newval| oldval + newval}
    end

    return locations_with_freq.select{|k,v| v > 1}

  end




end


class UnigramData < DataObject
  attr_accessor :cryp_text, :x_string, :likely_solutions, :solution, :progress
  attr_accessor :parts_of_speech_not,  :parts_of_speech_likely, :part_of_speech
  attr_accessor :abs_location, :rel_location, :punctuation, :freq, :name, :commonness
  attr_accessor :length, :prev_word, :next_word, :word_or_name, :attribution, :excepted

end

class WordData < UnigramData

  def initialize(cryp_text, hash ={})
    @freq = 1
    @cryp_text = cryp_text
    @name = cryp_text
    @x_string = hash[:x_string]
    @length = cryp_text.length
    @abs_location = [hash[:abs_location]]
    @rel_location = [hash[:rel_location]]
    @prev_word = [hash[:prev_word]]
    @attribution = [hash[:attribution]]
    @word_or_name = hash[:word_or_name]
    @parts_of_speech_not = []
    @parts_of_speech_likely = []
    @progress = 0
    if @name.index(/\d/)
      @excepted = true
    end
  end

  def sync_progress
    if !x_string.include?("X")
      if @likely_solutions && @likely_solutions.include?(self.x_string)
        @progress = :SOLVED
        @commonness = :COMMON
        @solution = x_string
        @part_of_speech = x_string.part_of_speech

      elsif  Vocab::SO_MANY_WORDS.include?(self.x_string)
        @progress = :SOLVED
        @commonness = :UNCOMMON
      else
        @progress = :FILLED
      end

    else
      if @commonness == :WEIRD
        @progress = 0
      else
        num_solved = x_string.scan(/[a-z]/).length
        @progress = 100 * num_solved / x_string.length
      end
    end
  end

  def lookup_likely_words
    return :initial if name_initial?
    case self.word_or_name
    when :word
      @likely_solutions = Vocab.get_likely_wordlist_from_x_string(x_string)
    when :name
      @likely_solutions =  Vocab.name_search(x_string)
    end
  end

  def name_initial?
    if @length == 1 && @word_or_name == :name
      return true
    end
  end

  def update_likely_words(solved_letters)
    if likely_solutions && !excepted
      @likely_solutions = XWordSearch.select_words(x_string, likely_solutions, *solved_letters)
      if @likely_solutions == [] && ![:WEIRD,:UNCOMMON].include?(@commonness) && @word_or_name == :word
        if @x_string.include?("'")
          @commonness = :WEIRD
        else
          @commonness = :UNCOMMON
          @likely_solutions = XWordSearch.select_words(x_string, Vocab::SO_MANY_WORDS, *solved_letters)
          if @likely_solutions == []
            @commonness = :WEIRD
          end
        end
      end
    end
  end


end

class PronounData < UnigramData
  attr_accessor :type


end
