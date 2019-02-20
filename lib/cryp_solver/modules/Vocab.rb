require "rubygems"
require "require_all"
require "verbs"
require "pry"
require 'active_support/inflector'

require_rel "basics"
require_relative "XWordSearch.rb"
require "yaml"

class Vocab

  def self.set_up_dict_array(file_with_one_column)
    arr = File.readlines(file_with_one_column, "r").join.split("\n")
    arr.delete("")
    return arr
  end

  def self.set_up_dict_hash(file_with_two_columns, options ={})
    mult_values = options[mult_values] || :on
    arr = set_up_dict_array(file_with_two_columns)
    arr.map! do |x|
      #x.split("\t")
      x.downcase.split(" ")
    end
    case mult_values
    when :on
      return arr.group_by(&:first).map {|k,v|[k,v.map(&:last)]}.to_h
    when :off
      return arr.to_h
    end
    # next step, everytime where it expects a string make it handle array
    # step after that, have it fix the freq of words with multiple pos
  end

  this_folder = File.expand_path(__dir__)


  DICTIONARY = self.set_up_dict_hash(this_folder + "/../../word_lists/words_by_freq_with_pos.txt")
  WORDS_WITH_FREQ = self.set_up_dict_hash(this_folder + "/../../word_lists/words_with_freq.txt")
  #added: an, alert
  NOUNS = DICTIONARY.select {|k,v| v.include?('n')}.keys
  PLURALS = NOUNS.map{|noun| [noun, noun.pluralize]}.to_h
  VERBS = DICTIONARY.select{|k,v| v.include?('v')}.keys
  #fix above (then fix dictionaries made from this) so verbs that have more than one part of speech are included
  VERB_FORMS_HASH = YAML.load_file(this_folder + '/../../word_lists/verb_forms.yml')

  VERB_FORMS_ARRAY = VERB_FORMS_HASH.values.flatten.compact

  CONTRACTIONS = self.set_up_dict_hash(this_folder + "/../../word_lists/contractions.txt")
  CONTRACTION_VERBS = CONTRACTIONS.select {|k,v| v == 'v'}.keys

  ALL_COMMON_WITH_PART_OF_SPEECH = DICTIONARY.merge(CONTRACTIONS)

  ALL_COMMON_FORMS = DICTIONARY.keys + PLURALS.values + VERB_FORMS_ARRAY
  require 'pry'; binding.pry
  SO_MANY_WORDS = set_up_dict_array(this_folder + "/../../word_lists/big_list.txt")


  #
  FEMALE_NAMES = set_up_dict_hash(this_folder + "/../../word_lists/female_names_with_pf.txt")
  MALE_NAMES = set_up_dict_hash(this_folder + "/../../word_lists/male_names_with_pf.txt")
  SURNAMES = YAML.load_file(this_folder + "/../../word_lists/surnames_with_pf.yml")
  #  sum = 180904837
  nparr = %w(de, da)
  NAME_PARTS = nparr.zip([0.1] * nparr.length).to_h

  ALL_NAMES = FEMALE_NAMES.merge(MALE_NAMES) {|key, oldval, newval| oldval.to_f > newval.to_f ? oldval : newval}.merge(SURNAMES) {|key, oldval, newval| oldval.to_f > newval.to_f ? oldval : newval}.merge(NAME_PARTS)
  #

  FREQ_FIRST_LETTER = %w(t o a w b c d s f m r h i y e g l n p u j k)
  FREQ_SECOND_LETTER = %w(h o e i a u n r t)
  FREQ_THIRD_LETTER = %w(e s a r n i)
  FREQ_LAST_LETTER = %w(e s t d n r y f l o g h a k m p u w)
  FREQ_FOLLOW_E = %w(r s n d)
  FREQ_DIGRAPH = %w(th he an in er on re ed nd ha at en es of nt ea ti to io le is ou ar as de rt ve)
  FREQ_TRIGRAPH = %w(the and tha ent ion tio for nde has nce tis oft men)
  FREQ_DOUBLE = %w(ss ee tt ff ll mm oo)

  TWO_LETTER_WORDS = %w(of to in it is be as at so we he by or on do if me my up an go no us am)
  TWO_LETTER_1 = TWO_LETTER_WORDS.map { |word| word[0]}.uniq
  TWO_LETTER_2 = TWO_LETTER_WORDS.map { |word| word[1]}.uniq

LETTER_FREQ_PERC = {a: 8.17, b: 1.49, c: 2.78, d: 4.25, e: 12.70, f: 2.23, g: 2.02,
   h: 6.09, i: 6.97, j: 0.15, k: 0.77, l: 4.03, m: 2.41, n: 6.75, o: 7.51,
   p: 1.93, q: 0.10, r: 5.99, s: 6.33, t: 9.06, u: 2.76, v: 0.98, w: 2.36,
   x: 0.15, y: 1.97, z: 0.07}


  def self.get_replist(array)
    return array.get_words_with_repeats.map{|x| x.include?("'") || x.include?("-") ? nil : x }.compact
  end

  def self.get_likely_wordlist_from_x_string(x_string, options = {})
    if x_string.index(/\d/)
      return []
    end
    solved_letters = options[:solved_letters] || []
    word_list = options[:word_list] || Vocab::ALL_COMMON_FORMS
    #Deals with words with apostrophes be they contractions or...
    #puts "\n\n\nHERE\n\n\n" if x_string = "AiAX'X"

    if x_string.include?("'")
      poss = XWordSearch.select_words(x_string, Vocab::CONTRACTIONS.keys, *solved_letters)
      #...possessive nouns
      if /'[s]$/ =~ x_string || /'[X]$/ =~ x_string && !solved_letters.include?('s')
        potential_possesive_nouns = XWordSearch.select_words(x_string[0..-3], Vocab::NOUNS, *solved_letters)
        potential_possesive_nouns.map! {|n| n + "'s"}
        poss.concat(potential_possesive_nouns)
      end

    else
      poss = XWordSearch.select_words(x_string, Vocab::ALL_COMMON_FORMS, *solved_letters)

    end
    if poss
      if poss.length == 0
        likelylist = []
      else
        likelylist = poss
      end
    end
  end

  def self.name_search(x_string)
     XWordSearch.select_words(x_string, Vocab::ALL_NAMES.keys)


  end



end



class String

  def uncontract
    if self == "won't"
      return "will"
    end
    if self.include?("'")
      bits = self.split("'")
      bits.each do |bit|
        if Vocab::DICTIONARY[bit]
          return bit
        end
      end
    end
    if self.include?("n't")
      return self.sub("n't", "")
    elsif
    #for tis
    self[0] = "'"
      return self[2..-1]
    end
  end

  def base
    #does returns do
    if Vocab::DICTIONARY[self]
      return self
    end
    if ["'s", "s'"].include?(self[-2..-1])
      return self.delete_after(-3)
    end
    word = Vocab::PLURALS.key(self)
    return word if word
    Vocab::VERB_FORMS_HASH.each do |key, values|
      if values && values.include?(self)
        return key.to_s
      end
    end
    if Vocab::CONTRACTIONS.keys.include?(self)
      return self.uncontract.base
    end
  end




  def freq(options = {})
    w_n = options[:word_or_name] || :word

    binding.pry if self == nil
    if w_n == :word && Vocab::WORDS_WITH_FREQ[self.base] == nil
      return 0.000001
    end
    case w_n
    when :word
      if ["ain't"].include?(self)
        return 100000
      end
      # binding.pry if Vocab::WORDS_WITH_FREQ[self.base] == nil
      freq = Vocab::WORDS_WITH_FREQ[self.base][0].to_i
    when :name
      freq = Vocab::ALL_NAMES[self.downcase].to_f
    end
    return freq if freq
    return 0

  end
end
