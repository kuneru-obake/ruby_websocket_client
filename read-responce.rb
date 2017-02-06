require "rubygems"
require "net/http"
require "uri"
require "json"
require "websocket-client-simple"
ws = WebSocket::Client::Simple.connect 'ws://localhost:8080/ws'
  M2X_HOST    = "api-m2x.att.com"
  DEVICE      = "067b12acfab95941a015fdc81312c86b"
  KEY         = "46bf8761cb7bca7cce5daca4a489f099"
  STREAM      = "ToiletStreamHM06A"
  ws.on :message do |msg|
    puts msg.data
  end

  ws.on :open do
    ws.send 'connect' + STREAM
  end

  ws.on :close do |e|
    p e
    exit 1
  end

  loop do
      value = 0
      (1..6).each do |i|
        body = Net::HTTP.start(M2X_HOST){|http| http.get("/v2/devices/#{DEVICE}/streams/#{STREAM}0#{i}/values?limit=1&pretty", "X-M2X-KEY" => "#{KEY}", "Accept" => "application/json").body}
        result = JSON.parse(body)
        value = value + (1 - result["values"][0]["value"])
      end
   ws.send value
  end