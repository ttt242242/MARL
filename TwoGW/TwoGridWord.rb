#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require "BaseAgent"
require "GridWorldAgent"
require 'rubyOkn/BasicTool'
require 'rubyOkn/GenerateGraph'
# require 'rubyOkn/StringTool'

include BasicTool
# include StringTool;

#
# == TwoGridWorldのメインクラス
#
class TwoGridWorld
  attr_accessor :field , :goal_info,:agents, :game_num; #書き込み、参照可能
  # attr_writer :test #書き込み可能
  # attr_reader :test #参照可能

  def initialize(conf = nil)
    game_conf = make_default_conf() if conf.nil? 
    # @field = conf[:field] ;  #フィールドは行列で管理
    # @goal_info = conf[:goal_info] ; # ゴール情報arrayで管理　タイルidで指定
    @agents = initialize_agents() ; # エージェントの生成
    @game_num = game_conf[:game_num] ;   #ゲームを何回するかを決定
  end

  def make_default_conf
    conf = {} ;
    conf[:game_num] = 100 ;
    return conf ;
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

  #
  # === エージェントの設定
  #
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
  # === ゲームを行うメソッド
  #
  def run()
    # 指定した回数の繰り返し
    step_num_to_goal = [] ;
    step_num_to_goal2 = [] ;
    step = 0 ;
    @game_num.times do |cycle|
      step = 0  ;
      while(!check_all_agent_goal())  #全エージェントがゴールするまで繰り返し
        all_agent_act() ;   #全エージェントが行動選択
        evaluate_all_agent(cycle) ;
        # エージェント同士がぶつかった場合  
        step += 1 ;
      end
      # 結果の出力 
      # step_num_to_goal.push(step) ;
      puts step ;
      # step_num_to_goal.push(( @agents[0].average_reward + @agents[1].average_reward )/2.0) ;
      step_num_to_goal.push(@agents[0].cycle) ;
      step_num_to_goal2.push(@agents[1].cycle) ;
      all_agent_move_ini_pos ;
    end
    result_array = [] ;
    result_array.push(step_num_to_goal) ;
    result_array.push(step_num_to_goal2) ;
    graph_conf = GenerateGraph.make_default_conf("test") ;
    GenerateGraph.list_time_step(result_array,graph_conf) ;
    makeYamlFile("test.yml", result_array) ;
  end

  #
  # ===  全エージェントが行動選択
  #
  def all_agent_act
    @agents.each do |agent|
      #エージェントがまだゴールにたどり着いてなければ
      if agent.is_goal == false
        dir = agent.e_greedy  #各行動選択法 を用いて行動選択
        agent.act(dir) ;
      end
    end 
  end


  #
  # ===全エージェントの評価を行う
  #
  def evaluate_all_agent(cycle)
    # エージェント同士がぶつかった場合  
    if @agents[0].is_collision_agent(@agents[1])
      @agents.each do |agent|
        if agent.is_goal == false
          reward = -100
          agent.update_q(reward) ;
          agent.calc_average_reward(reward, cycle) ;
          agent.x = agent.previous_x ;
          agent.y = agent.previous_y ;
        end
      end
    else   #エージェント同士がぶつからなければ 
      @agents.each do |agent|
        if agent.is_goal == false
          reward = nil ;
          if agent.is_goal_pos #エージェントがゴール状態にたどり着いたら
            reward = 100 ;
            agent.is_goal = true ;
          else 
            reward = -1 ;
          end
          agent.update_q(reward) ;
          agent.calc_average_reward(reward, cycle) ;
        end
      end
    end
  end

  #
  #
  #
  def all_agent_move_ini_pos
    @agents.each do |agent|
      agent.move_ini_pos ;
    end

  end
  #
  # === 全エージェントがゴールに到達したかどうかを確認する
  #
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
end


