--[[
Title: Mob.lua
Author(s): leio
Date: 2018/6/28
]]
registerCloneEvent(function(msg)
    local x = msg.pos[1];
    local y = _G.block_game.hero_born_y;
    local z = msg.pos[2];
    show();
    moveTo(x, y, z);
end)
function checkState()
    local mob_state = _G.block_game.mob_state;
    if(mob_state == "wait")then
        playLoop(1500, 4500)
    elseif(mob_state == "attack")then
        playLoop(0, 600)
    elseif(mob_state == "attacked")then
        playLoop(700, 1234+500)
        playSound("worlds/DesignHouse/BlockPveGame/sounds/attacked.mp3");
    end
end
function createMob()
    local mob_list = _G.block_game.mob_list;
    local k,v;
    for k,v in ipairs(mob_list) do
        if(v.health == nil or v.health <= 0 )then
            v.health = 100;
            log("=========start to born mob");
            clone(nil,v)
        end
    end
end

registerBroadcastEvent("onRefreshMob", function(msg)
    createMob();
    checkState();
end)
hide();