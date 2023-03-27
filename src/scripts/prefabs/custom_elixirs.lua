local elixirs = require("scripts/libraries/custom_elixirs_params.lua")

local all_prefabs = {}

local general_params = elixirs.all_elixirs
local nightmare_params = elixirs.all_nightmare_elixirs

local function priority_select(property, params)
    if params[property] then
        return params[property]
    elseif params.nightmare and nightmare_params[property] then
        return nightmare_params[property]
    end
    return general_params[property]
end

local function create_newelixir(prefab, params)
    local elixir
    -- item functions, which create the original entity (exactly one of these must run)
    if params.itemfn then
        elixir = params.itemfn(prefab, params)
    elseif params.nightmare and nightmare_params.itemfn then
        elixir = nightmare_params.itemfn(prefab, params)
    else
        elixir = general_params.itemfn(prefab, params) -- general_params.itemfn MUST be defined
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
    return elixir
end

local function create_newelixir_buff(prefab, params)
    local buff
    -- buff functions, which create the original entity (exactly one of these must run)
    if params.bufffn then
        buff = params.bufffn(prefab, params)
    elseif params.nightmare and nightmare_params.bufffn then
        buff = nightmare_params.bufffn(prefab, params)
    else
        buff = general_params.bufffn(prefab, params) -- general_params.bufffn MUST be defined
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
    return buff
end

for prefab, params in pairs(elixirs) do
    if string.startswith(prefab, "newelixir_") then
        local assets = {
            Asset("ANIM", "anim/new_elixirs.zip"),
            Asset("ANIM", "anim/abigail_buff_drip.zip"),
        }
        for _, property in ipairs({ "applyfx", "dripfx", "duration" }) do
            params[property] = priority_select(property, params)
        end
        local prefabs = {
            prefab .. "_buff",
            params.applyfx,
            params.dripfx,
        }
        local elixirfn = function() return create_newelixir(prefab, params) end
        local bufffn = function() return create_newelixir_buff(prefab, params) end
        table.insert(all_prefabs, GLOBAL.Prefab(prefab, elixirfn, assets, prefabs))
        table.insert(all_prefabs, GLOBAL.Prefab(prefab .. "_buff", bufffn))
    end
end

return unpack(all_prefabs)