--[[
Title: MapGenerator.lua
Author(s): leio
Date: 2018/6/28
Desc: a tool file for generating data source, read a bmax file and export an array source
]]
NPL.load("(gl)script/ide/mathlib.lua");
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)script/ide/math/ShapeAABB.lua");

local ShapeAABB = commonlib.gettable("mathlib.ShapeAABB");
local MapGenerator = commonlib.gettable("BlockGame.MapGenerator")

function MapGenerator.Read(input_filename,output_filename)
    local xmlRoot = ParaXML.LuaXML_ParseFile(input_filename);
	local blocks = MapGenerator.ParseBlocks(xmlRoot);
    local map_output = MapGenerator.LoadFromBlocks(blocks);
    if(map_output)then
        local file = ParaIO.open(output_filename, "w");
        if(file:IsValid()) then
            local s = commonlib.serialize(map_output)
            file:WriteString(s);
            file:close();
        end
    end
end
function MapGenerator.ParseBlocks(xmlRoot)
	if(not xmlRoot)then return end
	local node;
	local result;
	for node in commonlib.XPath.eachNode(xmlRoot, "/pe:blocktemplate/pe:blocks") do
		--find block node
		result = node;
		break;
	end
	if(not result)then return end
	return commonlib.LoadTableFromString(result[1]);
end
function MapGenerator.ForEach(blocks,callback)
    for k,v in ipairs(blocks) do
		local x = v[1];
		local y = v[2];
		local z = v[3];
		local template_id = v[4];
        local block_data = v[5];
        
        if(callback)then
            callback(x,y,z,template_id,block_data);
        end
	end
end
-- load from array of blocks
-- @param blocks: array of {x,y,z,id, data, serverdata}
function MapGenerator.LoadFromBlocks(blocks)
	if(not blocks) then
		return
	end
	local aabb = ShapeAABB:new();


    MapGenerator.ForEach(blocks,function(x,y,z,template_id,block_data)
		aabb:Extend(x,y,z);
    end)

	local blockMinX,  blockMinY, blockMinZ = aabb:GetMinValues()
    local blockMaxX,  blockMaxY, blockMaxZ = aabb:GetMaxValues();
    local width = blockMaxX - blockMinX;
	local height = blockMaxY - blockMinY;
    local depth = blockMaxZ - blockMinZ;
    
    commonlib.echo("=========min");
    commonlib.echo({blockMinX,  blockMinY, blockMinZ});
    commonlib.echo("=========max");
    commonlib.echo({blockMaxX,  blockMaxY, blockMaxZ});
    commonlib.echo("=========v");
    commonlib.echo({width,  height, depth});

    local target_y = blockMinY + 1;
    local wall_map = {}
    commonlib.echo("=========search");
    MapGenerator.ForEach(blocks,function(x,y,z,template_id,block_data)
        if(target_y == y)then
            x = x - blockMinX;
            z = z - blockMinZ;
            local key = string.format("%d_%d",x,z);
            wall_map[key] = true;
        end
    end)
    commonlib.echo("===wall_map");
    commonlib.echo(wall_map);
    local start_x = 0;
    local start_z = 0;
    local end_x = width;
    local end_z = depth;
    local map_output = {};
    for start_z = 0,end_z do
        local line = {};
        for start_x = 0,end_x do
            local key = string.format("%d_%d",start_x,start_z);
            local v;
            if(wall_map[key])then
                v = 1;
            else
                v = 0;
            end
            table.insert( line, v);
        end 
        table.insert( map_output, line);
    end
    commonlib.echo("===map_output");
    commonlib.echo(map_output);
    return map_output;
end
MapGenerator.Read("worlds/DesignHouse/BlockPveGame/blocktemplates/game_map.bmax","game_map.txt")
--MapGenerator.Read("worlds/DesignHouse/DefaultName/blocktemplates/test.bmax")