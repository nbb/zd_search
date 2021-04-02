require "byebug"
require "json"
require_relative "lib/build_index"
require_relative "lib/interface"

build_index = BuildIndex.new
indexed_data = build_index.call

interface = Interface.new(indexed_data)
interface.call
