--[[
Title: Map.lua
Author(s): leio
Date: 2018/6/28
Desc: just for testing map
]]
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
local map_start_x = 19200;
local map_start_y = 7;
local map_start_z = 19200;

registerCloneEvent(function(msg)
    local x = map_start_x + msg.x - 1;
    local y = map_start_y;
    local z = map_start_z + msg.z - 1;
    show();
    moveTo(x, y, z);
end)

-- create a map with assets
-- @param map_source:
-- return map_block
function generate_map(map_source)
    local map_block = {};
    local z,v;
    for z,v in ipairs(map_source) do
        local x,vv;
        for x,vv in ipairs(v) do
            local msg = {x = x, z = z,};
            local key = string.format("%d_%d",x,z);
            if(vv == 1)then
                -- create block
                clone(nil,msg);
            else
            end
            map_block[key] = vv;
        end
    end
    return map_block;
end
function start()
    local map_block = generate_map(map_source)
end
registerBroadcastEvent("onBuildMap", function(msg)
    map_source = _G.block_game.map_source or map_source;
    map_start_x = msg.map_start_x or map_start_x;
    map_start_y = msg.map_start_y or map_start_y;
    map_start_z = msg.map_start_z or map_start_z;
    start();
end)
hide();