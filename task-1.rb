# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_u(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'age' => user[4]
  }
end

def parse_s(session)
  {
    :user_id => session[1],
    :session_id => session[2],
    :browser => session[3],
    :time => session[4],
    :date => session[5]
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge!(yield(user))
  end
end

def work(filename, disable_gc = true)
  puts 'Work was started'
  GC.disable if disable_gc

  file_lines = File.read(filename).split("\n").group_by{ |l| l[0] }

  users = []
  sessions = []

  file_lines.each_key do |key|
    arr = file_lines[key].map{ |value| send "parse_#{key}", value.split(',') }
    key == 'u' ? users += arr : sessions += arr
  end

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report = {}

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = sessions.map{ |s| s[:browser] }.uniq

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s[:browser].upcase }
      .sort
      .uniq
      .join(',')

  sessions = sessions.group_by { |s| s[:user_id] }

  # Статистика по пользователям
  users_objects = users.map { |user| User.new(attributes: user, sessions: sessions[user['id']]) }

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    time_map             = user.sessions.map { |s| s[:time].to_i }
    browser_map          = user.sessions.map { |s| s[:browser].upcase }
    grouped_browsers_map = browser_map.group_by { |s| s[0] }

    {
        'sessionsCount' => user.sessions.count,
        'totalTime' => "#{time_map.sum} min.",
        'longestSession' => "#{time_map.max} min.",
        'browsers' => browser_map.sort.join(', '),
        'usedIE' => (grouped_browsers_map.key? 'I'),
        'alwaysUsedChrome' => !(grouped_browsers_map.length > 1),
        'dates' => user.sessions.map { |s| s[:date] }.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
  puts 'done'
end

