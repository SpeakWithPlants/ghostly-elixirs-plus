local elixirs = {}

--------------------------------------------------------------------------
--[[ newelixir_sanityaura ]]
--------------------------------------------------------------------------
elixirs.newelixir_sanityaura =
{
    nightmare = false,
    duration = TUNING.TOTAL_DAY_TIME,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "ghostlyelixir_slowregen_dripfx",
}
elixirs.newelixir_sanityaura.bufffn = function(_, _)
    local inst = GLOBAL.CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then return inst end

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.NEW_ELIXIRS.SANITYAURA.AURA

    return inst

    --return post_init_buff_fn(inst, elixir_type, data) TODO use generalized buff prefab function
end

--------------------------------------------------------------------------
--[[ newelixir_lightaura ]]
--------------------------------------------------------------------------
elixirs.newelixir_lightaura =
{
    nightmare = false,
    duration = TUNING.TOTAL_DAY_TIME,
    applyfx = "ghostlyelixir_attack_fx",
    dripfx = "ghostlyelixir_attack_dripfx",
}
elixirs.newelixir_lightaura.bufffn = function(_, _)
    local inst = GLOBAL.CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(TUNING.NEW_ELIXIRS.LIGHTAURA.LIGHT_RADIUS)
    inst.Light:SetFalloff(1)
    inst.Light:Enable(true)
    inst.Light:SetColour(255 / 255, 160 / 255, 160 / 255)

    inst.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then return inst end

    inst:AddComponent("heater")
    inst.components.heater.heat = TUNING.NEW_ELIXIRS.LIGHTAURA.TEMPERATURE

    return inst
    --return post_init_buff_fn(inst, elixir_type, data) TODO use generalized buff prefab function
end

--------------------------------------------------------------------------
--[[ newelixir_healthdamage ]]
--------------------------------------------------------------------------
elixirs.newelixir_healthdamage =
{
    nightmare = false,
    duration = TUNING.TOTAL_DAY_TIME,
    applyfx = "ghostlyelixir_retaliation_fx",
    dripfx = "ghostlyelixir_retaliation_dripfx",
}
-- TODO define damage function

--------------------------------------------------------------------------
--[[ newelixir_cleanse ]]
--------------------------------------------------------------------------
elixirs.newelixir_cleanse =
{
    nightmare = false,
    duration = 0,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "ghostlyelixir_slowregen_dripfx",
}
elixirs.newelixir_cleanse.onattachfn = function(_, abigail)
    local healing = abigail.components.health:GetMaxWithPenalty() * TUNING.NEW_ELIXIRS.CLEANSE.HEALTH_GAIN
    abigail.components.health:DoDelta(healing)
    if abigail._playerlink ~= nil then
        abigail._playerlink.components.sanity:DoDelta(TUNING.NEW_ELIXIRS.CLEANSE.SANITY_GAIN)
    end
end

--------------------------------------------------------------------------
--[[ newelixir_insanitydamage ]]
--------------------------------------------------------------------------
elixirs.newelixir_insanitydamage =
{
    nightmare = true,
    duration = TUNING.TOTAL_DAY_TIME / 2,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "shadow_trap_debuff_fx",
}
-- TODO define dripfxfn
-- TODO define damage function

--------------------------------------------------------------------------
--[[ newelixir_shadowfighter ]]
--------------------------------------------------------------------------
elixirs.newelixir_shadowfighter =
{
    nightmare = true,
    duration = TUNING.TOTAL_DAY_TIME / 2,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "thurible_smoke",
}
-- TODO define dripfxfn, this might go in onattach?
elixirs.newelixir_shadowfighter.postinit_vex = function(buff)
    -- TODO define postinit vex function
end
elixirs.newelixir_shadowfighter.postinit_wendy = function(wendy)
    -- TODO define custom vex damage for wendy
    -- inst.components.combat.customdamagemultfn = CustomCombatDamage
end
elixirs.newelixir_shadowfighter.onattachfn = function(_, abigail)
    abigail:AddTag("crazy") -- allows abigail to attack shadow creatures
end
elixirs.newelixir_shadowfighter.ondetachfn = function(_, abigail)
    abigail:RemoveTag("crazy")
end

--------------------------------------------------------------------------
--[[ newelixir_lightning ]]
--------------------------------------------------------------------------
elixirs.newelixir_lightning =
{
    nightmare = true,
    duration = TUNING.TOTAL_DAY_TIME / 2,
    applyfx = "ghostlyelixir_attack_fx",
    dripfx = "electrichitsparks",
}
elixirs.newelixir_lightning.smitefn = function(target)
    if math.random() < TUNING.NEW_ELIXIRS.LIGHTNING.SMITE_CHANCE then
        local x, y, z = target.Transform:GetWorldPosition()
        if target.components.aura ~= nil then
            local necessarytags = { "_combat" }
            local ignoretags = target.components.aura.auraexcludetags or {}
            local radius = target.components.aura.radius or 4
            local entities = GLOBAL.TheSim:FindEntities(x, y, z, radius, necessarytags, ignoretags)
            local smitees = {}
            local found = false
            for i, entity in ipairs(entities) do
                if target:auratest(entity) and entity.components.health ~= nil and not entity.components.health:IsDead() then
                    smitees[i] = entity
                    found = true
                end
            end
            if not found then return end
            local smitee = GLOBAL.GetRandomItem(smitees)
            if smitee ~= nil then
                GLOBAL.TheWorld:PushEvent("ms_sendlightningstrike", smitee:GetPosition())
            end
        end
    end
end
elixirs.newelixir_lightning.onareaattackotherfn = function(_, data)
    local target = data ~= nil and data.target
    if target ~= nil then
        elixirs.lightning.smitefn(target)
    end
end
elixirs.newelixir_lightning.onattachfn = function(buff, abigail)
    if abigail.components.electricattacks == nil then
        abigail:AddComponent("electricattacks")
    end
    abigail.components.electricattacks:AddSource(buff)
    abigail:ListenForEvent("onareaattackother", elixirs.lightning.onareaattackotherfn)
end
elixirs.newelixir_lightning.ondetachfn = function(buff, abigail)
    if abigail.components.electricattacks ~= nil then
        abigail.components.electricattacks:RemoveSource(buff)
    end
    abigail:RemoveEventCallback("onareaattackother", elixirs.lightning.onareaattackotherfn)
end

--------------------------------------------------------------------------
--[[ all elixirs ]]
--------------------------------------------------------------------------
elixirs.all_elixirs = {}
elixirs.all_elixirs.itemfn = function()
    -- TODO general inventory item prefab function
end
elixirs.all_elixirs.bufffn = function()
    -- TODO general buff prefab function
end

--------------------------------------------------------------------------
--[[ all nightmare elixirs ]]
--------------------------------------------------------------------------
elixirs.all_nightmare_elixirs = {}
elixirs.all_nightmare_elixirs.postbufffn = function(buff)
    buff.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then return buff end

    buff:AddComponent("sanityaura")
    buff.components.sanityaura.aura = TUNING.NEW_ELIXIRS.ALL_NIGHTMARE_ELIXIRS.SANITYAURA

    return buff
end

-- this one is just for copy/pasting
--[[
newelixir_unused = {
    nightmare = false,
    duration = TUNING.TOTAL_DAY_TIME,
    fn = function(elixir_type, data) end,
    onattachfn = function(buff, abigail) end,
    ontick = function(buff, abigail) end,
    ondetachfn = function(buff, abigail) end,
    fx = "ghostlyelixir_slowregen_fx",
    dripfx = "ghostlyelixir_slowregen_dripfx",
},
]]

return elixirs