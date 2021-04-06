# Returns results from a provided data hash using a provided inverted search index
class Searcher
  def initialize(search_index, data, entity, field, search_term)
    @search_index = search_index
    @data = data
    @entity = entity
    @field = field
    @search_term = search_term
  end

  def call
    record_indices = find_record_indices(@search_index, @entity, @field, @search_term.downcase)
    record_indices.map do |record_index|
      record = @data[@entity][record_index]
      record = attach_linked_records(record)
    end
  end

  private

  # Find the record indices in the search index for a given query
  def find_record_indices(search_index, entity, field, search_term)
    return [] unless search_index && search_index[entity] && search_index[entity][field]
    search_index[entity][field][search_term] || []
  end

  def attach_linked_records(record)
    if @entity == "users"
      # Find related organization name
      organization_index = find_record_indices(@search_index, "organizations", "_id", record["organization_id"].to_s)[0]
      if organization_index
        record["organization"] = @data["organizations"][organization_index]["name"]
        record.delete("organization_id")
      end

      # Find related tickets
      assignee_ticket_indices = find_record_indices(@search_index, "tickets", "assignee_id", record["_id"].to_s)
      submitter_ticket_indices = find_record_indices(@search_index, "tickets", "submitter_id", record["_id"].to_s)
      ticket_indices = assignee_ticket_indices + submitter_ticket_indices
      ticket_indices.each_with_index do |ticket_index, i|
        record["ticket_#{i}"] = @data["tickets"][ticket_index]["subject"]
      end
    elsif @entity == "tickets"
      # Find related submitter name
      submitter_index = find_record_indices(@search_index, "users", "_id", record["submitter_id"].to_s)[0]
      if submitter_index
        record["submitter"] = @data["users"][submitter_index]["name"]
        record.delete("submitter_id")
      end

      # Find related assignee name
      assignee_index = find_record_indices(@search_index, "users", "_id", record["assignee_id"].to_s)[0]
      if assignee_index
        record["assignee"] = @data["users"][assignee_index]["name"]
        record.delete("assignee_id")
      end

      # Find related organization name
      organization_index = find_record_indices(@search_index, "organizations", "_id", record["organization_id"].to_s)[0]
      if organization_index
        record["organization"] = @data["organizations"][organization_index]["name"]
        record.delete("organization_id")
      end
    elsif @entity == "organizations"
      # Find related tickets
      ticket_indices = find_record_indices(@search_index, "tickets", "organization_id", record["_id"].to_s)
      ticket_indices.each_with_index do |ticket_index, i|
        record["ticket_#{i}"] = @data["tickets"][ticket_index]["subject"]
      end

      # Find related users
      user_indices = find_record_indices(@search_index, "users", "organization_id", record["_id"].to_s)
      user_indices.each_with_index do |user_index, i|
        record["user_#{i}"] = @data["users"][user_index]["name"]
      end
    end

    record
  end
end