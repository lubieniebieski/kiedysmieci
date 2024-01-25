require "spec_helper"
require "pry"
require_relative "../lib/trash_date_parser"

describe TrashDateParser do
  let(:data) { File.read("spec/test_data.json") }
  subject { TrashDateParser.new(data) }

  describe "#trash_days" do
    it "returns the dates" do
      expect(subject.trash_days).to eq([Date.parse("2024-01-31"), Date.parse("2024-02-29")])
    end
  end
end
