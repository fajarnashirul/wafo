class EmailsController < ApplicationController
    before_action :find_user
    before_action :validate_email_update, only: :update

    def new
        token = params[:token].to_s
      
        if params[:token].blank?
          return render json: {error: 'Token tidak ada'}
        end
      
        @user = User.find_by(reset_token: token)
      
        if @user.present? && @user.token_valid?
          if @user.update_new_email!(params[:new_email])
            render json: {status: 'ok',}, status: :ok
          else
            render json: {error: @user.errors.full_messages}, status: :unprocessable_entity
          end
          else
            render json: {error:  ['Token sudah kadaluarsa.']}, status: :not_found
          end
    end

    def update
        @user.generate_token!
        # SEND EMAIL HERE
        time = @user.reset_token_sent_at + 4.hours.to_i
        time_formatted = time.strftime("%m-%d-%Y %H:%M")
        success_response({ token: @user.reset_token, exp: time_formatted}, :ok, nil)
    end

    private

    def validate_email_update

        @new_email = params[:new_email]
    
        if @new_email.blank?
          return render json: { status: 'Email kosong' }, status: :bad_request
        end
    
        if  @new_email == @user.email
          return render json: { status: 'Email sama seperti sebelumnya' }, status: :bad_request
        end
    
        if User.email_used?(@new_email)
          return render json: { error: 'Email sudah digunakan' }, status: :unprocessable_entity
        end
    end

    def find_user
        @user = User.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound
        error_message = "User dengan id #{params[:user_id]} tidak ditemukan"
        fail_response(:not_found, error_message)
    end
end
