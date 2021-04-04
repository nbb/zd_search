# Builds an inverted index, which will have a structure something like this:
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
    # Can we initialise the inverted index using the data hash above instead?
    @inverted_index = {
      "users" => {
        "_id" => {}, "url" => {}, "external_id" => {}, "name" => {}, "alias" => {}, "created_at" => {}, "active" => {}, "verified" => {}, "shared" => {}, "locale" => {}, "timezone" => {}, "last_login_at" => {}, "email" => {}, "phone" => {}, "signature" => {}, "organization_id" => {}, "tags" => {}, "suspended" => {}, "role" => {}
      },
      "tickets" => {
        "_id" => {}, "url" => {}, "external_id" => {}, "created_at" => {}, "type" => {}, "subject" => {}, "description" => {}, "priority" => {}, "status" => {}, "submitter_id" => {}, "assignee_id" => {}, "organization_id" => {}, "tags" => {}, "has_incidents" => {}, "due_at" => {}, "via" => {}
      },
      "organizations" => {
        "_id" => {}, "url" => {}, "external_id" => {}, "name" => {}, "domain_names" => {}, "created_at" => {}, "details" => {}, "shared_tickets" => {}, "tags" => {}
      }
    }
  end

  def call
    # Build out our inverted index here
    # TODO: I think this needs to be recursive and follow the structure of the data input
    @data.each do |entity_name, records|
      records.each_with_index do |record, record_index|
        @inverted_index[entity_name].keys.each do |field|
          value = record[field]
          add_value_to_index(record_index, entity_name, field, value)
        end
      end
    end

    return @inverted_index
  end

  def add_value_to_index(field_index, entity_name, field, value)
    if value.is_a?(Array)
      value.map { |sub_value| add_value_to_index(field_index, entity_name, field, sub_value) }
    end
    value = value.to_s.downcase # convert integers and booleans to strings at this point, and downcase
    value_array = value.split(" ")
    value_array = value_array << value if value_array.length > 1 # we add the whole value to the index as well as the split value (so you can search e.g. a full name as well as name component)
    value_array.map do |value_component|
      @inverted_index[entity_name][field][value_component] ||= []
      @inverted_index[entity_name][field][value_component] << field_index
    end
  end
end
