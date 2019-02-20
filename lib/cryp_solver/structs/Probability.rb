#Used to handle predictions that can't be summed up by an Equivalency. For example,
#it is highly probable that the word following a pronoun is not a pronoun.
Probability = Struct.new(:fact, :likelyhood)
