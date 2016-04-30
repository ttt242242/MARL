#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

#
# == 基礎的なエージェントクラス
#


$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'

include BasicTool

class BaseAgent 
  attr_accessor :id, :average_reward, :a, :q_table ;
  def initialize(agent_conf = nil)
    if agent_conf == nil
    @average_reward = 0.0 ;
    @id = agent_conf[:id] ;
    @a = agent_conf[:a] ;
    else
      @average_reward = agent_conf[:average_reward] ;
      @id = agent_conf[:id] ;
      @a = agent_conf[:a] ;
    end
    # @e = agent_conf[:e] ;
  end


  #
  # qテーブルを生成するメソッド
  #
  def create_q_table(conf=nil)
    raise 'Called abstract method !'
  end

  #
  # === q値の更新
  #
  def update_q(q_id, reward)

  end 
    
  #
  # === 平均報酬の更新
  #
  def calc_average_reward(reward, cycle)
    @average_reward = (cycle.to_f/(cycle.to_f+1.0))*@average_reward + (1.0/(cycle.to_f+1.0))* reward ;
  end

  #
  # 行動選択用のメソッド
  #
  def select_action()
    raise 'Called abstract method !'
  end

  def get_q_by_id()
    raise 'Called abstract method !'
  end
  
  #
  # === ソフトマックス行動選択
  #
  def softmax

  end

  #
  # === egreedyによる行動選択
  #
  def e_greedy
    # if Random.rand <= self.e
    #  action = random_select_action ;
    # else 
    #  action = greedy_select_action;   
    # end
    # return action ;
  end

  #
  # === greedyで行動選択
  # @return [Q] maxQ 最も期待報酬の高いQ値を返す
  #
  def greedy_select_action()
    # q = get_q_by_id(self.state)  ;
    max_action_r = -1000000 ;
    max_action = Q.new() ;
    #選択肢から報酬を最も得られるであろう選択を行う 
    q_table.each do |q|
      if q.r > max_action_r
        max_action = q  ;
        max_action_r = q.r ;
      end
    end
    return max_action.id ; 
  end

  #
  # === randomで行動選択
  #
  def random_select_action()
    action_id =Random.rand(@q_table.size) ; 
    return action_id ;
  end

  
end

#
# 実行用
#
if($0 == __FILE__) then
  
end


