--[[
Title: HeroAnim.lua
Author(s): leio
Date: 2018/6/28
Desc: just for testing animation
]]
local state;
local last_state;
local x = 18844;
local y = 5;
local z = 19073;
function gotoForward()
    z = z - 1;
    --moveTo(x,y,z);
setPos(x,y,z)
end
function anim()
    if(state == last_state)then
        return
    end
    last_state = state;
    if(state == "walk")then
        play(0, 1000)
        --gotoForward();
        wait(1.5)
        gotoForward();
    last_state = nil    
    elseif(state == "attack")then
        play(5000, 5992)
    elseif(state == "beattacked")then
        play(6008, 6408)
    elseif(state == "wait")then
        play(6432,7743)
    end
end
function reset()
    last_state = nil;
end
while(true) do
    if(isKeyPressed("1")) then
        state = "walk";
        anim(state);
    elseif(isKeyPressed("2"))then
        state = "attack"
        anim(state);
    elseif(isKeyPressed("3"))then
        state = "beattacked"
        anim(state);
    elseif(isKeyPressed("4"))then
        state = "wait"
        anim(state);
    elseif(isKeyPressed("u"))then
        reset();
    elseif(isKeyPressed("i"))then
        turnTo(0);
    end
end