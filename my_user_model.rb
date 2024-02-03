require 'sqlite3'

class User
  # Attributs de la classe
  attr_accessor :id, :firstname, :lastname, :age, :email, :password

  # Initialise un nouvel utilisateur
  def initialize(id = 0, firstname, lastname, age, email, password)
    @id = id
    @firstname = firstname
    @lastname = lastname
    @age = age
    @email = email
    @password = password
  end

  # Méthode pour établir une connexion à la base de données
  def self.connect_db
    begin
      @db = SQLite3::Database.open 'db.sql'
      @db.results_as_hash = true

      # Crée la table 'users' si elle n'existe pas déjà
      @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY,
          firstname STRING,
          lastname STRING,
          age INTEGER,
          email STRING,
          password STRING
        );
      SQL

      return @db
    rescue SQLite3::Exception => e
      puts "Erreur : #{e}"
    end
  end

  # Méthode pour créer un nouvel utilisateur
  def self.create(user_info)
    @db = connect_db
    @db.execute "INSERT INTO users(firstname, lastname, age, email, password) VALUES (?, ?, ?, ?, ?)", user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:email], user_info[:password]

    user = User.new(user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:email], '')
    user.id = @db.last_insert_row_id
    @db.close
    return user
  end

  # Méthode pour récupérer tous les utilisateurs
  def self.all
    @db = connect_db
    users = @db.execute "SELECT * FROM users"
    @db.close
    return users
  end

  # Méthode pour récupérer un utilisateur par son ID
  def self.find(user_id)
    @db = connect_db
    user_data = @db.execute "SELECT * FROM users WHERE id = ?", user_id
    user_info = User.new(user_data[0]["firstname"], user_data[0]["lastname"], user_data[0]["age"], user_data[0]["email"], user_data[0][""])
    @db.close
    return user_info
  end

  # Méthode pour mettre à jour un attribut d'un utilisateur
  def self.update(user_id, attribute, value)
    @db = connect_db
    @db.execute "UPDATE users SET #{attribute} = ? WHERE id = ?", value, user_id

    user_data = @db.execute "SELECT * FROM users WHERE id = ?", user_id
    @db.close
    return user_data
  end

  # Méthode pour authentifier un utilisateur
  def self.authenticate(password, email)
    @db = connect_db
    user_data = @db.execute "SELECT * FROM users WHERE password = ? AND email = ?", password, email
    @db.close
    return user_data
  end

  # Méthode pour supprimer un utilisateur
  def self.destroy(user_id)
    @db = connect_db
    @db.execute "DELETE FROM users WHERE id = ?", user_id
    @db.close
    return true
  end
end

