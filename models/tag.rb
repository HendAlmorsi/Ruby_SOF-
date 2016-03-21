class Tag < ActiveRecord::Base
	has_many :tag_questions
	has_many :questions, :through => :tag_questions

	validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :popular, -> {
    select("tags.*, count(questions.id) AS questions_count").
    joins(:questions).
    group( 'tags.id' ).
    order("questions_count DESC")
  }

  scope :newest, -> {order(created_at: :DESC)}
  scope :nameAlp, -> {order(name: :asc)}

  def self.search(query, filter)
    if query
      where('name LIKE ?', "%#{query}%").order(name: :asc)
    elsif filter && filter.downcase === "popular"
      Tag.popular
    elsif filter && filter.downcase === "newest"
      Tag.newest
    else
      Tag.nameAlp
    end
  end

end
