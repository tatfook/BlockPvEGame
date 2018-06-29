--[[
Title: PathTips.lua
Author(s): leio
Date: 2018/6/28
Desc: help file
]]
local path_list;
local hero_world_x;
local hero_world_y;
local hero_world_z;
registerCloneEvent(function(msg)
    show();
    moveTo(msg.x, msg.y, msg.z);
end)

registerBroadcastEvent("onPathtips", function(msg)
    if(msg and msg.path_list)then
        local path_list = msg.path_list;
        local hero_world_y = msg.hero_world_y;
        local k,v;
        for k,v in ipairs(path_list) do
            local x = v.x;
            local y = hero_world_y;
            local z = v.z;
            clone(nil,{x = x, y = y, z = z});    
        end
    end
end)

hide();
