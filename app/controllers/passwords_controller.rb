class PasswordsController < ApplicationController
    before_action :find_user, except: %i[forgot reset]

    def forgot
        if params[:email].blank?
            return render json: {error: 'Email tidak ada'}
        end

        @user = User.find_by(email: params[:email])

        if @user.present?
            @user.generate_token!
            # SEND EMAIL HERE
            @token = @user.reset_token
            # TokenMailer.with(token: @order, email: params[:email]).send_token.deliver_later

            time = @user.reset_token_sent_at + 4.hours.to_i
            time_formatted = time.strftime("%m-%d-%Y %H:%M")
            success_response({ token: @user.reset_token, exp: time_formatted, message: 'Token telah di kirim ke email, mohon gunakan sebelum kadaluarsa'}, :ok, nil)
          else
            render json: {error: ['Alamt email tidak ditemukan. Mohon dicek kembali.']}, status: :not_found
          end
        end
      
        def reset
          token = params[:token].to_s
      
          if params[:token].blank?
            return render json: {error: 'Token tidak ada'}
          end
          if params[:password].blank?
            return render json: {error: 'masukan password baru'}
          end

          @user = User.find_by(reset_token: token)
      
          if @user.present? && @user.token_valid?
            if @user.reset_password!(params[:password])
              render json: {status: 'ok',}, status: :ok
            else
              render json: {error: user.errors.full_messages}, status: :unprocessable_entity
            end
          else
            render json: {error:  ['Token sudah kadaluarsa.']}, status: :not_found
          end
    end

    def update
        if !params[:password].present?
            render json: {error: 'Password kosong'}, status: :unprocessable_entity
            return
          end
        
          if @user.reset_password!(params[:password])
            render json: {status: 'Password telah di ganti'}, status: :ok
          else
            render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
          end
    end

    def find_user
        @user = User.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound
        error_message = "User dengan id #{params[:user_id]} tidak ditemukan"
        fail_response(:not_found, error_message)
    end
end
