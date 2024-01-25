require "spec_helper"
require "pry"
require_relative "../lib/schedule"

describe Schedule do
  let(:data) { {"id" => "112233", "month" => "9", "days" => "17;18", "year" => "2024", "scheduleDescriptionId" => "123"} }
  let(:subject) { described_class.new(data) }

  it "allows to get the month" do
    expect(subject.month).to eq(9)
  end

  it "allows to get the days" do
    expect(subject.days).to eq([17, 18])
  end

  it "allows to get the year" do
    expect(subject.year).to eq("2024")
  end

  it "allows to get the schedule description id" do
    expect(subject.schedule_description_id).to eq("123")
  end

  it "allows to get the id" do
    expect(subject.id).to eq("112233")
  end

  describe "#trash_type" do
    ["54653", "54661", "54662", "54663", "54660", "54655", "54657"].each do |id|
      it "translates #{id} to something more friendly" do
        expect(subject).to receive(:schedule_description_id).and_return(id)
        expect(subject.trash_type).to_not match("Translation missing")
      end
    end
  end
end
