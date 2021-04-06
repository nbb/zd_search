class Searcher
  def initialize(search_index, data, entity, field, search_term)
    @search_index = search_index
    @data = data
    @entity = entity
    @field = field
    @search_term = search_term
  end

  def call
    record_locations = find_record_locations(@search_index, @entity, @field, @search_term.downcase)

    record_locations.map do |record_location|
      record = @data[@entity][record_location]
      record = attach_linked_records(record)
    end
  end

  def find_record_locations(search_index, entity, field, search_term)
    # Returns an empty array if entities, fields or results aren't present
    return [] unless search_index && search_index[entity] && search_index[entity][field]
    search_index[entity][field][search_term] || []
  end

  # Note: This method mutates the passed variable
  def attach_linked_records(record)
    if @entity == "users"
      # Find related organization name
      organization_record_location = find_record_locations(@search_index, "organizations", "_id", record["organization_id"].to_s)[0]
      if organization_record_location
        record["organization"] = @data["organizations"][organization_record_location]["name"]
        record.delete("organization_id")
      end

      # Find related tickets
      assignee_tickets = find_record_locations(@search_index, "tickets", "assignee_id", record["_id"].to_s)
      submitter_tickets = find_record_locations(@search_index, "tickets", "submitter_id", record["_id"].to_s)
      tickets = assignee_tickets + submitter_tickets
      tickets.each_with_index do |id, i|
        record["ticket_#{i}"] = @data["tickets"][id]["subject"]
      end
    elsif @entity == "tickets"
      # Find related submitter name
      user_record_location = find_record_locations(@search_index, "users", "_id", record["submitter_id"].to_s)[0]
      if user_record_location
        record["submitter"] = @data["users"][user_record_location]["name"]
        record.delete("submitter_id")
      end
      # Find related assignee name
      user_record_location = find_record_locations(@search_index, "users", "_id", record["assignee_id"].to_s)[0]
      if user_record_location
        record["assignee"] = @data["users"][user_record_location]["name"]
        record.delete("assignee_id")
      end
      # Find related organization name
      organization_record_location = find_record_locations(@search_index, "organizations", "_id", record["organization_id"].to_s)[0]
      if organization_record_location
        record["organization"] = @data["organizations"][organization_record_location]["name"]
        record.delete("organization_id")
      end
    end
    record
  end
end