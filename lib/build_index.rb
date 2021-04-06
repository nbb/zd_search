# Builds an inverted index, outputting a structure like this:
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
class BuildIndex
  def initialize(data)
    @data = data
    @inverted_index = {}
  end

  def call
    @data.each do |entity_name, records|
      records.each_with_index do |record, record_index|
        record.keys.each do |field|
          value = record[field]
          add_value_to_index(record_index, entity_name, field, value)
        end
      end
    end

    return @inverted_index
  end

  def add_value_to_index(record_index, entity_name, field, value)
    if value.is_a?(Array)
      # Recurse over array values
      value.map { |sub_value| add_value_to_index(record_index, entity_name, field, sub_value) }
    else
      # convert integers and booleans to strings, and downcase
      value = value.to_s.downcase

      # Split value into seperate words
      if value.include? " "
        value_array = value.split(" ")
      else
        value_array = [value]
      end

      # we add the whole value to the index as well as the split value (so you can search e.g. a full name as well as name component)
      value_array = value_array << value if value_array.length > 1
      value_array.map do |value_component|
        # Initialize hash keys if needed
        @inverted_index[entity_name] ||= {}
        @inverted_index[entity_name][field] ||= {}
        @inverted_index[entity_name][field][value_component] ||= []
        # Add our search index location into the right bit of the index hash
        @inverted_index[entity_name][field][value_component] << record_index
      end
    end
  end
end
