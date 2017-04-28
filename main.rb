require 'telegram/bot'
require 'sqlite3'
require './config.rb'

@db = SQLite3::Database.new DATABASE

def get_price
  date = Time.now.strftime("%Y-%m-%d")  
  list = @db.execute( "select * from positions where created_at=?",  date)
  sum = @db.execute( "select sum(price) from positions where created_at=?", date ).join.to_i
  text = ""
  list.each do |row|
    text += "#{row[0]}: #{row[1]} - #{row[2]}р.\n"
  end 
  text+= "Итого: #{sum}р."
end

def get_order(id)
  date = Time.now.strftime("%Y-%m-%d")  
  list = @db.execute( "select * from orders where created_at=? and user_id=?",  date, id)
  text = ""
  list.each do |row|
    text += "#{row[0]}: #{row[1]}\n"
  end 
  text.empty? ? "Nothing"  : text
end



Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
  	msg = message.text.partition(/\A\/[a-z]+/).reject { |c| c.empty? }
  	command = msg[0]
  	argument = msg[1].split if msg[1]
    current_user_id = @db.execute("select id from users where chat_id = ?", message.chat.id).join.to_i
    actions = message.from.id == ADMIN_ID ?  [%w(Прайс Отправить)] : [%w(Прайс Заказ)]
    categories = [%w(Водичка Еда Десерты), %w(Назад)]
    drink = [%w(Кола Пепси Пеппер Сок), %w(Пеппер_100 Чай Кафир Доширак), %w(Назад)]
    food = [%w(Биггер Бургер Бигроллы), %w(Штука_50 Ведро Боксмастер), %w(Назад)]
    desert = [%w(Киндерошоколад Буена Дилис Яйцо), %w(Марс Сникерс Твикс Баунтя), %w(Назад)]

    case command
    when '/listorder'
        bot.api.sendMessage(chat_id: message.chat.id, text: get_order(argument.first.to_i)) unless argument.nil?
    when 'Назад', '/start'
      answers =
        Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: actions, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: '......', reply_markup: answers)
    when '/order', 'Заказ'
      answers = 
        Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: categories, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: 'Категория', reply_markup: answers)
    when 'Водичка'
      answers = 
        Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: drink, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: 'Водичка', reply_markup: answers)
    when 'Еда'
      answers = 
        Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: food, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: 'Еда', reply_markup: answers)
    when 'Десерты'
      answers = 
        Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: desert, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: 'Десерты', reply_markup: answers)
    when '/add'
      if message.from.id == ADMIN_ID			
        @db.execute "insert into positions (name, price, created_at) values ( ?, ?, ? )", 
                                           argument[0], 
                                           argument[1], 
                                           Time.now.strftime("%Y-%m-%d")
        bot.api.sendMessage( chat_id: message.chat.id, 
                             text: "Добавлено #{argument[0]} - #{argument[1]}р.")
   	  end
    when '/send', 'Отправить'
         users = @db.execute "select * from users"
         users.each do |user|
            bot.api.sendMessage( chat_id: message.chat.id, text: get_price)
          end  

    when '/start'
          @db.execute "insert into users (name, chat_id) values ( ?, ? )", 
                                           message.chat.username, 
                                           message.chat.id
    when '/list', 'Прайс'
      bot.api.sendMessage(chat_id: message.chat.id, text: get_price)

    when 'Кола'
      @db.execute "insert into orders (name, user_id, created_at) values ( ?, ?, ? )", 
                                           "Кола", 
                                           current_user_id,
                                           Time.now.strftime("%Y-%m-%d")
    end
  end
end