require 'rubygems'
require 'require_all'
# require './lib/cryp_solver/structs/Probability.rb'
require_rel 'cryp_solver'
require_relative 'cryp_maker.rb'

if __FILE__ == $0
  require_relative 'solve_many.rb'
end




require_relative "cryp_solver.rb"

def c_solve(text)
  t1 = CrypTracker.new(string: text)
  t1.solve
  t1.solution
end

def solve_me_a_cgram
  puts "Enter a cryptogram! Must be more than 10 characters, no double quotes,
or proper names unless attributed at the end such as --Hjwrt Wfds Lrth.\n"
  puts "Or... press enter and I'll solve one from my database.\n"
  puts "Or... enter 'm' and then some text, and I'll make a cryptogram to solve."


  cgram_s = gets.chomp
  if cgram_s == 'm'
    cgram_s = make_gram_for_user
    puts "\n...Now solving...\n"
  end

  if cgram_s.length < 10
    cgram_s = Cryp_Store::CRYP_ARR.sample
  end
  t1 = CrypTracker.new(string: cgram_s)
  t1.solve(:print)

  puts "SOLUTION:"
  p t1.solution
end


if __FILE__ == $0
  solve_me_a_cgram
end
