require "byebug"
require "json"

# Load users, tickets and organizations into Ruby.
# Then build an inverted index, which will have a structure something like this:
# search_index = {
#   users: {
#     {
#       _id: {
#         1: users[0]
#         2: users[1]
#       },
#       url: {
#         "http://initech.zendesk.com/api/v2/users/1.json": users[0]
#       }
#     }
#   }
# }

def build_index
  @data = {}
  file_names = ["users.json", "tickets.json", "organizations.json"]
  file_names.each do |file_name|
    file = File.read("data/" + file_name)
    @data[file_name.gsub(".json", "").to_sym] = JSON.parse(file)
  end

  # Can we initialise the inverted index using the data hash above instead?
  inverted_index = {
    users: {
      _id: {}, url: {}, external_id: {}, name: {}, alias: {}, created_at: {}, active: {}, verified: {}, shared: {}, locale: {}, timezone: {}, last_login_at: {}, email: {}, phone: {}, signature: {}, organization_id: {}, tags: {}, suspended: {}, role: {}
    }, 
    tickets: {
      _id: {}, url: {}, external_id: {}, created_at: {}, type: {}, subject: {}, description: {}, priority: {}, status: {}, submitter_id: {}, assignee_id: {}, organization_id: {}, tags: {}, has_incidents: {}, due_at: {}, via: {}
    },
    organizations: {
      _id: {}, url: {}, external_id: {}, name: {}, domain_names: {}, created_at: {}, details: {}, shared_tickets: {}, tags: {}
    }
  }

  # Build out our inverted index here
  # I think this needs to be recursive and follow the structure of the data input
  @data.keys.each do |key|
    @data[key].each_with_index do |item, i|
      inverted_index[key].keys.each do |index_key|
        inverted_index[key][index_key][item[index_key.to_s]] = i
      end
    end
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
  @data.keys.each do |key|
    puts key
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

def input_loop
  if !@entity
    puts "\nReady to search? y/n\n"
    exit if gets.chomp.downcase != "y"

    entity_options = ["users", "tickets", "organizations"]
    puts "\nWhich entity would you like to search?"
    puts "\nSelect a number:\n"
    entity_options.each_with_index { |option, i| puts "#{i+1}) #{option.capitalize}" }
    @entity = get_input(blank_allowed: false)
    puts "\nSearching #{entity_options[@entity.to_i]}..." if @entity
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
    input_loop
  end
end

build_index
display_introduction
display_help
input_loop
