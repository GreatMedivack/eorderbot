require 'telegram/bot'
require 'sqlite3'

db = SQLite3::Database.new "eorderbot.db"

token = ''

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
  	msg = message.text.partition(/\A\/[a-z]+/).reject { |c| c.empty? }
  	command = msg.first
  	argument = msg.last.split
    case command
    when '/start'
      bot.api.sendMessage(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/add'
      db.execute "insert into positions values ( ?, ?, ? )", argument[0], argument[1], Time.now.strftime("%Y-%m-%d")
      bot.api.sendMessage(chat_id: message.chat.id, text: "Added #{argument[0]} - #{argument[1]}р. \n #{Time.now.strftime("%Y-%m-%d")}")
    when '/list'
      date = Time.now.strftime("%Y-%m-%d")	
      list = db.execute( "select * from positions where created_at=?",  date)
      sum = db.execute( "select sum(price) from positions where created_at=?", date ).join.to_i
      text = ""
      list.each do |row|
      	text += "#{row[0]} - #{row[1]}р.\n"
      end	
      text+= "Итого: #{sum}р."
      bot.api.sendMessage(chat_id: message.chat.id, text: text)
    end
  end
end