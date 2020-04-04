local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

local function apply_spoil(inv_list)
    for _, itemstack in pairs(inv_list) do
        if not itemstack:is_empty() then
            local groups = itemstack:get_definition().groups
            if groups["spoils"] then --replace with all food check
                local spoil_time = groups["spoils"]
                local meta = itemstack:get_meta()
                if not meta:get("spoil_start") then
                    local round_factor = 60*60 --One hour
                    local rounded_time = (math.floor(os.time()/round_factor + 0.5)*round_factor)
                    minetest.debug(rounded_time)
                    meta:set_int("spoil_start", rounded_time)
                end
                local spoil_start = meta:get_int("spoil_start")
                local time = os.time()
                local diff = time-spoil_start
                local pct_spoiled = (diff/(spoil_time*60*60*24)*100)
                if pct_spoiled < 0 then pct_spoiled = 0 end
                if pct_spoiled >= 100 then
                    itemstack:clear()
                else
                    local new_description = ("%s\n%.0f%%%s"):format(itemstack:get_definition().description, pct_spoiled, " spoiled")
                    meta:set_string("description", new_description)
                end
            end
        end
    end
    return inv_list
end

local function check_player_inventories()
    for _,player in pairs(minetest.get_connected_players()) do
       local inv = player:get_inventory()
       local main = inv:get_list("main")
       --local main2 = inv:get_list("main2")
       inv:set_list("main",apply_spoil(main))
       --apply_spoil(main2)
    end
    minetest.after(5, check_player_inventories)
end

--Hook 1: Check every 60 seconds
check_player_inventories()

--Hook 2: Check on player join
minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    local main = inv:get_list("main")
    --local main2 = inv:get_list("main2")
    inv:set_list("main",apply_spoil(main))
    --apply_spoil(main2)
end)

--Hook 3: Chest hook?