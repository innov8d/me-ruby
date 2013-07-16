#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

EM.run do
	puts "[#{Thread.current.object_id}] In run loop."

	EM.defer do
		puts "[#{Thread.current.object_id}] I'm on a thread"
		sleep(2)
		puts "[#{Thread.current.object_id}] First sleepy"
	end

	EM.defer do
		puts "[#{Thread.current.object_id}] a cool thread"
		sleep(1)
		puts "[#{Thread.current.object_id}] Second sleepy"
	end

	op = Proc.new { puts "[#{Thread.current.object_id}] OPERATION"; [1, 2] }
	cb = Proc.new { |first, second| puts "[#{Thread.current.object_id}] CALLBACK #{first} #{second}"}

	EM.defer(op, cb)
end
