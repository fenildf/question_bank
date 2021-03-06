module QuestionBank
  class Question
    include Mongoid::Document
    include Mongoid::Timestamps
    include Kaminari::MongoidExtension::Document
    include QuestionBank::EnumerizeKind
    include QuestionBank::TimeKindScope
    include QuestionBank::AnswerValidate
    include QuestionBank::Point::QuestionMethods
    extend Enumerize

    # 题目正文
    field :content,  type: String
    enumerize :content_format, in: [:text, :md], default: :text
    # 答案解析
    field :analysis, type: String
    # 难度系数(1 2 3 4 5 6 7 8 9 10)
    field :level,    type: Integer
    # 是否启用
    field :enabled,  type: Boolean, default: false
    # 答案
    field :answer

    validates :answer,  presence: true
    validates :content, presence: true
    validates :level,   presence: true

    has_many :question_flaws,   class_name: 'QuestionBank::QuestionFlaw'
    has_many :question_records, class_name: 'QuestionBank::QuestionRecord'

    scope :with_kind, ->(kind) { where(kind: kind) }

    # 填空题的填空数量
    def fill_count
      self.content.scan("___").size
    end

    def human_kind
      I18n.t("custom.model.question.human_kind.#{self.kind}")
    end

    def is_in_flaw_list_of?(user)
        user.question_flaws.where(:question_id => self.id.to_s).exists?
    end

    def sorted_choices(user)
      user_ord = (user.created_at.to_i % 43) + 1
      # 43是随便取的一个素数，
      # 可以随意换个大于选项个数的2~3位的数字代替,
      # +1为使之不为0
      self.answer["choices"].sort {|x, y|
        (x['id'].to_i(36) % user_ord) <=> (y['id'].to_i(36) % user_ord)
      }
    end
    
  end
end
