local elixirs = require("scripts/libraries/custom_elixirs_params.lua")

local prefabs = {}

local general_params = elixirs.all_elixirs
local nightmare_params = elixirs.all_nightmare_elixirs

local function create_newelixir(_, params)
    local elixir
    -- item functions, which create the original entity (exactly one of these must run)
    if params.itemfn then
        elixir = params.itemfn(params)
    elseif params.nightmare and nightmare_params.itemfn then
        elixir = nightmare_params.itemfn(params)
    else
        elixir = general_params.itemfn(params) -- general_params.itemfn MUST be defined
    end
    elixir.params = params
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

local function create_newelixir_buff(_, params)
    local buff
    -- buff functions, which create the original entity (exactly one of these must run)
    if params.bufffn then
        buff = params.bufffn(params)
    elseif params.nightmare and nightmare_params.bufffn then
        buff = nightmare_params.bufffn(params)
    else
        buff = general_params.bufffn(params) -- general_params.bufffn MUST be defined
    end
    buff.params = params
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

for prefab, params in pairs(elixirs) do
    if string.startswith(prefab, "newelixir_") then
        create_newelixir(prefab, params)
        create_newelixir_buff(prefab, params)
    end
end

return unpack(prefabs)