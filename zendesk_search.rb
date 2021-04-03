require "byebug"
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
  file = File.read(json_file[:relative_path])
  data[json_file[:entity_name]] = JSON.parse(file)
end

build_index = BuildIndex.new(data)
indexed_data = build_index.call

interface = Interface.new(data, indexed_data)
interface.call
