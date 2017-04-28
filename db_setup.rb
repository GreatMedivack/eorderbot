require 'sqlite3'

db = SQLite3::Database.new "eorderbot.db"

rows = db.execute <<-SQL
  create table positions (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    name varchar(50),
    price int, 
    created_at date,
    user_id integer 
  );
SQL

rows = db.execute <<-SQL
  create table users (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    name varchar(250),
    chat_id int
  );
SQL

rows = db.execute <<-SQL
  create table orders (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    name varchar(50),
    created_at date,
    user_id integer
  );
SQL
