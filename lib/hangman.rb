class Hangman
  attr_accessor :word, :player_array, :incorrect_guesses, :wrong_answers
  attr_reader :dictionary

  def initialize
    @word = ""
    @player_array = []
    @incorrect_guesses = []
    @wrong_answers = 0;
    @file = File.open("5desk.txt", "r")
    @dictionary = @file.readlines.map(&:chomp)
    @file.close
  end

  def setup_game
    while true
      @word = dictionary[rand(0..dictionary.length)].downcase
      if word.length.between?(5, 12)
        break
      end
    end
    puts "Word has been generated!"
    define_player_array()
    start()
  end
  
  def define_player_array
    word.split("").each do |element|
      player_array << "_"
    end
  end

  def start
    letter = ""
    print_word()

    until wrong_answers == 6 || check_win()
      while true
        letter = input_letter()
        if check_input(letter).empty?
          break
        end
        puts check_input(letter)
        print_word(letter)
      end

      unless word.include?(letter)
        wrong_answers += 1
        incorrect_guesses << letter
        puts "Incorrect! Attempts remaining: #{6 - wrong_answers}\n"
      end
      print_word(letter)
    end

    if wrong_answers == 6
      puts "You failed to guess the word. Word was #{word}"
      puts
    else
      puts "You guessed the word!"
      puts
    end
  end
  
  def check_input(letter)
    if letter.split("").length > 1
      return "Enter only one letter!\n"
    elsif letter_present?(incorrect_guesses, letter) || letter_present?(player_array, letter)
      return "Already guessed that letter!\n"
    end
    return ""
  end

  def input_letter
    print "\nEnter a letter: "
    letter = gets.chomp.downcase
    letter
  end

  def check_win
    word.split("") == player_array
  end

  def letter_present?(array, letter)
    array.join("").include?(letter)
  end

  def print_word(letter="")
    puts "_______________________________________________________________________________________________"
    puts
    if letter.empty?
      print "#{player_array.join(" ")}\t\t\t\t\t\t"
      puts "Incorrect guesses: #{incorrect_guesses.join(" ")}"
      return
    end

    if word.include?(letter)
      word.split("").each_with_index do |element, idx|
        if element.eql?(letter)
          player_array[idx] = letter
        end
      end
    end
    print "#{player_array.join(" ")}\t\t\t\t\t\t"
    puts "Incorrect guesses: #{incorrect_guesses.join(" ")}"
  end
end

Hangman.new.setup_game