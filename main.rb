require 'httparty'
require 'json'
require 'pry'
require 'colorize'

file = File.read('config.json')
config = JSON.parse(file)

address = config['address']

algo = 0
port = 0

previous_algo = algo
previous_port = port

while 1 > 0 do
  url = 'https://www.nicehash.com/api?method=simplemultialgo.info'
  response = HTTParty.get(url)
  response = JSON.parse(response)

  result = response["result"]["simplemultialgo"]

  earnings = []

  result.each do |x|
    paying = x['paying'].to_f
    hash = config[x['name']]
    earnings[x['algo']] = paying * hash
    paying = 0
    hash = 0
  end

  earnings.compact!

  puts earnings.index(earnings.max)

  result.each do |x|
    if x['algo'] == earnings.index(earnings.max)
      algo = x['name']
      port = x['port']
    end
  end

  unless previous_algo == algo
    system 'killall ccminer'
    system "ccminer -a #{algo} --url stratum+tcp://#{algo}.eu.nicehash.com:#{port} -u #{address}.miningcontrol -p x &"
    previous_algo = algo
  end

  sleep(60)
end
