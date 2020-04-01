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

local spoil_time = 0.5 -- Arbitraty number for now


local function apply_spoil(inv_list)
    for _, itemstack in pairs(inv_list) do
        if not itemstack:is_empty() then
            local groups = itemstack:get_definition().groups
            if groups["food_wheat"] then --replace with all food check
                local meta = itemstack:get_meta()
                if meta:get("spoil_start") then
                    local spoil_start = meta:get_int("spoil_start")
                    local time = os.time()
                    local diff = time-spoil_start
                    local pct_spoiled = (diff/(spoil_time*60)*100)
                    if pct_spoiled >= 100 then
                        itemstack:clear()
                    else
                        local new_description = ("%s\n%.0f%%%s"):format(itemstack:get_definition().description, pct_spoiled, " spoiled")
                        meta:set_string("description", new_description)
                    end
                else
                    meta:set_int("spoil_start", os.time())
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

minetest.register_craftitem("civspoil:Test", {
    description = "Testing description 10% \nTesting multiline"
})

check_player_inventories()

