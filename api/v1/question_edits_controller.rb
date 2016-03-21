class Api::V1::QuestionEditsController < BaseController

	before_filter :load_question, except: :approve
	before_filter :check_id_valid, except: :create
	before_filter :load_question_edit, only: :approve
	before_action :authenticate_with_token!


	##
	# Edit a question
	# = params
		 # body,question_id
	# = return
		 # question_edit json object
	# = URL
	#   PUT  /questions/:question_id/
	#
	#
	# = Examples
    #
    #   resp = conn.put("/api/v1/questions/1/", "quetion_edit[body]" => "edit this question")
    #
    #   resp.status
    #   => 201
    #
    #   resp.body
    #   => [{"status":"true","question_edit":{"id":6,"body":"edit this","question_id":1,"created_at":"2015-07-27T14:32:38.635Z","updated_at":"2015-07-27T14:32:38.635Z","approve":false}}]

	def create
		@question_edit = @question.question_edits.new(question_edit_params)

		if @question_edit.save
			render json: { status: true, question_edit: @question_edit}, status: :created
		else
			render json: { status: false, :message => I18n.t('question_edits.create.invalid'), :errors => @question_edit.errors}, status: :unprocessable_entity
		end
	end

	##
	# Approve edit
	# = params
		 # question_edit_id, approve
	# = return
		 # json object
	# = URL
	#  POST /question_edits/:id/
	#
	#
	# = Examples
    #
    #   resp = conn.post("/api/v1/question_edits/7/", "approve" => "true")
    #
    #   resp.status
    #   => 200
    #
    #   resp.body
    #   => [{"status":"true"}]


	def approve
		@approve = @question_edit.set_approve?(params[:question_edit][:approve].downcase)
		if @approve
			render json: { status: true, message: "Still"}, status: :ok
		else
			render json: { status: true}, status: :no_content
		end
	end

	private

	def question_edit_params
		params[:question_edit][:user_id] = current_user.id
		params.require(:question_edit).permit(:user_id, :body)
	end

	def load_question_edit
  	@question_edit = QuestionEdit.where(id: params[:id]).first
  	if !@question_edit
  		render json: {status: false, message: I18n.t('questions_edits.not_found')}, status: :not_found
  	end
  end

	def load_question
  	@question = Question.where(id: params[:question_id]).first
  	if !@question
  		render json: {status: false, message: I18n.t('questions.not_found')}, status: :not_found
  	end
	end

	def check_id_valid
		if !QuestionEdit.exists?(id: params[:id]);
			render json: {status: false, message: I18n.t('question_edits.not_found')}, status: :not_found
		end
	end
end
