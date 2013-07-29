#!/usr/bin/env ruby

puts RUBY_VERSION

require File.expand_path('../src/command', __FILE__)

store = StoreAccessor.new

while (line = gets.chomp.downcase) != 'end' do
  command, *args = line.split(/\s+/)

  command = 'begin_tx' if command == 'begin'  # begin is a Ruby keyword

  retval = Command.new(store).send(command, *args)

  retval = 'NULL' if retval.nil?

  puts retval if %w(get numequalto commit rollback).include?(command)
end