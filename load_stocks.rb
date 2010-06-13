require 'riak'
require 'csv'

client = Riak::Client.new
bucket = client["goog"]

CSV.foreach('goog.csv', :headers => true) do |row|
  puts row.first[1].to_s
  key = bucket[row.first[1].to_s]
  key.content.value = Hash[row.to_a]
  key.save
end
