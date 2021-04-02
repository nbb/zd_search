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
  def call
    data = {}
    file_names = ["users.json", "tickets.json", "organizations.json"]
    file_names.each do |file_name|
      file = File.read("data/" + file_name)
      data[file_name.gsub(".json", "").to_sym] = JSON.parse(file)
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
    data.keys.each do |key|
      data[key].each_with_index do |item, i|
        inverted_index[key].keys.each do |index_key|
          inverted_index[key][index_key][item[index_key.to_s]] = i
        end
      end
    end

    return data
  end
end
