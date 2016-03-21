class Api::V1::QuestionsController < BaseController

	before_action :authenticate_with_token!, :except => [:show,:index]
  before_filter :load_question, only: :show
  ##
	# create questions
	# = params
		 # title, body, tags_set, question_type_set
	# = return
		 # question json object including its tags, types
	# <br>tag params specify tag name 
	# = URL
	#   POST questions/
	#
	#
	# = Examples
  #
  #   resp = conn.post("/api/v1/questions/?question[title]=I'm title&question[body]=I'm body&question[tags_set]=java,php,JAVA&question[question_type_set][]=range_question&question[question_type_set][]=1&question[question_type_set][]=2&auth_token=XxcFzXr_dzX1XWZoksqt")
  #
  #   resp.status
  #   => 201
  #
  #   resp.body
  #   => [{"id":208,"title":"I'm title","body":"I'm body","status":false,"num_views":0,"question_type":"default","created_at":"2015-08-12T11:06:34.921Z","updated_at":"2015-08-12T11:06:34.921Z","user_id":1,"tags":[{"id":13,"name":"java","description":null,"created_at":"2015-08-02T14:43:40.000Z","updated_at":"2015-08-02T14:43:40.000Z"},{"id":8,"name":"php","description":null,"created_at":"2015-07-28T12:47:11.000Z","updated_at":"2015-07-28T12:47:11.000Z"},{"id":13,"name":"java","description":null,"created_at":"2015-08-02T14:43:40.000Z","updated_at":"2015-08-02T14:43:40.000Z"}],"multiple_choices":[],"range_questions":[]}]
  #
  #   resp = conn.post("/api/v1/questions/?question[body]=I'm body&question[tags_set]=java,php,JAVA&question[question_type_set][]=range_question&question[question_type_set][]=1&question[question_type_set][]=2&auth_token=XxcFzXr_dzX1XWZoksqt")
  #
  #   resp.status
  #   => 422
  #
  #   resp.body
  #   => [{"status":false,"message":"Invalid","errors":{"title":["can't be blank"]}}]
  # 
	def create
		@question = Question.new(question_params)
		if @question.save
			if @question.question_type == TYPE_MULTICHOICE
				render json: @question,include: ['tags', 'multiple_choices'], status: :created
			elsif @question.question_type == TYPE_RANGE
				render json: @question,include: ['tags', 'range_questions'], status: :created
			else
				render json: @question,include: ['tags'], status: :created	
			end

		else
			render json: {status: false , :message => I18n.t('questions.create.invalid'),
		      errors: @question.errors}, status: :unprocessable_entity
		end
	end

  ##
	# search questions
	# = params
		 # filter,tag,sort
	# = return
		 # question paginated json object including its answers
	# = availabe filters
		 # (newest,featured,type,vote,active,unanswered(availabe sort for unanswered noanswer,newest,votes))
	# = URL
	#   GET questions/
	#
	#
	# = Examples
  #
  #   resp = conn.get("/api/v1/questions, "filter" => "newest")
  #
  #   resp.status
  #   => 200
  #
  #   resp.body
  #   => [{"id":4,"title":"test","body":"test questions","status":null,"num_views":0,"question_type":null,"created_at":"2015-07-29T07:10:21.000Z","updated_at":"2015-07-29T07:10:21.000Z","user_id":2,"answers":[]},{"id":3,"title":"test","body":"test questions","status":null,"num_views":0,"question_type":null,"created_at":"2015-07-29T07:09:42.000Z","updated_at":"2015-07-29T07:09:42.000Z","user_id":2,"answers":[]}]
  #
  #   resp = conn.get("/api/v1/questions, "filter" => "featured")
  #
  #   resp.status
  #   => 200
  #
  #   resp.body
  #   => [{"id":1,"title":"hello","body":"test","status":false,"num_views":2,"question_type":"essay","created_at":null,"updated_at":"2015-08-09T11:16:14.000Z","user_id":null,"answers":[]},
  #      {"id":2,"title":"test","body":"test questions","status":null,"num_views":0,"question_type":null,"created_at":"2015-07-29T07:08:28.000Z","updated_at":"2015-08-09T11:16:24.000Z","user_id":2,"answers":[{"id":1,"body":null,"verified":null,"question_id":2,"created_at":"2015-07-26T07:55:06.000Z","updated_at":"2015-07-26T07:55:06.000Z","user_id":1}]
  #   resp = conn.get("/api/v1/questions, "filter" => "newest","tag" => "java")
  #
  #   resp.status
  #   => 200
  #
  #   resp.body
  #   => [{"id":3,"title":"test","body":"test questions","status":null,"num_views":0,"question_type":null,"created_at":"2015-07-29T07:09:42.000Z","updated_at":"2015-07-29T07:09:42.000Z","user_id":2,"answers":[]}]
	#   
	#   resp = conn.get("/api/v1/questions?page=1&filter=with_type&type=RangeQuestion")
  #
  #   resp.status
  #   => 200
  #
  #   resp = conn.get("/api/v1/questions?page=1&filter=newest")
  #
  #   resp.status
  #   => 200
  #
  def index
		query_builder = QuestionQueryBuilder.new(params)
		if !query_builder.validate_input
			render json: { status: false ,errors: I18n.t('option.not_found') },
			status: :unprocessable_entity
			return
		end

		@questions = query_builder.getQuery
		paginate json: @questions,include: ['answers'], status: :ok
  end

	def show
		# @question = Question.find(params[:id])
		@question.increment_no_of_views
		if @question.question_type == TYPE_MULTICHOICE
			render json: @question,include: ['tags', 'multiple_choices', 'answers']
		elsif @question.question_type == TYPE_RANGE
			render json: @question,include: ['tags', 'range_questions', 'answers']
		else
			render json: @question,include: ['tags', 'answers']	
		end
	end

	private

	def question_params
		params[:question][:user_id] = current_user.id
		params.require(:question).permit(:user_id, :title, :body, :tags_set, question_type_set: [])
	end

	def load_question
    @question = Question.where(id: params[:id]).first
    if !@question
      render json: {status: false, message: I18n.t('questions.not_found')}, status: :not_found
    end
  end

end
