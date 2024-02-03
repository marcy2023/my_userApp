require 'sinatra'
require 'json'
require_relative 'my_user_model.rb'

class MyUserApp < Sinatra::Base
  configure do
    # Configuration de l'application
    set :port, 8080
    set :bind, '0.0.0.0'
    enable :sessions
  end

  # Page d'accueil pour afficher tous les utilisateurs
  get '/' do
    @users = User.all
    erb :index
  end

  # Endpoint pour récupérer tous les utilisateurs au format JSON
  get '/users' do
    content_type :json
    users = User.all.map { |user| user.slice("firstname", "lastname", "age", "email") }
    users.to_json
  end

  # Endpoint pour l'authentification d'un utilisateur
  post '/sign_in' do
    verify_user = User.authenticate(params[:password], params[:email])
    if !verify_user.empty?
      status 200
      session[:user_id] = verify_user[0]["id"]
      verify_user[0].to_json
    else
      status 401
    end
  end

  # Endpoint pour la création d'un nouvel utilisateur
  post '/users' do
    if params[:firstname]
      create_user = User.create(params)
      new_user = User.find(create_user.id)
      user = {
        firstname: new_user.firstname,
        lastname: new_user.lastname,
        age: new_user.age,
        password: new_user.password,
        email: new_user.email
      }.to_json
    else
      check_user = User.authenticate(params[:password], params[:email])
      if !check_user[0].empty?
        status 200
        session[:user_id] = check_user[0]["id"]
      else
        status 401
      end
      check_user[0].to_json
    end
  end

  # Endpoint pour la mise à jour du mot de passe d'un utilisateur
  put '/users' do
    User.update(session[:user_id], 'password', params[:password])
    user = User.find(session[:user_id])
    status 200
    user_info = {
      firstname: user.firstname,
      lastname: user.lastname,
      age: user.age,
      password: user.password,
      email: user.email
    }.to_json
  end

  # Endpoint pour la déconnexion d'un utilisateur
  delete '/sign_out' do
    session[:user_id] = nil if session[:user_id]
    status 204
  end

  # Endpoint pour la suppression d'un utilisateur
  delete '/users' do
    user_id = session[:user_id]
    halt 401, json({ message: 'Unauthorized' }) if user_id.nil?
    User.new.destroy(user_id)
    session.clear
    status 204
  end

  run! if app_file == $0
end
