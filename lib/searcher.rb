class Searcher
  def initialize(search_index, data, entity, field, search_term)
    @search_index = search_index
    @data = data
    @entity = entity
    @field = field
    @search_term = search_term
  end

  def call
    index = @search_index[@entity.to_sym][@field.to_sym][@search_term.downcase]
    @data[@entity][index]
  end
end