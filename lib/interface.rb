require_relative "searcher"

class Interface
  def initialize(data, search_index)
    @data = data
    @search_index = search_index
    @entity, @field, @search_term = nil
  end

  def call
    display_introduction
    display_help
    input_loop
  end

  private

  def input_loop
    if !@entity
      puts "\nReady to search? y/n\n"
      exit if gets.chomp.downcase != "y"

      entity_options = ["users", "tickets", "organizations"]
      puts "\nWhich entity would you like to search?"
      puts "\nSelect a number:\n"
      entity_options.each_with_index { |option, i| puts "#{i+1}) #{option.capitalize}" }

      entity_id = get_input(blank_allowed: false)
      @entity = entity_options[entity_id.to_i - 1]
      puts "\nSearching #{@entity}..."
      input_loop
    end

    if !@field
      puts "\nEnter the field you'd like to search:\n"
      @field = get_input(blank_allowed: false)
      input_loop
    end

    if !@search_term
      puts "\nEnter your search term:\n"
      @search_term = get_input(blank_allowed: true)
      searcher = Searcher.new(@search_index, @data, @entity, @field, @search_term)
      searcher.call
      input_loop
    end
  end

  def display_introduction
    puts "\nWelcome to Zendesk Search!\n"
  end

  def display_help
    puts "\nAvailable commands:\n\n"
    puts "      \\exit — exits"
    puts "      \\restart — starts again"
    puts "      \\fields — views a list searchable fields"
    puts "      \\help — see these commands again\n"
  end

  def display_fields
    @data.keys.each do |entity_name|
      puts "\n#{entity_name.capitalize}:"
      puts "\n  #{@data[entity_name].first.keys.join(", ")}"
    end
  end

  def get_input(blank_allowed: false)
    input = gets.chomp
    if input == "" && !blank_allowed
      puts "! You must enter a value here !"
      return nil
    end

    case input
    when "\\exit"
      exit
    when "\\help"
      display_help
      nil
    when "\\fields"
      display_fields
      nil
    when "\\restart"
      @entity, @field, @search_term = nil
    else
      input
    end
  end
end