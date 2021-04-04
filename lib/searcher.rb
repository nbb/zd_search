class Searcher
  def initialize(search_index, data, entity, field, search_term)
    @search_index = search_index
    @data = data
    @entity = entity
    @field = field
    @search_term = search_term
  end

  def call
    location_indexes = @search_index[@entity][@field][@search_term.downcase]
    location_indexes.map { |location_index| @data[@entity][location_index] }
  end
end