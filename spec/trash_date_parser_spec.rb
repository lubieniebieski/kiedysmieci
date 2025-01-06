require "spec_helper"
require "pry"
require_relative "../lib/trash_date_parser"

describe TrashDateParser do
  let(:data) { File.read("spec/test_data.json") }
  subject { TrashDateParser.new(JSON.parse(data)) }

  describe "#trash_days" do
    it "returns array of TrashDay objects" do
      expect(subject.trash_days).to all(be_a(TrashDay))
    end

    it "returns correct dates and types" do
      trash_days = subject.trash_days
      expect(trash_days.map(&:date)).to eq([Date.parse("2024-01-31"), Date.parse("2024-02-29")])
      expect(trash_days.first.types).to include("Zmieszane")
    end
  end

  describe "#next_trash_day" do
    before do
      allow(Date).to receive(:today).and_return(Date.parse("2024-01-15"))
    end

    it "returns the next TrashDay after today" do
      next_day = subject.next_trash_day
      expect(next_day).to be_a(TrashDay)
      expect(next_day.date).to eq(Date.parse("2024-01-31"))
    end

    it "returns correct types for next collection" do
      expect(subject.next_trash_day.types).to include("Zmieszane")
    end
  end

  describe "#upcoming_collections" do
    before do
      allow(Date).to receive(:today).and_return(Date.parse("2024-01-15"))
    end

    it "returns all future TrashDay objects" do
      upcoming = subject.upcoming_collections
      expect(upcoming).to all(be_a(TrashDay))
      expect(upcoming.map(&:date)).to all(be >= Date.today)
    end
  end
end
