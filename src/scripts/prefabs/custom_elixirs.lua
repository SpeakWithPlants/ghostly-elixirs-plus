local elixirs = require "libraries/custom_elixirs_params"

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
    -- post item functions, after original entity creation
    if elixirs[prefab].postitemfn then
        elixir = elixirs[prefab].postitemfn(elixir)
    end
    if elixirs[prefab].nightmare and nightmare_params.postitemfn then
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
    -- post buff functions, after original entity creation
    if elixirs[prefab].postbufffn then
        buff = elixirs[prefab].postbufffn(buff)
    end
    if elixirs[prefab].nightmare and nightmare_params.postbufffn then
        buff = nightmare_params.postbufffn(buff)
    end
    if general_params.postbufffn then
        buff = general_params.postbufffn(buff)
    end
    return buff
end

for _, prefab in ipairs(elixirs.new_elixir_prefabs) do
    local raw_params = elixirs[prefab]
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
        "enddriptaskfn",
        "onattachfn",
        "ondetachfn",
        "onextendfn",
        "ontimerdonefn",
        "itemfn",
        "bufffn"
    }
    local explicit_params = {}
    for _, property in ipairs(priority_properties) do
        explicit_params[property] = priority_select(property, raw_params)
    end
    explicit_params.nightmare = raw_params.nightmare or false
    local prefabs = {
        prefab .. "_buff",
        explicit_params.applyfx,
        explicit_params.dripfx,
    }
    local elixirfn = function() return create_newelixir(prefab, explicit_params) end
    local bufffn = function() return create_newelixir_buff(prefab, explicit_params) end
    table.insert(all_prefabs, Prefab(prefab, elixirfn, assets, prefabs))
    table.insert(all_prefabs, Prefab(prefab .. "_buff", bufffn))
end

return unpack(all_prefabs)