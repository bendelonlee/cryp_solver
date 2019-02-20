require "rubygems"
require "require_all"

require_rel "../../modules/basics"

require_relative "../../modules/Vocab.rb"
require_relative "../../modules/XWordSearch.rb"
require_relative "../DataObjects/DataObjects.rb"
require_relative "../Guess.rb"


require "pp"







class Tracker


  def print_with(args={})
    if args.is_a?(Hash) && args[:atts]
      atts = args[:atts]
      att_of_att = args[:att_of_att] || att_of_att = {}
      limit = args[:limit] || limit = 35
    else
      atts = args
      limit = 35
    end



    self.all.values.each do |dataob|
      if dataob.is_a? Array
        dataob.each do |real_dataob|
          print_dataobject(real_dataob, atts, limit, array = true)
          puts "-"
        end
      else

        print_dataobject(dataob, atts, limit)
        puts "-"

      end
    end
    return nil
  end
  alias :pw :print_with

  def print_dataobject(dataob, atts, limit, array = false)

    atts.each_with_index do |att, i|
      realat = dataob.public_send(att)
      if realat.is_a? DataObject
        print "#{realat.name.to_s}"
      else
        if realat.is_a?(Array) || realat.is_a?(Hash)
          printlist = realat.to_uncluttered_string_limited(limit)
          print "#{printlist}"
          max_length = limit + 3
          num_spaces = max_length - printlist.length + 2
        else
          print "#{realat.to_s}"
          if [String, Symbol, Integer, Float, NilClass].include?(realat.class)
            if array == true
              max_length = self.all.values.flatten.list_attribute(att, :to_s).max_attribute(:length)
            else
              if self.all.values.list_attribute(att).any?{|object| [Array, Hash].include?(object.class) }
                max_length = limit + 2
              else
                max_length = self.all.values.list_attribute(att, :to_s).max_attribute(:length)
              end
            end
          end

          num_spaces = max_length - realat.to_s.length + 2
          binding.pry if num_spaces > 1000
        end
      end
      if i == 0
        print ": "
      elsif i < atts.length - 1
        print "; "
      end

      print " " * num_spaces
      #print "#{x.x_string.d}"
    end
  end
end





class LetterTracker < Tracker
  attr_accessor :all

  def cipher
    @all.map{ |k, v| [k, v.solution]}.to_h
  end

  def symplify_locs
    @all.values.each do |letterdata|
      sym_locs = []
      letterdata.locations.each do|location|
        from_front = location[0]
        from_back = location[1]
        if from_front == 0
          if from_back == -1
            sym_locs << :loner
          elsif from_back == -2
            sym_locs << :one_of2
          elsif from_back == -3
            sym_locs << :one_of3
          elsif from_back == -4
            sym_locs << :one_of4
          elsif from_back < -4
            sym_locs << :first
          end
        elsif from_front == 1
          if from_back == -1
            sym_locs << :last_of2
          elsif from_back == -2
            sym_locs << :mid_of3
          elsif from_back < -2
            sym_locs << :second
          end
        elsif from_front == 2
          if from_back == -1
            sym_locs << :last_of3
          elsif from_back == -2
            sym_locs << :third
          end
        elsif from_back == -1
          sym_locs << :last
        else
          sym_locs << :mid
        end
      end

      letterdata.locations = sym_locs
    end
  end

  def letter_count

    return @all.values.list_attribute(:freq).inject do |sum, n|
      n + sum
    end
  end

  def set_perc_freqs(lc)
    @all.values.each do |letterdata|
      letterdata.perc_freq = 10000 * letterdata.freq / lc / 100.0
    end
  end

  def initialize(string)

    array = string.split_into_dataObjects(by: :letter)
    @all = (array.map { |x| [x.name, x]}).to_h
    symplify_locs
    set_perc_freqs(letter_count)
    tlw_smarts
  end

  def letter_solutions
    @all.values.list_attribute(:solution).compact
  end










  module LetterSmarts
    #two_letter_word_smarts
    def tlw_smarts
      @all.values.each do |letterdata|
        if letterdata.freq_locs.include?(:one_of2)
          letterdata.likely_not += ("a".."z").to_a - Vocab::TWO_LETTER_1

        end
        if letterdata.freq_locs.include?(:last_of2)
          letterdata.likely_not += ("a".."z").to_a - Vocab::TWO_LETTER_2
        end
      end
    end
  end

  include LetterSmarts
end





class CrypTracker < Tracker
  attr_accessor :u_t, :l_t, :g_t, :u_t_master, :l_t_master, :id, :progress, :original_string, :guesses, :round, :all_rounds

  #@@l_t_master = LetterTracker.new()
  #@@u_t_master = []

  def initialize(args={ut:nil, lt:nil, string:nil, round:0})
    rnum = args[:round] || 0
    if args[:string]
      @original_string = args[:string]
      @u_t = UnigramTracker.new(args[:string])
      @l_t = LetterTracker.new(args[:string])
      @g_t = GuessTracker.new()
      @g_t.gather_good_guesses(self)
      first_word_bonus
      @all_rounds = []
      @best_progress = 0
      @best_round = :NONE

    elsif args[:ut]
      @u_t = args[:ut]
    end
    if args[:lt]
      @l_t = args[:lt]
    end
    if args[:gt]
      @g_t = args[:gt]
    end
    @round = rnum


  end

  def stuckness
    u_t.weird_count ** 2 * (u_t.uncommon_count + 1) * 70 + u_t.uncommon_count * 20 - u_t.progress
  end


  def new_round
    @all_rounds[@round] = Marshal.dump([@u_t, @l_t, @g_t.all])
    if @u_t.progress > @best_progress
      @best_round = @round
      @best_progress = @u_t.progress
    end
    @round += 1
    @g_t.round = @round
  end

  def reset_to_round(rnum)
    oldround = Marshal.load(@all_rounds[rnum])
    @u_t = oldround[0]
    @l_t = oldround[1]
    @g_t.all = oldround[2]
    nil
  end




  def apply_eq(equiv)

    case equiv.word_or_letter
    when :word

      equiv.cryp_text.chars.each_with_index do |char, i|
        apply_eq(Equivalency.new(char, equiv.solution[i], :letter)) unless char == "'"
      end
    when :letter
      binding.pry if l_t.all[equiv.cryp_text] == nil
      l_t.all[equiv.cryp_text].solution = equiv.solution
      u_t.all.values.each do |worddata|
        inds = worddata.cryp_text.get_indices_of_letter(equiv.cryp_text)
        worddata.x_string = worddata.x_string.insert_at_indices(equiv.solution, inds)
      end
    end
  end


  def update_likely_words
    u_t.all.values.each do |word|
      word.update_likely_words(l_t.letter_solutions)
      word.sync_progress
    end
  end

  def update_guesses
    @g_t.gather_good_guesses(self)
    first_word_bonus
  end

  def delete_bad_guesses_from_likely_words
    bad_cs = g_t.bad_guesses.list_attribute(:cryp_text)
    bad_ss = g_t.bad_guesses.list_attribute(:solution)
    @u_t.all.each do |k,word|
      if word.likely_solutions
        word.likely_solutions.delete_if{|sol| bad_ss.index(sol) && bad_cs[bad_ss.index(sol)] == word.cryp_text }
      end
    end
  end

  def solution
    sol = original_string.downcase.chars.map { |char| l_t.cipher[char] ? l_t.cipher[char].upcase : char }.join
  end


  module Bonus

    FIRST_WORD_BONUSES = {"the" => 50, "i" => 50}
    def first_word_bonus

      @g_t.all.values.each do |guesses|
        guesses.each do |guess|
          word = @u_t.all[guess.cryp_text]
          if word.rel_location.include?(0) && word.word_or_name == :word

            if FIRST_WORD_BONUSES.keys.include?(guess.solution)
              # binding.pry
              guess.bonuses[:first_word] = FIRST_WORD_BONUSES[guess.solution]
            end
          end
        end
      end
    end
  end
  include Bonus

  # include Restrospect

  module CrypSolver

    def implement_best_guess
      binding.pry if g_t.best_guess == nil
      if g_t.best_guess
        implement(g_t.best_guess)
      else
        return :stuck
      end
    end
    def implement(guess)
      c_g = @g_t.current_guess
      if c_g
        guess.parent = c_g.round
        guess.depth = c_g.depth + 1
        c_g.num_children += 1
      end
      @g_t.guesses_taken << guess
      apply_eq(guess.eq)
      update_likely_words
      g_t.gather_good_guesses(self)
      first_word_bonus
    end

    def reach_back_for_undoubted_round(bad_guess)
      parent = @g_t.get_parent(bad_guess)
      if parent && parent.doubt > 30
        reach_back_for_undoubted_round(parent)
      else
        return bad_guess.round
      end
    end



    def go_back_wiser(bad_guess)
      binding.pry if bad_guess.is_a?(Array)
      r = reach_back_for_undoubted_round(bad_guess)
      reset_to_round(r)
      # binding.pry
      # @g_t.bad_guesses -= @g_t.get_descendants(bad_guess)
      @g_t.bad_guesses << bad_guess
      self.delete_bad_guesses_from_likely_words
      @g_t.gather_good_guesses(self)
      first_word_bonus


    end

    def guess_until_stuck(*options)
      if options.include?(:print)
        to_print = true
      else
        to_print = false
      end
      loop do
        # t1.g_t.print_with(atts:[:cryp_text, :solution, :goodness])
        p self.solution if to_print
        puts "" if to_print
        if to_print == :verbose
          self.g_t.print_with(atts:[:cryp_text, :solution, :goodness])
          self.u_t.print_with(atts:[:name, :x_string, :likely_solutions, :commonness])
        end
        self.new_round


        # binding.pry
        #binding.pry if self.stuckness > 50

        if self.stuckness > 50 || g_t.best_guess == nil
          r_g = @g_t.regrettable_guess
          @g_t.raise_doubt(r_g)
          return r_g
        end
        if self.implement_best_guess == :stuck
          return @g_t.regrettable_guess
        end


        # t1.u_t.print_with(atts:[:name, :x_string, :likely_solutions, :word_or_name])
        # break if count == 1
      end
    end


    def solve(*options)
      loop do
        bad_guess = self.guess_until_stuck(*options)
        unless bad_guess
          # binding.pry
          break
        end
        if options.include?(:print)
          puts "\nGuessing #{bad_guess.solution.upcase} was a dead end. I'm going back.\n"
        end

        if @u_t.progress == 100
          break
        end
        if @round > 40
          reset_to_round(@best_round)
          # binding.pry
          break
        end
        go_back_wiser(bad_guess)

      end
    end
  end
  include CrypSolver

end












class UnigramTracker < Tracker
  attr_accessor :all, :progress, :names, :words, :name_initial_count

  def initialize(cgram_s)
    array = cgram_s.split_into_dataObjects
    @all = (array.map { |x| [x.name, x]}).to_h
    @names = @all.select {|k,v| v.word_or_name == :name }
    @words = @all.select {|k,v| v.word_or_name == :word }

    @name_initial_count = @all.values.select { |word| word.name_initial? }.length
    self.lookup_all_likely_words
  end

  def lookup_all_likely_words
    self.all.values.each do |word|
      word.lookup_likely_words
    end
  end

  def progress
    list = @all.values.list_attribute(:progress)
    list.map! do |item|
      case item
      when :SOLVED
        100
      when :FILLED
        0
      else
        item
      end
    end
    list.inject(0,:+) / (list.length - @name_initial_count)
  end

  def weird_count
    @all.values.count_obs_with(:commonness, :WEIRD)
  end

  def uncommon_count
    @all.values.count_obs_with(:commonness, :UNCOMMON)
  end

end



class GuessTracker < Tracker
  attr_accessor :all, :close_guesses, :round, :bad_guesses, :guesses_taken
  def initialize
    @all = {}
    @literally_all
    @close_guesses
    @round = 0
    @bad_guesses = []
    @guesses_taken = []
    @num_children = []
  end

  def closest_guess

  end



  def current_guess
    good_guesses = @guesses_taken - @bad_guesses
    good_guesses[-1]
  end

  #given a regrettable_guess, raises doubt about it's parent guesses.
  def raise_doubt(regrettable, amount = 10)
    amount = 1 if amount < 1
    p_g = get_parent(regrettable)
    return unless p_g
    p_g.doubt += amount
    if p_g.parent
      raise_doubt(p_g, amount - 1)
    end
  end

  def doubted_guesses
    @guesses_taken.select{|g| g.doubt > 30}
  end

  def get_parent(guess)
    return nil unless guess
    @guesses_taken.row(:round, guess.parent)
  end

  def get_children(guess)
    @guesses_taken.select {|g| get_parent(g) == guess}
  end

  def get_descendants(guess)
    desc = get_children(guess)
    return desc if desc == []
    desc.each do |g|
      if g.num_children == 0
        next
      else
        desc += get_descendants(g)
      end
    end

    return desc
  end



  module Generate

    def gather_good_guesses(ctracker)
      @all = {}
      a = letter_guesses(ctracker.l_t)
      b = get_word_guesses(ctracker)
      guesses_to_add = b
      guesses_to_add.each do |guess|
        unless @all[guess.cryp_text]
          @all[guess.cryp_text] = [guess]
        else
          @all.merge({guess.cryp_text => guess}){|key, oldv, newv| oldv << newv}
        end
      end
    end

    def get_word_guesses(ctracker)
      b = word_guesses(ctracker.u_t.all.values)
    end

    def bad_guesses_for_word(word)
      bad_guesses.return_objects_with(:cryp_text, word.name)
    end

    def bad_solutions_for_word(word)
      bad_guesses_for_word(word).la(:solution)
    end

    def doubted_guesses_for_word(word)
      doubted_guesses.return_objects_with(:cryp_text, word.name)
    end

    def doubted_solutions_for_word(word)
      doubted_guesses_for_word(word).la(:solution)
    end

    private

    def word_guesses(arr_o_w)
      guesses = []
      arr_o_w.each do |word|
        if word.solution
          next
        elsif word.likely_solutions
          possible = word.likely_solutions - bad_solutions_for_word(word)
          num_poss = possible.length
        else
          num_poss = 0
        end
        if num_poss < 50 && num_poss > 0
          binding.pry if word.likely_solutions.include?(nil)
          goodness_arr = GuessEval.goodness_by_freq(word.likely_solutions, word_or_name: word.word_or_name, doubted_guesses: doubted_guesses_for_word(word))
          word.likely_solutions.each_with_index do |x, index|
            new_guess = Guess.new(:word, word.cryp_text, x, goodness_arr[index], @round)
            binding.pry if new_guess.goodness == nil
            guesses << new_guess if new_guess.goodness > 20
          end
        end
      end
      return guesses
    end

    def letter_guesses(ct)
    end

  end

  include GuessEval
  include Generate

end
