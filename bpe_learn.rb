#! /usr/bin/env ruby

EOW = [0]

# "vocab" is a list of tokens.
# "tokens" are arrays of bytes.
# "words" are lists of tokens.
vocab = (0..255).map {|i| [i]}
words = Hash.new(0)
File.read(ARGV[0]).split(/(\W)/).each do |word|
  word.downcase!
  bytes = word.bytes
  next if bytes.length < 2
  tokens = word.bytes.map {|i| [i]}
  words[tokens] += 1
end

puts "#{words.keys.length} words."

token_pairs = Hash.new(0)
words.each do |word, count|
  word.each_cons(2) do |token_pair|
    token_pairs[token_pair] += count
  end
end
  
1000.times do
  max_token_pair = token_pairs.max_by {|k, v| v}[0]

  # Create new token and reduce words
  new_token = max_token_pair.flatten
  vocab.unshift(new_token)
  puts "Merged new token: #{new_token.inspect}, #{new_token.pack('U*')}"

  words.transform_keys! do |word|
    new_word = []
    updated = false
    word.each do |token|
      if token == max_token_pair[1] && new_word.last == max_token_pair[0]
        new_word.pop
        new_word.push(new_token)
        updated = true
      else
        new_word.push(token)
      end
    end

    if updated
      count = words[word]
      # subtract counts for tokens in this word before edit
      word.each_cons(2) do |token_pair|
        token_pairs[token_pair] -= count
      end

      # add counts for tokens in the new word
      new_word.each_cons(2) do |token_pair|
        token_pairs[token_pair] += count
      end
    end

    new_word
  end
end

vocab.sort_by!(&:length).reverse!

ARGV.clear

loop do
  print "tokenize: "
  input = gets.strip.bytes
  output = []
  while input.length > 0
    vocab.each do |token|
      if input.first(token.length) == token
        output.push(token)
        input.shift(token.length)
      end
    end
  end

  puts output.map {|token| token.pack("U*")}.inspect
end
