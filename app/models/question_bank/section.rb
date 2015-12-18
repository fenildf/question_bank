module QuestionBank
  class Section
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize
    # 引用排序模块
    include QuestionBank::Concerns::MovePosition

    # 题目类型 枚举: 单选题 多选题 判断题 填空题 论述题 连线题
    KINDS = [:single_choice, :multi_choice, :bool, :fill, :essay, :mapping]
    enumerize :kind, in: KINDS

    # 每题分值
    field :score, :type => Integer

    # 最低难度系数(1 2 3 4 5 6 7 8 9 10)
    field :min_level, :type => Integer
    # 最高难度系数(1 2 3 4 5 6 7 8 9 10)
    field :max_level, :type => Integer

    belongs_to :test_paper, class_name: 'QuestionBank::TestPaper', inverse_of: :sections
    def questions
      section_questions.map(&:question).compact
    end

    def parent
      test_paper
    end

    validates :kind, :presence => true
    validates :score, :presence => true
    validates :min_level, :presence => true
    validates :max_level, :presence => true

    has_and_belongs_to_many :questions, class_name:'QuestionBank::Question'

    def question_ids_str
      question_ids.map(&:to_s).join(",")
    end

    def question_ids_str=(str)
      p "question_ids_str="
      p self.question_ids
      self.question_ids = str.split(",")
      p self.question_ids
    end
  end
end
