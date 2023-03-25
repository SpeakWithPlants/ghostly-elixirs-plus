local elixirs = require("scripts/libraries/custom_elixirs_params.lua")

local prefabs = {}

local general_params = elixirs.all_elixirs
local nightmare_params = elixirs.all_nightmare_elixirs

local function create_newelixir(prefab, data)
    local params = elixirs[prefab]
    local elixir
    -- item functions, which create the original entity (exactly one of these must run)
    if params.itemfn then
        elixir = params.itemfn()
    elseif params.nightmare and nightmare_params.itemfn then
        elixir = nightmare_params.itemfn()
    else
        elixir = general_params.itemfn() -- general_params.itemfn MUST be defined
    end
    -- post item functions, after original entity creation
    if params.postitemfn then
        elixir = params.postitemfn(elixir)
    end
    if params.nightmare and nightmare_params.postitemfn then
        elixir = nightmare_params.postitemfn(elixir)
    end
    if general_params.postitemfn then
        elixir = general_params.postitemfn(elixir)
    end
    table.insert(prefabs, elixir)
end

local function create_newelixir_buff(prefab, data)
    local params = elixirs[prefab]
    local buff
    -- buff functions, which create the original entity (exactly one of these must run)
    if params.bufffn then
        buff = params.bufffn()
    elseif params.nightmare and nightmare_params.bufffn then
        buff = nightmare_params.bufffn()
    else
        buff = general_params.bufffn() -- general_params.bufffn MUST be defined
    end
    -- post buff functions, after original entity creation
    if params.postbufffn then
        buff = params.postbufffn(buff)
    end
    if params.nightmare and nightmare_params.postbufffn then
        buff = nightmare_params.postbufffn(buff)
    end
    if general_params.postbufffn then
        buff = general_params.postbufffn(buff)
    end
    table.insert(prefabs, buff)
end

for prefab, data in pairs(elixirs) do
    if string.startswith(prefab, "newelixir_") then
        create_newelixir(prefab, data)
        create_newelixir_buff(prefab, data)
    end
end

return unpack(prefabs)