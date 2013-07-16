#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

EM.run do
	puts 'Hello World.'
	EM.stop
end
