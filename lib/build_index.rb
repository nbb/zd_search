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
  end

  def call
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
    @data.each do |entity_name, fields|
      fields.each_with_index do |field, i|
        inverted_index[entity_name.to_sym].keys.each do |index_key|
          value = field[index_key.to_s].to_s.downcase
          inverted_index[entity_name.to_sym][index_key][value] ||= []
          inverted_index[entity_name.to_sym][index_key][value] << i
        end
      end
    end

    return inverted_index
  end
end
