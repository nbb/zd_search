require "build_index"
require "byebug"

describe BuildIndex do
  let(:data) {
    {
      "users" => [
        {"name" => "Francisca Rasmussen", "timezone" => "Sri Lanka", "active" => false, "tags" => ["Springville", "Sutton"]},
        {"name" => "Cross Barlow", "timezone" => "Armenia", "active" => true, "tags" => ["Foxworth", "Woodlands"]}
      ]
    }
  }

  describe ".call" do
    it "correctly indexes a given data hash that includes strings, booleans and arrays" do
      build_index = BuildIndex.new(data)
      expect(build_index.call).to eq(
        "users" => {
          "active" => {
            "false" => [0],
            "true" => [1]
          },
          "name" => {
            "francisca" => [0],
            "rasmussen" => [0],
            "francisca rasmussen" => [0],
            "barlow" => [1],
            "cross" => [1],
            "cross barlow" => [1]
          },
          "tags" => {
            "springville" => [0],
            "sutton" => [0],
            "foxworth" => [1],
            "woodlands" => [1]
          },
          "timezone" => {
            "lanka" => [0],
            "sri" => [0],
            "sri lanka" => [0],
            "armenia" => [1]
          }
        }
      )
    end
  end
end