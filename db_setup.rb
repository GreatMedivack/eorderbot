require 'sqlite3'

db = SQLite3::Database.new "eorderbot.db"

rows = db.execute <<-SQL
  create table positions (
    name varchar(50),
    price int, 
    created_at date
  );
SQL