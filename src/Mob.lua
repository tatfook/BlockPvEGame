--[[
Title: Mob.lua
Author(s): leio
Date: 2018/6/28
]]
local mob_prefix_name = "mob"
function getID(id)
    local id = string.format( "%s_%d",mob_prefix_name,id);
    return id;
end
registerCloneEvent(function(msg)
    local mob = msg.mob;
    local index = msg.index;
    local id = getID(index);
    local x = mob.pos[1];
    local y = _G.block_game.hero_born_y;
    local z = mob.pos[2];

    setActorValue("id",id);
    show();
    moveTo(x, y, z);
    checkState("wait");
end)
registerBroadcastEvent("onMobState", function(msg)
    local mob_state = msg.mob_state;
    local mob_index = msg.mob_index;
    log("===onMobState");
    log(msg);
    checkState(mob_state,mob_index);
end)
function checkState(mob_state,mob_index)
    local my_id = getActorValue("id");
    log("===my_id");
    log(my_id);
    log(mob_index);
    log(mob_state);
    if(mob_state == "wait")then
        playLoop(1500, 4500)
    elseif(mob_state == "attack")then
        playLoop(0, 600)
    elseif(mob_state == "attacked")then
        if(mob_index)then
            local mob_id = getID(mob_index);
            log("==============mob_id");
            log(mob_id);
            local mob_list = _G.block_game.mob_list;
            local mob = mob_list[mob_index];
            log("======my_id");
            log(my_id);
            log(mob_id);
            if(my_id == mob_id and mob and mob.health > 0)then
                playLoop(700, 1234+500)
                playSound("worlds/DesignHouse/BlockPveGame/sounds/attacked.mp3");
                mob.health = mob.health or 0;
                mob.health = mob.health - 60;
                if(mob.health <= 0)then
                    _G.block_game.mob_count = _G.block_game.mob_count + 1;
                    local s = string.format("共击杀%d个怪物",_G.block_game.mob_count);
                    showVariable("game_tip",s,"#ff0000");
                    delete();
                end
            end
        end
        
    end
end

function createMob()
    local mob_list = _G.block_game.mob_list;
    local k,v;
    for k,v in ipairs(mob_list) do
        if(v.health == nil or v.health <= 0 )then
            v.health = 100;
            log("=========start to born mob");
            local msg = {
                mob = v,
                index = k,
            }
            clone(nil,msg)
        end
    end
end

registerBroadcastEvent("onRefreshMob", function(msg)
    createMob();
end)
hide();