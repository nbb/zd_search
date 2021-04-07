require "json"
require_relative "lib/build_index"
require_relative "lib/interface"

json_files = [
  {
    entity_name: "users",
    relative_path: "data/users.json"
  },
  {
    entity_name: "tickets",
    relative_path: "data/tickets.json"
  },
  {
    entity_name: "organizations",
    relative_path: "data/organizations.json"
  },
]

data = {}
json_files.each do |json_file|
  raise "The #{json_file[:relative_path]} file is missing" if !File.exist?(json_file[:relative_path])
  file = File.read(json_file[:relative_path])
  begin
    data[json_file[:entity_name]] = JSON.parse(file)
  rescue JSON::ParserError => e
    puts "\nThere was a problem parsing the #{json_file[:relative_path]} file. Please check it's valid. \n\n"
    puts e.message
    puts e.backtrace
    exit
  end
end

build_index = BuildIndex.new(data)
indexed_data = build_index.call

interface = Interface.new(data, indexed_data)
interface.call
