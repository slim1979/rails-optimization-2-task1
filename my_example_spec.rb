# frozen_string_literal: true

require 'rspec'
require 'rspec-benchmark'
require_relative 'task-1.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'MyBehavior' do
  before do
    File.write('control.txt',
'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
    ENV['DATA_FILE'] == 'self' ? `cat data_large.txt > test_data.txt` : `head -#{ENV['DATA_FILE']} data_large.txt > test_data.txt`
  end

  after do
    File.write('result.json', '')
    File.write('control.txt', '')
  end

  context 'when condition' do
    it 'succeeds' do
      expect { work('test_data.txt') }.to perform_under(40).sec if ENV['DATA_FILE']
      work('control.txt')
      expected_result = File.read('expected_result.json')
      expect(expected_result).to eq File.read('result.json')
    end
  end
end
