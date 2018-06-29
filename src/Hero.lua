--[[
Title: Hero.lua
Author(s): leio
Date: 2018/6/28
]]
local hero_world_x;
local hero_world_y;
local hero_world_z;

local is_show = false;
function getFacingFromOffset(dx, dy, dz)
	local len = dx^2+dz^2;
	if(len>0.01) then
		len = math.sqrt(len)
		local facing = math.acos(dx/len);
		if(dz>0) then	
			facing = -facing;
		end
		return facing;
	else
		return 0;
	end
end
function setHeroPos(x,y,z,dx,dy,dz)
    --move(dx,dy,dz);
    moveTo(x,y,z);
    _G.block_game.setHeroWorldPosition(x,y,z);

    hero_world_x = x;
    hero_world_y = y;
    hero_world_z = z;
end

function findNeighborMobs(x,z)
    local h_index = 0;
    local v_index = 0;
    local direction_index;
    for direction_index = 1,4 do 
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

        local n_x = x + h_index;
        local n_z = z + v_index;
        local mob_list = _G.block_game.mob_list;
        local k,v;
        for k,v in ipairs(mob_list)do
            if(v.health and v.health >0)then
                local next_x = v.pos[1];
                local next_z = v.pos[2];
                if(n_x == next_x and n_z == next_z)then
                    return n_x,n_z;
                end
            end
        end
    end
    
end
function checkState(path_list)
    local hero_state = _G.block_game.hero_state;

    if(hero_state == "wait")then
        playLoop(1200, 6200)
    elseif(hero_state == "attack")then
        playLoop(600, 1200)
    elseif(hero_state == "attacked")then
        playLoop(6500, 6880+2000)
    elseif(hero_state == "walking")then
        if(path_list)then
            local last_x = hero_world_x;
            local last_y = hero_world_y;
            local last_z = hero_world_z;
            local k,v;
            local len = table.getn(path_list);
            if(len < 2)then
                return
            end
            local end_block = path_list[len];
            for k = 2,len do
                local v = path_list[k];
                if(not v)then
                    return
                end
                local cur_state = _G.block_game.hero_state;
                if(cur_state == "walking")then
                    local x = v.x;
                    local y = hero_world_y;
                    local z = v.z;
    
                    local dx = x - last_x;
                    local dy = y - last_y;
                    local dz = z - last_z;
    
                    local facing = getFacingFromOffset(dx, dy, dz);
                    facing = 180 * facing/math.pi;
                    last_x = x;
                    last_y = y;
                    last_z = z;
    
                    -- only check the last waypoint
                    if(k == (len - 1))then
                        local mob_x,mob_z = findNeighborMobs(x,z);
                        if(mob_x and mob_z)then
                            local facing = getFacingFromOffset(mob_x - x, 0, mob_z - z);
                            facing = 180 * facing/math.pi;
                            turnTo(facing);
                            setHeroPos(x, y, z, dx, dy, dz);
                            _G.block_game.hero_state = "attack";
                            checkState();
                            _G.block_game.mob_state = "attacked";
                            wait(0.2);
                            return 
                        end
                    end
                    turnTo(facing);
                    playLoop(0, 500)
                    setHeroPos(x, y, z, dx, dy, dz);
                    wait(0.2);
                    if(k == len)then
                        _G.block_game.hero_state = "wait";
                        checkState();
                    end
                end
            end
        end
    end
end
registerBroadcastEvent("onBorn", function(msg)
    log("==============born hero");
    hero_world_x = msg.hero_world_x;
    hero_world_y = msg.hero_world_y;
    hero_world_z = msg.hero_world_z;
    moveTo(hero_world_x, hero_world_y, hero_world_z);
    show();
    checkState();
    focus();
end)
registerBroadcastEvent("onHeroState", function(msg)
    if(not msg)then return end
    checkState(msg.path_list)
end)
hide();