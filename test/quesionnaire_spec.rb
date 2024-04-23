require_relative '../questionnaire'
require 'stringio'

describe Questionnaire do
  let(:mock_io) { StringIO.new }
  let(:questionnaire) { Questionnaire.new }

  before do
    # Redirect stdout to mock_io for testing output
    $stdout = mock_io
  end

  after do
    # Restore stdout
    $stdout = STDOUT
  end

  describe "#do_prompt" do
    it 'asks questions and processes answer' do
        allow(questionnaire).to receive(:gets).and_return("yes\n", "no\n", "yes\n", "yes\n", "no\n")
        expect(questionnaire).to receive(:save_answers_and_rating).with(["yes", "no", "yes", "yes", "no"])
        questionnaire.do_prompt
    end
  end

  describe "#do_report" do
    it 'display survey report' do
      questionnaire.send(:do_report)
      expect(mock_io.string).to include("Rating for the survey you just submitted : ")
      expect(mock_io.string).to include("Average ratings score for all runs : ")
    end  
  end

  describe "#save_answers_and_rating" do
    it "saves answers to the store" do
      answers = ["yes", "yes", "yes", "yes", "no"]
      questionnaire.send(:save_answers_and_rating, answers)
      stored_answers = questionnaire.instance_variable_get(:@store).transaction { |store| store[:answers] }
      stored_ratings = questionnaire.instance_variable_get(:@store).transaction { |store| store[:rating] }
      expect(stored_answers.last).to eq(answers)
      expect(stored_ratings.last).to eq(80)
    end
  end

  describe "#calculate_rating" do
    it "calculates rating correctly" do
      answers = ["yes", "no", "yes", "yes", "yes"]
      rating = questionnaire.send(:calculate_rating, answers)
      expect(rating).to eq(80.0)
    end
  end
end
