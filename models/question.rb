class Question < ActiveRecord::Base
  belongs_to :user

  has_many :tag_questions
  has_many :question_edits
  has_many :multiple_choices
  has_many :range_questions
  has_many :answers
  has_many :tags, :through => :tag_questions
  has_many :comments, :as => :commentable
  has_many :votes, :as => :votable
  
  attr_accessor :question_type_set

  before_create :set_default

  # Validation
  validates :user, presence: true

  validates :title, :body, presence: true

  validate  :validate_question_size , on: :create

  # Scopes
  # TODO: unanswered and no_answer scope names
  # may cause confusion

  scope :newest, -> { order('created_at desc') }

  scope :featured, -> { order('num_views desc') }

  scope :unanswered, -> { where('status = ?', false).order('created_at desc') }

  scope :noanswers, -> { where('id NOT IN (SELECT DISTINCT(question_id) FROM answers)')}
  
  scope :with_type, -> type { where(question_type: type) }
  scope :with_type_not_default, -> { where("question_type is NOT NULL and question_type != '#{TYPE_DEFAULT}'") }

  # TODO: this scope has an issue that it now knows that votes 
  # table has up_down attribute
  scope :vote, -> {
    select("questions.*, count(questions.id) AS questions_count")
    .joins(:votes).where( :votes => { :up_down => true } )
    .group("questions.id").order("questions_count DESC")
  }

  scope :active, -> {
   joins(:answers).where("(answers.created_at > ? or questions.created_at > ?)",
                         7.days.ago,7.days.ago)
 }

 scope :tag_filter, -> tag {joins(:tags).where("tags.name =  ?",tag)}


  #increment number of views
  def increment_no_of_views
    self.increment!(:num_views)
  end

  # TODO: this can simply return self.user == user
  def can_verify?(user)
    return self.user == user
  end

  def tags_set=(names)
    names.split(",").map do |name|
     self.tags << Tag.where(name: name.strip).first_or_create!
    end
  end

  # TODO: use static string variables instead of strings
  def question_type_set=(param)
    @param = param
    if(param[0] === TYPE_MULTICHOICE)
      self.question_type = TYPE_MULTICHOICE
      $i = 1
      while $i < param.length do
        @choice = MultipleChoice.new(response_text: param[$i],
                                      response_number: param[$i+1])
        $i += 2
        if @choice.save
          self.multiple_choices << @choice
        end
      end

    elsif(param[0] === TYPE_RANGE && param.length === 3)
      self.question_type = TYPE_RANGE
      @range_question = RangeQuestion.new(min: param[1], max: param[2])

      if @range_question.save
        self.range_questions << @range_question
      end
    end
  end


  private
  #Set_default
  #set the default value of both status and number of viewers
  def set_default
    self.status = false
    self.num_views = 0
    if(!self.question_type)
      self.question_type = TYPE_DEFAULT
    end
  end

  def validate_question_size
    if (@param && (@param.length <= 1 || @param.length % 2 != 1))
        self.errors[:question_type] << I18n.t('questions.create.invalidtype')
    elsif (@param && @param[0] === TYPE_RANGE && @param.length == 3)
      if @param[1] > @param[2]
        self.errors[:question_type] << I18n.t('questions.create.invalidRangeType')
      end
    elsif (@param && @param[0] === TYPE_RANGE && @param.length != 3)
        self.errors[:question_type] << I18n.t('questions.create.invalidRangeType')
    end
  end

end
