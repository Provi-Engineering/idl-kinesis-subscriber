require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)
require 'aws-sdk-kinesis'
require 'aws/kclrb'