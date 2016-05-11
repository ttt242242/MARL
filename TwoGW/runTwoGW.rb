#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require "BaseAgent"
require "GridWorldAgent"
require "TwoGridWorld"


test = TwoGridWorld.new()  ;
test.run() ;

