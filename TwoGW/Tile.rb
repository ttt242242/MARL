#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'
require 'rubyOkn/StringTool'

include BasicTool
include StringTool;

#
# == タイルクラス
#
class Tile
  attr_accessor :id, :x, :y, :is_goal #書き込み、参照可能
  def initialize(id, x, y, is_goal=nil)
    @id = id ;
    @x = x ;
    @y = y ;
    if is_goal.nil?
      @is_goal = false ;
    else
      @is_goal = true ;
    end
  end
end


#
# 実行用
#
if($0 == __FILE__) then
  test = .new()  ;
  test.main() ;
end


