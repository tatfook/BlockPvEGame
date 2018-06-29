--[[
Title: Astar.lua
Author(s): leio
Date: 2018/6/28
]]
local priority_queue = {};
local waypoints_map = {};
local map_source = nil;


function debug(s)
    --commonlib.echo(s);
    log(s)
end
--priority_queue------------------------------------------------begin
-- @param node: an input table, the value of index is unique
-- the lesser value is on the first
function enqueue(node)
    if(not node or node.index == nil)then
        return
    end
    table.insert(priority_queue,node);
    table.sort( priority_queue, function(a,b)
        return a.index < b.index;
    end)
end

function dequeue()
    local first_index = 1;
    local node = priority_queue[first_index];
    if(node)then
        table.remove(priority_queue,first_index);
    end
    return node;
end
function isEmpty()
    local len = table.getn(priority_queue);
    if(len == 0)then
        return true;
    end
end
function clear()
    priority_queue = {};
    waypoints_map = {};
end

--priority_queue------------------------------------------------end

--create a waypoint
function createWayPoint(x,y,z,distance,prev,block_value)
    x = x or 0;
    y = y or 0;
    z = z or 0;
    distance = distance or 0;
    prev = prev or nil;
    block_value = block_value or nil;
    
    local wp = {
        x = x,
        y = y,
        z = z,
        distance = distance,
        prev = prev,
        block_value = block_value,
    }
    return wp;
end
--create a queue node
function createQueueNode(priority,waypoint)
    local node = {
        index = priority,
        waypoint = waypoint,
    }
    return node;
end
function createKey(x,z)
    return string.format( "%d_%d",x,z);
end
-- @param waypoint
-- @param direction_index: 1 <= direction_index <= 4
function createOrGetNeighbors(waypoint,direction_index)
    if(not waypoint or not direction_index or not map_source)then
        debug("can't create neighbors!");
        return
    end
    local h_index = 0;
    local v_index = 0;
    if(direction_index == 1)then
        --left
        h_index = -1;
        v_index = 0;
    elseif(direction_index == 2)then
        --top
        h_index = 0;
        v_index = -1;
    elseif(direction_index == 3)then
        --right
        h_index = 1;
        v_index = 0;
    elseif(direction_index == 4)then
        --bottom
        h_index = 0;
        v_index = 1;
    end
    local x = waypoint.x + h_index;
    local z = waypoint.z + v_index;
    local max_x = table.getn(map_source[1]);
    local max_z = table.getn(map_source);
    if(x < 1 or z < 1 or x > max_x or z > max_z)then
        return
    end
    local block_value = map_source[z][x];
    local key = createKey(x,z);
    local wp = waypoints_map[key]
    if(not wp)then
        wp = createWayPoint(x,0,z,0,nil,block_value)
        waypoints_map[key] = wp;
    end
    return wp;
end
function isSameWaypoint(wp_1,wp_2)
    if(wp_1 and wp_2)then
        local key_1 = createKey(wp_1.x,wp_1.z);
        local key_2 = createKey(wp_2.x,wp_2.z);
        if(key_1 == key_2)then
            return true;
        end
    end
end
function canPass(wp)
    if(wp and wp.block_value == 0)then
        return true;
    end
end
function canSearch(start_x,start_z,end_x,end_z)
    local max_x = table.getn(map_source[1]);
    local max_z = table.getn(map_source);
    if(start_x < 1 or start_z < 1 or start_x > max_x or start_z > max_z
        or end_x < 1 or end_z < 1 or end_x > max_x or end_z > max_z
)then
        return false
    end
    return true;
end

function distanceTo(wp1,wp2)
    if(not wp1 or not wp2)then
        return 0;
    end
    local dx = wp1.x - wp2.x;
    local dy = wp1.y - wp2.y;
    local dz = wp1.z - wp2.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
end
function getPathList(wp)
    local list = {};
    while(wp) do
        table.insert(list,wp);
        wp = wp.prev;
    end
    local result = {};
    local len = table.getn(list);
    while(len > 0)do
        local wp = list[len];
        wp.prev = nil;
        table.insert(result,wp);
        len = len - 1;
    end
    return result;
end
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
registerBroadcastEvent("onSearching", function(msg)
    local start_x = msg.start_x;
    local start_z = msg.start_z;
    local end_x = msg.end_x;
    local end_z = msg.end_z;
    map_source = _G.block_game.map_source or map_source;
    debug("=========doSearch");
    debug(msg);
    local path_list = doSearch(start_x,start_z,end_x,end_z);
    debug("=========path_list");
    if(path_list)then
        local msg = {
            path_list = path_list,
        }
        debug(path_list);
        broadcast("onSearchFinished",msg);
    end
end)

