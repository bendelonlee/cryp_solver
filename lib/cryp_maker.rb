require "pry"
def make_cgram(text)
  alphabet = ("a".."z").to_a
  cipherbet = alphabet.clone.shuffle_sameless
  cipher = alphabet.zip(cipherbet).to_h

  cryptext = text.downcase.chars.map do |c|
    if alphabet.include?(c)
      cipher[c]
    else
      c
    end
  end
  return cryptext.join.upcase

end

class Array
  def sample_except(exceptions)
    self.reject{|x| exceptions.include?(x)}.sample
  end
  def shuffle_sameless
    old = self.clone
    shuffled = []
    self.each do |item|
      shuffled << old.sample_except([item] + shuffled)
    end
    if shuffled[-1] == nil
      s = shuffled.sample_except([nil])
      shuffled[-1] = s
      shuffled[shuffled.index(s)] = self[-1]
    end
    return shuffled
  end
end

def make_gram_for_user
  puts "Enter Text:"
  text = gets.chomp
  cryptext = make_cgram(text)
  puts "Cryptogram"
  puts cryptext
  return cryptext
end

if __FILE__ == $0
  make_gram_for_user
end
