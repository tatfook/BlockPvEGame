# BlockPvEGame
A block game for the hackathon of tatfook
### 游戏介绍
- 名称：小花不炒菜
- 游戏背景：主角小花是一位“可爱的猪猪女孩”，生活在美丽的森林中，她的爱好是炒菜，但是，突然有一天，她发现所有的食材被偷走了，非常愤怒，于是手上的炒菜铲子变成了她的武器，她要在森林中寻找到遗失的食材。
- 小组成员
    - 张磊(程序)
    - 谭雯文(美术)
### 美术资源
 - 世界地图
![image](https://user-images.githubusercontent.com/5885941/42093752-0b0586c8-7be0-11e8-9339-1cae61e03139.png)
- 主角
    - 动作
        - 待机
        - 走路
        - 攻击
        - 被攻击
![image](https://user-images.githubusercontent.com/5885941/42093835-6459d346-7be0-11e8-9463-d7568d83da32.png)
- 怪物
    - 动作
        - 待机
        - 攻击
        - 被攻击 
![image](https://user-images.githubusercontent.com/5885941/42093897-8e77cc78-7be0-11e8-8d80-b509943b3ca0.png)
- 音效
    - 游戏加载
    - 游戏开启
    - 游戏结束
    - 走路
    - 攻击
    - 被攻击 
- 贴图材质
    - [[Paracraft][64x][鲜艳]卡通材质包.zip](https://github.com/tatfook/BlockPvEGame/blob/master/worlds/%5BParacraft%5D%5B64x%5D%5B%E9%B2%9C%E8%89%B3%5D%E5%8D%A1%E9%80%9A%E6%9D%90%E8%B4%A8%E5%8C%85.zip)
- 游戏截图
![image](https://user-images.githubusercontent.com/5885941/42100936-326e7792-7bf4-11e8-9920-ca86f8227305.png)
![image](https://user-images.githubusercontent.com/5885941/42101178-df892026-7bf4-11e8-8165-6a49ba2334d8.png)

### 程序
 - 地图数据格式
    - 真实数据有36KB,尺寸132*132格
```lua
local map_source = {
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,1,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
}
```
- 算法
  - 使用了A star最短路径算法
```lua
-- @param start_x:the first value is 1,not 0
-- @param start_z:the first value is 1,not 0
-- @param end_x:the last value equals table.length()
-- @param end_z:the last value equals table.length()
function doSearch(start_x,start_z,end_x,end_z)
    if(not canSearch(start_x,start_z,end_x,end_z))then
        debug("index is invalid");
        return
    end
    local start_wp = createWayPoint(start_x,nil,start_z);
    local goal_wp = createWayPoint(end_x,nil,end_z);
    clear();
    local marked_map = {};
    local start_node = createQueueNode(0,start_wp);
    enqueue(start_node);

    while(not isEmpty())do
        local current = dequeue();
        local cur_wp = current.waypoint;

        local temp_key = createKey(cur_wp.x,cur_wp.z);
        if(not marked_map[temp_key])then
            marked_map[temp_key] = true;
            if (isSameWaypoint(cur_wp,goal_wp))then
                return getPathList(cur_wp);
            end
            local index;
            for index = 1,4 do
                local next_wp = createOrGetNeighbors(cur_wp,index);
                if(next_wp)then
                    if(canPass(next_wp))then
                        local distance = cur_wp.distance + distanceTo(cur_wp,next_wp);
                        if(next_wp.prev ~= nil)then
                            if(distance < next_wp.distance)then
                                next_wp.distance = distance;
                                next_wp.prev = cur_wp;
                            end
                        else
                            next_wp.distance = distance;
                            next_wp.prev = cur_wp;

                        end
                        local heuristics = distanceTo(next_wp,goal_wp) + distance;
                        heuristics = math.floor(heuristics);
                        local next_node = createQueueNode(heuristics,next_wp);
                        enqueue(next_node);
                    end
                end
                
            end
        end

    end
end
```
- 主循环控制输入状态
```lua 
while(true) do
    if(isKeyPressed("t")) then
        onStart();
    elseif(isKeyPressed("y"))then
        doPick();
    elseif(isMouseDown())then
        doPick();
    elseif(isKeyPressed("1"))then
        changeHeroState("attack");
    elseif(isKeyPressed("2"))then
        changeHeroState("wait");
    elseif(isKeyPressed("3"))then
        changeHeroState("attacked");
    elseif(isKeyPressed("u"))then
        reset();

    elseif(isKeyPressed("4"))then
        _G.block_game.mob_state = "attack";
    elseif(isKeyPressed("5"))then
        _G.block_game.mob_state = "wait";
    elseif(isKeyPressed("6"))then
        _G.block_game.mob_state = "attacked";
    elseif(isKeyPressed("0"))then
        exit();
        cmd("/mode edit");
    end
    
    if(is_start)then
        local now = getTimer();
        local time = now - last_time;
        --in seconds
        if(time > 5)then
            update();
            last_time = now;
        end
    end
end
```
### 功能改进
 - 更高效的优先队列算法，目前使用的是table.sort()排列数据
 - 更平滑的移动
 - 英雄和怪物之间根据不同状态，切换动画效果
 - 技能cooldown时间
 - 支持8个方向的移动，目前是4个方向
 - 英雄移动避开怪物
 - 怪物随机移动
 - 英雄/怪物生命值
 - 根据地图生成英雄/怪物位置
 - 更多的技能
### 参考
- [paracraft 课程实例](https://keepwork.com/kecheng/cs/all)
- [a-star](https://www.redblobgames.com/pathfinding/a-star/introduction.html)
- [队伍列表](https://keepwork.com/official/hackathon/1st/%E9%98%9F%E4%BC%8D%E5%88%97%E8%A1%A8)
### 源码
- [BlockPvEGame](https://github.com/tatfook/BlockPvEGame)
