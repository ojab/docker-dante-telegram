# frozen_string_literal: true

require 'csv'
require 'securerandom'

FILE = File.join(File.dirname(__FILE__), 'users.csv')

def users_csv
  CSV.open(FILE, 'ab+')
end

def users
  users_csv.read.to_h
end

def password
  password = ''
  loop do
    char = SecureRandom.random_bytes(1).sub(/[^[:print:]]/, '')
    password += char unless char.empty?
    return password if password.length > 15
  end
end

namespace :users do
  task :add, %i[login password] do |_t, args|
    login = args[:login] || 'telegram'

    abort("User #{login} already exists") if users.key?(login)

    users_csv << [login, args[:password] || password]
  end

  task :remove, %i[login] do |_t, args|
    old_users = users

    CSV.open(FILE, 'wb') do |csv|
      old_users.each do |login, password|
        csv << [login, password] unless login == args[:login]
      end
    end
  end

  task :replace, %i[login password] do |_t, args|
    login = args[:login] || 'telegram'

    Rake::Task['users:remove'].invoke(login)
    Rake::Task['users:add'].invoke(login, args[:password])
  end

  task :list, %i[hostname] do |_t, args|
    server = args[:hostname] || 'vpn.example.com'
    users.each do |user, pass|
      puts "tg://socks?server=#{server}&port=1080&user=#{user}&pass=#{pass}"
    end
  end
end
