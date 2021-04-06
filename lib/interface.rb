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
      entity_options = ["users", "tickets", "organizations"]
      puts "\nWhich entity would you like to search? Select a number:\n\n"
      entity_options.each_with_index { |option, i| puts "  #{i+1}) #{option.capitalize}" }
      puts "\n"

      if entity_id = get_input(blank_allowed: false)
        @entity = entity_options[entity_id.to_i - 1]
      end
      input_loop
    end

    if !@field
      print "\nEnter the field in '#{@entity.capitalize}' you'd like to search: "
      @field = get_input(blank_allowed: false)
      input_loop
    end

    if !@search_term
      print "\nEnter your search term (leave blank to search for empty values): "
      @search_term = get_input(blank_allowed: true)
      input_loop unless @search_term

      searcher = Searcher.new(@search_index, @data, @entity, @field, @search_term)
      search_results = searcher.call
      display_search_results(search_results)

      # Clear user set values and start again
      @entity, @field, @search_term = nil
      input_loop
    end
  end

  def display_introduction
    puts "\nWelcome to Zendesk Search!\n"
  end

  def display_help
    puts "\nAvailable commands to use at anytime:\n\n"
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

  def display_search_results(search_results)
    if search_results.empty?
      puts "\nNo results found"
      return
    end
    puts "\nFound #{search_results.count} result#{search_results.count > 1 ? "s" : ""}:\n\n"
    search_results.each do |result|
      result.each do |key, value|
        puts key.ljust(30) + value.to_s
      end
      puts "\n\n"
    end
  end

  def get_input(blank_allowed: false)
    input = gets.chomp
    if input == "" && !blank_allowed
      puts "\n ! You must enter a value here !"
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