

module GuessEval

  def regrettable_guess

    self.guesses_taken.reverse.each do |gs|
      unless self.bad_guesses.include?(gs)
        return gs
      end
    end

    return nil
  end


  def best_guess(arr_of_guesses = self.all.values - bad_guesses )
    arr_of_guesses.flatten.return_object_with(:adjusted_goodness, best_score(arr_of_guesses))
  end

  def best_guess_plus(arr_of_guesses = self.all.values - bad_guesses, options = {})
    bg = best_guess(arr_of_guesses)
    nbg = next_best_guess(arr_of_guesses)
    closeness = best_score(arr_of_guesses) - next_best_score(arr_of_guesses)

    @close_guesses[closeness] = nbg
    return {best_guess: bg, closeness: closeness, next_best_guess: nbg}
  end

  private
  def next_best_score(a_of_g)
    best_score(a_of_g - best_guess(a_of_g))
  end

  def next_best_guess(a_of_g)
    best_guess(a_of_g - best_guess(a_of_g))
  end
  #need a better nbg

  def best_score(a_of_g)
    best_score = a_of_g.flatten.return_objects_with(:attempts, 0).max_attribute(:adjusted_goodness)
  end
  public

  def self.doubt_to_subtract(d_gs, arr_strings)
    dts ={}
    d_gs.each do |g|
      i = arr_strings.index(g.solution)
      if i
        dts[i] = g.doubt
      end
    end
    dts
  end

  def self.apply_doubt(d_gs, normed_arr, arr_strings)
    doubt_to_subtract(d_gs, arr_strings).each do |index, doubt|
      normed_arr[index] /= (doubt/5)
    end
  end

  def self.goodness_by_freq(arr_of_strings, options = {})
    d_gs = options[:doubted_guesses]

    word_or_name = options[:word_or_name] || :word
    arr_of_freq = arr_of_strings.map {|s| s.freq(word_or_name: word_or_name)}
    arr_of_goodness = arr_of_freq.normalize(100)
    if d_gs && d_gs != []
      apply_doubt(d_gs, arr_of_goodness, arr_of_strings)
      arr_of_goodness = arr_of_goodness.normalize(100)
    end

    # binding.pry if arr_of_strings.include?("fears")
    return arr_of_goodness
  end





end
