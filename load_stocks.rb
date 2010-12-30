require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler'

Bundler.require

require 'csv'
require 'benchmark'

@noisy = ARGV.grep("-q").none?

Benchmark.bmbm do |x|
  x.report do

    client = Riakpb::Client.new
    bucket = client["goog"]

    CSV.foreach('goog.csv', :headers => true) do |row|
      @noisy && puts row.first[1].to_s

      key = bucket[row.first[1].to_s]
      key.content.value = Hash[row.to_a]
      key.save
    end

  end
end
