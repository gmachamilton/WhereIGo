class AccountController < ApplicationController
    
    def flash_create_user(message)
        session[:return_to] ||= request.referer
    	redirect_to session.delete(:return_to), :flash => {:error => message}
    	return
    end
    
    
    def flash_create_user_special(message)
        redirect_to '/register', :flash => {:error => message}
    	return
    end
    
    def edit
        @title = "Minha conta"
        if session[:current_user_id] == nil
            redirect_to '/login', :flash => { :error => "Faça login para continuar!" }
            return
        end
        @user = User.find_by(id: session[:current_user_id])
        if @user.is_provider
            render layout: "provider"
        else
            render layout: "client"
        end
    end
    
    def update
        values = params.require(:user).permit!
        user = User.find_by(email: params[:user][:email])
        if params[:user][:password_digest] == user.password_digest
            User.update(session[:current_user_id], values)
            redirect_to '/account', :flash => { :error => "Conta editada com sucesso!" }
        else
            redirect_to '/account', :flash => { :error => "Senha incorreta." }
        end
    end
    
    def login
    	if session[:current_user_id] != nil
    		redirect_to '/account'
    		return
    	end
    	@title = "Login"
    	render layout: "login-signup"
    end
    
    def login_authentication
    	user = User.find_by(email: params["email"])
    	if user != nil
    		if user.password_digest == params["password"]
    		    session[:current_user_id] = user.id
    	        if user.is_client or user.is_provider
    			    if user.is_provider
    			        redirect_to '/p/dashboard'
    			        return
    			    else
    			        redirect_to '/c/dashboard'
    			    end
    		    else
    			    redirect_to '/register/role'
    		    	return
                end
    		
    		else
    			redirect_to '/login', :flash => { :error => "Usuário ou senha incorretas!" }
    			return
    		end
    	else
    		redirect_to '/login', :flash => { :error => "Usuário não encontrado!" }
    		return
    	end
    end
    
    def logout
    	session[:current_user_id] = nil
	    redirect_to ''
	    return
    end
    
    def register_account
        @title = "Cadastro"
        render layout: "login-signup"
    end
    
    def register_create_account
        values = params.require(:user).permit!
        new_user = User.new values
        if new_user.valid?
            if User.exists?(:email => params[:user][:email])
                flash_create_user_special("O email já está em uso.")
                return
            else
                new_user.save
        	    session[:current_user_id] = new_user[:id]
        	    redirect_to '/register/role'
        	    return
            end
        else
            if params[:user][:name].strip == ""
                flash_create_user_special("O campo nome é obrigatório.")
                return
            elsif params[:user][:password_digest].size < 6
        	    flash_create_user_special("A senha precisa ter no mínimo 6 caracteres.")
        	    return
            elsif params[:user][:email].strip == ""
                flash_create_user_special("O campo e-mail é obrigatório.")
                return
            elsif params[:user][:password_digest].strip == ""
                flash_create_user_special("O campo senha não pode ter espaço.")
                return
            end
        end
    	render layout: "login-signup"
    end
    
    def register_role_choice
        render layout: "login-signup"
    end
    
    
    def register_role_provider
        User.update(session[:current_user_id], :is_provider => true)
        redirect_to '/register/provider/establishment'
    end
    
    def register_role_client
        User.update(session[:current_user_id], :is_client => true)
        redirect_to '/c/dashboard'
    end
    
    def register_provider_establishment
        @title = "Estabelecimento"
        render layout: "login-signup"
    end
    
end