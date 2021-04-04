require "searcher"
require "byebug"

describe Searcher do
  let(:data) {
    {
      "users" => [
        {"name" => "Francisca Rasmussen", "timezone" => "Sri Lanka"},
        {"name" => "Cross Barlow", "timezone" => "Sri Lanka"}
      ]
    }
  }

  let(:search_index) {
    { users: {
        name: {
          "francisca rasmussen" => [0]
        },
        timezone: {
          "sri lanka" => [0, 1]
        }
      }
    }
  }

  describe ".call" do
    it "finds a matching record for a given search" do
      searcher = Searcher.new(search_index, data, "users", "name", "Francisca Rasmussen")
      expect(searcher.call).to eq([{"name"=>"Francisca Rasmussen", "timezone" => "Sri Lanka"}])
    end

    it "finds multiple matching records for a given search" do
      searcher = Searcher.new(search_index, data, "users", "timezone", "Sri Lanka")
      expect(searcher.call).to eq([
        {"name" => "Francisca Rasmussen", "timezone" => "Sri Lanka"},
        {"name" => "Cross Barlow", "timezone" => "Sri Lanka"}
      ])
    end

    it "finds a record for a given search case-insensitively" do
      searcher = Searcher.new(search_index, data, "users", "name", "FrAnCiScA RaSmUsSeN")
      expect(searcher.call).to eq([{"name"=>"Francisca Rasmussen", "timezone" => "Sri Lanka"}])
    end
  end
end