require "yaml"

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
    print "Type 'l' to load game or type any other key to start new game: "
    choice = gets.chomp.downcase
    if choice.eql?("l")
      game = load_game()
      unless game == nil
        game.start()
      else
        new_game()
      end
    else
      new_game()
    end
  end

  protected 

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
        @wrong_answers += 1
        incorrect_guesses << letter
        puts "Incorrect! Attempts remaining: #{6 - wrong_answers}\n"
      end
      print_word(letter)
    end

    if wrong_answers == 6
      puts "\nYou failed to guess the word. Word was #{word}"
    else
      puts "\nYou guessed the word!"
    end
    puts
  end
  
  private 

  def new_game
    while true
      @word = dictionary[rand(0..dictionary.length)].downcase
      if word.length.between?(5, 12)
        break
      end
    end
    puts "\nWord has been generated!"
    define_player_array()
    start()
  end

  def define_player_array
    word.split("").each do |element|
      player_array << "_"
    end
  end
  
  def check_input(letter)
    if letter.eql?("save")
      save_game()
      exit(0)
    elsif letter.split("").length > 1
      return "Enter only one letter!\n"
    elsif letter_present?(incorrect_guesses, letter) || letter_present?(player_array, letter)
      return "Already guessed that letter!\n"
    end
    return ""
  end

  def save_game
    Dir.mkdir('save_files') unless Dir.exist?('save_files')
    print "Enter name of the save file: "
    filename = check_filename(gets.chomp)
    yaml = YAML::dump(self)
    game_file = File.new("save_files/#{filename}", "w")
    game_file.write(yaml)
  end
  
  def check_filename(filename)
    if Dir.children("save_files").include?(filename)
      print "#{filename} already exists. Do you want to override it? ('y' or 'n'): "
      case gets.chomp.downcase
      when "n" then 
        print "Enter a different name (entering the same name again will override the file): "
        filename = gets.chomp
      end
    end
    return filename
  end

  def print_files
    Dir.open("save_files").each_child do |file|
      puts " - #{file}"
    end
  end

  def dir_valid?
    Dir.exist?("save_files") && !Dir.empty?("save_files")
  end

  def load_game
    if dir_valid?()
      puts "\nType the name of the file you want to open:"
      print_files()
      filename = gets.chomp
      if Dir.children("save_files").include?(filename)
        game_file = File.open("save_files/#{filename}", "r")
        yaml = game_file.read
        YAML::load(yaml)
      else
        puts "File does not exist"
        return nil
      end
    else
      puts "No game saves are present"
      return nil
    end
  end

  def input_letter
    print "\nEnter a letter or type 'save' to save and exit game: "
    letter = gets.chomp.downcase
    return letter
  end

  def check_win
    word.split("") == player_array
  end

  def letter_present?(array, letter)
    array.join("").include?(letter)
  end

  def print_word(letter="")
    puts "______________________________________________________________________________________________________________________"
    puts
    if letter.empty?
      print "#{player_array.join(" ")}\t\t\t\t\t\t\t"
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
    print "#{player_array.join(" ")}\t\t\t\t\t\t\t"
    puts "Incorrect guesses: #{incorrect_guesses.join(" ")}"
  end
end

Hangman.new.setup_game