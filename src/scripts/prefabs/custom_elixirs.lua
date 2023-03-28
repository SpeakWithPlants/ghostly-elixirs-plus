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
    -- general_params.itemfn MUST be defined
    local elixir = params.itemfn(prefab, params)
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
    -- general_params.bufffn MUST be defined
    local buff = params.bufffn(prefab, params)
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
        -- define which properties overwrite their parent properties
        local priority_properties = {
            "duration",
            "tickrate",
            "applyfx",
            "dripfx",
            "dripfxfn",
            "driptaskfn",
            "onattachfn",
            "ondetachfn",
            "onextendfn",
            "itemfn",
            "bufffn"
        }
        local explicit_params = {}
        for _, property in ipairs(priority_properties) do
            explicit_params[property] = priority_select(property, params)
        end
        local prefabs = {
            prefab .. "_buff",
            explicit_params.applyfx,
            explicit_params.dripfx,
        }
        local elixirfn = function() return create_newelixir(prefab, explicit_params) end
        local bufffn = function() return create_newelixir_buff(prefab, explicit_params) end
        table.insert(all_prefabs, GLOBAL.Prefab(prefab, elixirfn, assets, prefabs))
        table.insert(all_prefabs, GLOBAL.Prefab(prefab .. "_buff", bufffn))
    end
end

return unpack(all_prefabs)