#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'

include BasicTool
require 'cairo'

format = Cairo::FORMAT_ARGB32
width = 300
height = 200
radius = height / 3 # 半径

surface = Cairo::ImageSurface.new(format,  width,  height)
context = Cairo::Context.new(surface)

context.set_source_rgb(1,  1,  1) # 白
context.rectangle(0,  0,  width,  height)
context.fill

# 赤丸
context.set_source_rgb(1,  0,  0) # 赤
context.arc(width / 2,  height / 2,  radius,  0,  2 * Math::PI)
context.fill

surface.write_to_png("hinomaru.png")



