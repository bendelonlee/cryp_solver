require_relative "cryp_maker.rb"
require_relative "cryp_solver.rb"
require "pp"
class Cryp_Store

  this_folder = File.expand_path(__dir__)

  quotes_to_test = File.open(this_folder + "/quotes_raw.txt", "r").read.delete('"')



  arr = quotes_to_test.scan(/[\w ,:;\.\!\"\'\?^[0-9]]*[" ]*[\n]* *--[A-Z][a-z]*[ .\w]*/)

  ORIGINALS = arr.map{|line| line.gsub("\n", " ").upcase}
  l = ORIGINALS.length
  CRYP_ARR = ORIGINALS.each_with_index.map { |line, i| make_cgram(line)}


end

def solve_many
  completeds = Cryp_Store::CRYP_ARR.map {|line| p c_solve(line)}

  solved_count = 0
  unsolved = []
  originals = Cryp_Store::ORIGINALS[3..11]

  completeds.each_with_index do |string, i|
    if string == originals[i]
      solved_count += 1
    else
      unsolved << string.similarity(originals[i])
    end
  end

  puts "#{(100 * solved_count/Cryp_Store::CRYP_ARR.length).to_s} percent completely solved."
  puts "Of those not completely solved, the average nearness to the correct solution was #{unsolved.average} percent"
end

if __FILE__ == $0
  solve_many
end

#finds names
# p quotes_to_test.scan(/--[A-Z][a-z]*[ .\w]*/).length
