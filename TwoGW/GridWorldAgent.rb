#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'
# require 'rubyOkn/StringTool'
# require 'BanditAgentQ'
require 'BaseAgent'

include BasicTool
# include StringTool;

#
# バンディット問題用のエージェント
#
class GridWorldAgent < BaseAgent
  attr_accessor :x, :y, :e, :t, :is_goal, :goal_x, :goal_y, :last_dir, :previous_x, :previous_y, :ini_x, :ini_y, :cycle, 
  :max_x, :max_y, :min_x, :min_y, :sum_reward; #書き込み、参照可能
    # attr_writer :test #書き込み可能
  # attr_reader :test #参照可能
  def initialize(conf = nil)
    conf = make_default_conf() if conf.nil? 
    super(conf) ;
    @q_table = Hash.new ;
    @x = conf[:start_x] ; 
    @y = conf[:start_y] ; 
    @ini_x = conf[:start_x] ;
    @ini_y = conf[:start_y] ; 
    @max_x = conf[:max_x] ;
    @min_x = conf[:min_x] ;
    @max_y = conf[:max_y] ;
    @min_y = conf[:min_y] ;
    create_q_table(@q_table) ;
    @e = conf[:e] ;
    @t = conf[:t] ;
    @is_goal = false ; #エージェントがゴールにいるかどうか
    @goal_x = conf[:goal_x] ; #エージェントがゴールにいるかどうか
    @goal_y = conf[:goal_y] ; #エージェントがゴールにいるかどうか
    @last_dir = nil ;
    @cycle = 0 ;
    @sum_reward= 0 ;

  end
 

  def make_default_conf
    conf = {} ;
    conf[:e] = 0.01 ;
    conf[:t] = 0.1 ;
    conf[:average_reward] = 0.0 ;
    conf[:id] = 0 ;
    conf[:a] = 0.1 ;
    conf[:start_x] = 2 ;
    conf[:start_y] = 2 ;
    conf[:goal_x] = 0 ;
    conf[:goal_y] = 0 ;
    return conf ;
  end
  
  def move_ini_pos
    @x = @ini_x ;
    @y = @ini_y ;
    @is_goal = false ; #エージェントがゴールにいるかどうか
    @average_reward = 0.0 ;
    @sum_reward = 0.0 ;
    @cycle = 0 ;
  end 
  #
  # === Qテーブルの生成
  # @param conf hash 設定hash
  # @return q_table array 生成したQテーブル
  #
  def create_q_table(q_table)
    # q_table = Array.new ; 
    # conf[:arm_num].times do |num|
    #   q_table.push(BanditAgentQ.new(num,0.0)) ;
    # end
    # return q_table ;
    x = 0 ;
    while (x <= 2)
      y = 0 ;
      while (y <= 2)
        q_table["#{x}_#{y}"] = Hash.new ;

        q_table["#{x}_#{y}"]["right"] = 0.0  if x+1 <= @max_x
        q_table["#{x}_#{y}"]["left"] = 0.0 if x-1 >= @min_x
        q_table["#{x}_#{y}"]["up"] = 0.0 if y-1 >= @min_y
        q_table["#{x}_#{y}"]["down"] = 0.0 if y+1 <= @max_y

        puts "#{x}_#{y}" ;
        y = y + 1 ;
      end
      x = x + 1 ;
    end
    return q_table ;
  end

  def act(dir)
    @previous_x = @x
    @previous_y = @y
    if dir == "up" then
      @y = @y - 1 ;
    elsif dir == "down" then
      @y = @y + 1 ;
    elsif dir == "right" then
      @x = @x + 1 ;
    else 
      @x = @x - 1 ;
    end

    @last_dir = dir ;
  end

  #
  # === q値の更新
  #
  def update_q(reward)
    begin
   @q_table["#{@previous_x}_#{@previous_y}"]["#{@last_dir}"] = @a*reward + (1-@a)*q_table["#{@previous_x}_#{@previous_y}"]["#{@last_dir}"]
   @sum_reward += reward ;
   @cycle += 1 ;
    rescue
      binding.pry ;
      end
  end 

  #
  # === egreedyによる行動選択
  # @return action integer 選択した行動
  #
  def e_greedy()
    if Random.rand <= self.e
     action = random_select_action(@q_table["#{@x}_#{@y}"].keys) ;
    else 
     action = greedy_select_action(@q_table["#{@x}_#{@y}"],@q_table["#{@x}_#{@y}"].keys) ;
    end
    return action ;
  end
  
  #
  # === greedyで行動選択
  # @return [Q] maxQ 最も期待報酬の高いQ値を返す
  #
  def greedy_select_action(table,actions)
    # q = get_q_by_id(self.state)  ;
    max_action_r = -1000000 ;
    max_action = nil ;
    #選択肢から報酬を最も得られるであろう選択を行う 
    actions.each do |action|
      if table[action] > max_action_r
        max_action = action  ;
        max_action_r = table[action] ;
      end
    end
    return max_action ; 
  end

  #
  # === randomで行動選択
  #
  def random_select_action(actions)
    id =Random.rand(actions.size) ; 
    return actions[id] ;
  end

  #
  # === ソフトマックス行動選択
  #
  def softmax
    policy_values = {} ;
    sum_policy_value = get_sum_policy_value() ;
    q_table.each do |q|
      policy_values[q.id] = Math.exp(q.r/self.t) / sum_policy_value ; 
    end  
  
    rand_value = rand() ; # 行動選択を行う際に必要になってくる乱数
    cumlation_iterater = 0.0  ; # 累積の数で判定を行うので必要
    q_table.size.times do |q_id|
      cumlation_iterater += policy_values[q_id]  ;
      if rand_value <= cumlation_iterater 
        return q_id ;
      end
    end
    return nil  ;  #プログラムに問題あり 
  end  

  #
  # === ソフトマックス法の分母を求めるメソッド
  #
  def get_sum_policy_value
    sum_policy_value = 0.0 ;
    q_table.each do |q|
      sum_policy_value += Math.exp(q.r/self.t) ;
    end 
    return sum_policy_value ;
  end

  #
  # === その他のエージェントとの当たり判定
  #
  def is_collision_agent(agent)
    if @x == agent.x && @y == agent.y
      return true ;
    else
      return false ;
    end
  end

  #
  # === 現在ゴールにいるかどうかの判定
  #
  def is_goal_pos
    if @x == @goal_x && @y == @goal_y 
      return true ;
    else
      return false ;
    end
  end
end

# #
# # 実行用
# #
# if($0 == __FILE__) then
#   
# end


