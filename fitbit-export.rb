#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra'
require 'oauth2'
require 'base64'
require 'influxdb'

$stdout.sync = true # docker IO buffer

influxdb = InfluxDB::Client.new "fitbit",
  host: "influxdb",
  username: "fitbit",
  password: "fitbit",
  time_precision: "s"

oauth = OAuth2::Client.new(
  ENV["OAUTH_CLIENT_ID"],
  ENV["OAUTH_CLIENT_SECRET"],
  authorize_url: "https://www.fitbit.com/oauth2/authorize",
  token_url: "https://api.fitbit.com/oauth2/token"
)

token_path = "./shared/token.yml"

if File.exist? token_path
  token_hash = YAML.load File.read(token_path)
  token = OAuth2::AccessToken.from_hash(oauth, token_hash)
else
  token = nil
end

get '/' do
  if token
    "<a href='/heartrate/#{(Date.today - 1).iso8601}'>Get yesterday's heartrate data</a>"
  else
    "<a href='/authorize'>Authorize</a>"
  end
end

get '/authorize' do
  redirect oauth.auth_code.authorize_url(scope: "heartrate")
end

get '/callback' do
  basic = Base64.encode64("#{ENV["OAUTH_CLIENT_ID"]}:#{ENV["OAUTH_CLIENT_SECRET"]}")
  token = oauth.auth_code.get_token(
    params[:code],
    headers: {
      "Authorization": "Basic #{basic}"
    }
  )
  File.open(token_path, "w") do |f|
    f.write YAML.dump(token.to_hash)
  end
  redirect "/"
end

get '/heartrate/:date' do
  res = token.get("https://api.fitbit.com/1/user/-/activities/heart/date/#{params[:date]}/1d/1sec.json")
  data = res.parsed["activities-heart-intraday"]["dataset"]
  data.map! do |x|
    {
      series: 'heartrate',
      values: { value: x["value"] },
      timestamp: Time.parse("#{params[:date]}T#{x["time"]}").to_i
    }
  end
  influxdb.write_points(data)
  "success"
end
