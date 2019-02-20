require 'yaml'

original = YAML.load_file("./lib/word_lists/words_with_freq.yaml", "r")

changed = original.map{|k,v| [k.downcase, v]}.to_h

File.open("./lib/word_lists/words_w_freq.yml", "w") {|file| file.write(changed.to_yaml)}
