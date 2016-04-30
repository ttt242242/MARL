#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require "BaseAgent"
require "GridWorldAgent"
require 'rubyOkn/BasicTool'
# require 'rubyOkn/StringTool'

include BasicTool
# include StringTool;

#
# == TwoGridWorldのメインクラス
#
class TwoGridWorld
  attr_accessor :field , :goal_info,:agents; #書き込み、参照可能
  # attr_writer :test #書き込み可能
  # attr_reader :test #参照可能

  def initialize(conf = nil)
    # conf = make_default_conf() if conf.nil? 
    # @field = conf[:field] ;  #フィールドは行列で管理
    # @goal_info = conf[:goal_info] ; # ゴール情報arrayで管理　タイルidで指定
    @agents = initialize_agents() ; # エージェントの生成
  end

  def make_default_conf
    # conf = {} ;
    # conf[:field] = 0.01 ;
   end

  #
  # === エージェントの初期化
  #
  def initialize_agents
    result_array = []  ;
    agent1 = GridWorldAgent.new() ;
    agent_conf = make_default_agent_conf() ;
    agent2 = GridWorldAgent.new(agent_conf) ;
    result_array.push(agent1) ;
    result_array.push(agent2) ;
    return result_array ;
  end

  def make_default_agent_conf
    conf = {} ;
    conf[:e] = 0.01 ;
    conf[:t] = 0.1 ;
    conf[:average_reward] = 0.0 ;
    conf[:id] = 0 ;
    conf[:a] = 0.1 ;
    conf[:start_x] = 0 ;
    conf[:start_y] = 2 ;
    conf[:goal_x] = 2 ;
    conf[:goal_y] = 0 ;
    return conf ;
  end

  #
  # === 実際にゲームを行うクラス
  #
  def run()
    # 指定した回数の繰り返し
    10.times do  

      while(!check_all_agent_goal())
        dir = nil ;
        @agents.each do |agent|
          puts "#{agent.x}, #{agent.y}"
          # エージェントが行動選択
          #エージェントがまだゴールにたどり着いてなければ
          if agent.is_goal == false
            dir = agent.e_greedy  #各行動選択法 を用いて行動選択
            agent.act(dir) ;
          end
          # 各エージェントは現在の状態から報酬を受け取り、期待報酬テーブルを更新
        end 

        # エージェント同士がぶつかった場合  
        if @agents[0].x == @agents[1].x && @agents[0].y == @agents[1].y
          @agents.each do |agent|
            if agent.is_goal == true
            else
              reward = -100
              agent.update_q(reward) ;
              agent.x = agent.previous_x ;
              agent.y = agent.previous_y ;
            end
          end
        else
          @agents.each do |agent|

            if agent.is_goal == true
            else
              if agent.x == agent.goal_x && agent.y == agent.goal_y #エージェントがゴール状態にたどり着いたら
                reward = 100 ;
                agent.is_goal = true ;
              else 
                reward = -1 ;
              end
              agent.update_q(reward) ;
            end
          end

        end

      end
        @agents.each do |agent|
          agent.move_ini_pos ;
        end


        # 結果の出力 
        # output_log() ;
    end
    end

  def check_all_agent_goal
    @agents.each do |agent|
      return false  if agent.is_goal == false
    end
      return true ;
  end
end

#
# 実行用
#
if($0 == __FILE__) then
  test = TwoGridWorld.new()  ;
  test.run() ;
  binding.pry ;
end


