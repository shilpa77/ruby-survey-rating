class Questionnaire
  require "pstore" # https://github.com/ruby/pstore

  STORE_NAME = "tendable.pstore"
  POSITIVE_RESPONSE = ["yes", "y"]

  def initialize
    @store = PStore.new(STORE_NAME)
  end

  QUESTIONS = {
    "q1" => "Can you code in Ruby?",
    "q2" => "Can you code in JavaScript?",
    "q3" => "Can you code in Swift?",
    "q4" => "Can you code in Java?",
    "q5" => "Can you code in C#?"
  }.freeze

  # Accept survey answers
  def do_prompt
    answers = []
    # Ask each question and get an answer from the user's input.
    QUESTIONS.each_key do |question_key|
      print QUESTIONS[question_key]
      ans = gets.chomp.downcase
      answers << ans
    end

    save_answers_and_rating(answers)
  end

  # Print overall surveys report
  def do_report
    ratings = @store.transaction(true) { @store[:rating] }
    puts "Rating for the survey you just submitted : #{ratings.last}"
    average_rating = (ratings.inject(0, :+))/ratings.length
    puts "Average ratings score for all runs : #{average_rating.round(2)}"
  end

  private
    # Store survey answers and ratings in array format
    def save_answers_and_rating(answers)
      survey_rating = calculate_rating(answers)
      @store.transaction do
        @store[:answers] ||= []
        @store[:rating] ||= []
        @store[:answers] << answers
        @store[:rating] << survey_rating
      end
    end

    def calculate_rating(answers)
      yes_count = answers.count { |answer| POSITIVE_RESPONSE.include?(answer)}
      total_questions = QUESTIONS.length
      (yes_count.to_f / total_questions * 100).round(2)
    end


end
questionnaire = Questionnaire.new
questionnaire.do_prompt
questionnaire.do_report
