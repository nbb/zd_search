require "searcher"
require "byebug"

describe Searcher do
  let(:data) {
    {
      "users" => [
        {"_id" => 1, "name" => "Francisca Rasmussen", "timezone" => "Sri Lanka"},
        {"_id" => 2, "name" => "Cross Barlow", "timezone" => "Sri Lanka", "tags" => ["Gallina", "Glenshaw"]},
        {"_id" => 3, "name" => "Ingrid Wagner", "timezone" => "Trinidad and Tobago"},
        {"_id" => 4, "name" => "Rose Newton", "timezone" => "Netherlands"}
      ],
      "organizations" => [
        { "_id" => 1, "name" => "Enthaze", }
      ],
      "tickets" => [
        {
          "subject" => "A Catastrophe in Korea (North)",
          "submitter_id" => 3,
          "assignee_id" => 4,
          "organization_id" => 1
        }
      ]
    }
  }

  # !! If you update the data variable above, you'll need an corresponding updated index. To do this `require "build_index"`
  # and run the following code from an example: `puts BuildIndex.new(data).call.to_s`
  let(:search_index) { {"users"=>{"_id"=>{"1"=>[0], "2"=>[1], "3"=>[2], "4"=>[3]}, "name"=>{"francisca"=>[0], "rasmussen"=>[0], "francisca rasmussen"=>[0], "cross"=>[1], "barlow"=>[1], "cross barlow"=>[1], "ingrid"=>[2], "wagner"=>[2], "ingrid wagner"=>[2], "rose"=>[3], "newton"=>[3], "rose newton"=>[3]}, "timezone"=>{"sri"=>[0, 1], "lanka"=>[0, 1], "sri lanka"=>[0, 1], "trinidad"=>[2], "and"=>[2], "tobago"=>[2], "trinidad and tobago"=>[2], "netherlands"=>[3]}, "tags"=>{"gallina"=>[1], "glenshaw"=>[1]}}, "organizations"=>{"_id"=>{"1"=>[0]}, "name"=>{"enthaze"=>[0]}}, "tickets"=>{"subject"=>{"a"=>[0], "catastrophe"=>[0], "in"=>[0], "korea"=>[0], "(north)"=>[0], "a catastrophe in korea (north)"=>[0]}, "submitter_id"=>{"3"=>[0]}, "assignee_id"=>{"4"=>[0]}, "organization_id"=>{"1"=>[0]}}} }

  describe ".call" do
    it "finds a matching record for a given search" do
      searcher = Searcher.new(search_index, data, "users", "name", "Francisca Rasmussen")
      expect(searcher.call).to eq([{"_id"=>1, "name"=>"Francisca Rasmussen", "timezone" => "Sri Lanka"}])
    end

    it "finds a matching record when the field contains the query as a word" do
      searcher = Searcher.new(search_index, data, "users", "name", "Francisca")
      expect(searcher.call).to eq([{"_id"=>1, "name"=>"Francisca Rasmussen", "timezone" => "Sri Lanka"}])
    end

    it "finds multiple matching records for a given search" do
      searcher = Searcher.new(search_index, data, "users", "timezone", "Sri Lanka")
      expect(searcher.call).to eq([
        {"_id"=>1, "name"=>"Francisca Rasmussen", "timezone"=>"Sri Lanka"},
        {"_id"=>2, "name"=>"Cross Barlow", "timezone"=>"Sri Lanka", "tags"=>["Gallina", "Glenshaw"]}
      ])
    end

    it "finds a matching record when the query is in the record's subarray" do
      searcher = Searcher.new(search_index, data, "users", "tags", "Gallina")
      expect(searcher.call).to eq([{"_id"=>2, "name"=>"Cross Barlow", "tags"=>["Gallina", "Glenshaw"], "timezone"=>"Sri Lanka"}])
    end

    it "finds a record for a given search case-insensitively" do
      searcher = Searcher.new(search_index, data, "users", "name", "FrAnCiScA RaSmUsSeN")
      expect(searcher.call).to eq([{"_id"=>1, "name"=>"Francisca Rasmussen", "timezone" => "Sri Lanka"}])
    end

    it "to return an empty array when searching for a non-existant entity" do
      searcher = Searcher.new(search_index, data, "non_existant_entity", "name", "a search query")
      expect(searcher.call).to eq([])
    end

    it "to return an empty array when searching for a non-existant field" do
      searcher = Searcher.new(search_index, data, "users", "non_existant_field", "a search query")
      expect(searcher.call).to eq([])
    end

    it "to return an empty array when no results are found" do
      searcher = Searcher.new(search_index, data, "users", "name", "a failing search query")
      expect(searcher.call).to eq([])
    end

    it "it returns related ticket data when searching users" do
      searcher = Searcher.new(search_index, data, "users", "name", "ingrid")
      expect(searcher.call).to eq([{"_id"=>3, "name"=>"Ingrid Wagner", "ticket_0"=>"A Catastrophe in Korea (North)", "timezone"=>"Trinidad and Tobago"}])
    end

    it "it returns related ticket data when searching organizations" do
      searcher = Searcher.new(search_index, data, "organizations", "name", "Enthaze")
      expect(searcher.call).to eq([{"_id"=>1, "name"=>"Enthaze", "ticket_0"=>"A Catastrophe in Korea (North)"}])
    end

    it "it returns related fields when searching tickets" do
      searcher = Searcher.new(search_index, data, "tickets", "subject", "catastrophe")
      expect(searcher.call).to eq([{"assignee"=>"Rose Newton", "organization"=>"Enthaze", "subject"=>"A Catastrophe in Korea (North)", "submitter"=>"Ingrid Wagner"}])
    end
  end
end