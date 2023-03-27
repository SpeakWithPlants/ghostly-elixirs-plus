local elixirs = {}

--[[
 Usable Functions:
 itemfn(prefab, params)                                      - creates the elixir item that wendy uses
 bufffn(prefab, params)                                      - creates the invisible buff object attached to abigail
 onattachfn(buff, target, followsymbol, followoffset, data)  - executed when the buff is added to abigail
 ontickfn(buff, target)                                      - executed at the buff's tick rate until detached
 ondetachfn(buff, target, followsymbol, followoffset, data)  - executed when the buff is removed from abigail
 onextendfn(buff, target, followsymbol, followoffset, data)  - executed when the buff is reapplied to abigail
 ontimerdonefn(buff, data { timername })                     - executed immediately before the buff is removed from abigail due to expiration
]]--

--------------------------------------------------------------------------
--[[ all elixirs ]]
--------------------------------------------------------------------------
elixirs.all_elixirs = {
    duration = TUNING.TOTAL_DAY_TIME,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "ghostlyelixir_slowregen_dripfx",
}
elixirs.all_elixirs.itemfn = function(prefab, params)
    local elixir = GLOBAL.CreateEntity()

    elixir.entity:AddTransform()
    elixir.entity:AddAnimState()
    elixir.entity:AddNetwork()

    GLOBAL.MakeInventoryPhysics(elixir)

    elixir.AnimState:SetBank("new_elixirs")
    elixir.AnimState:SetBuild("new_elixirs")
    elixir.AnimState:PlayAnimation(string.gsub(prefab, "newelixir_", "", 1))

    elixir:AddTag("ghostlyelixir")

    GLOBAL.MakeInventoryFloatable(elixir)

    elixir.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then return elixir end

    elixir.params = params

    elixir:AddComponent("inspectable")
    elixir:AddComponent("inventoryitem")
    elixir.components.inventoryitem.imagename = prefab
    elixir.components.inventoryitem.atlasname = "images/inventoryimages/" .. prefab .. ".xml"
    elixir:AddComponent("stackable")
    elixir:AddComponent("ghostlyelixir")
    elixir:AddComponent("fuel")
    elixir.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    return elixir
end
elixirs.all_elixirs.bufffn = function(_, params)
    local buff = GLOBAL.CreateEntity()

    if not GLOBAL.TheWorld.ismastersim then
        -- Not meant for client!
        buff:DoTaskInTime(0, buff.Remove)
        return buff
    end

    buff.entity:AddTransform()
    buff.entity:Hide()
    buff.persists = false

    buff.params = params

    buff:AddTag("CLASSIFIED")

    buff:AddComponent("debuff")
    buff.components.debuff:SetAttachedFn(params.onattachfn)
    buff.components.debuff:SetDetachedFn(params.ondetachfn)
    buff.components.debuff:SetExtendedFn(params.onextendfn)
    buff.components.debuff.keepondespawn = true
    buff:AddComponent("timer")
    buff.components.timer:StartTimer("decay", params.duration)
    if params.ontimerdonefn ~= nil then
        buff:ListenForEvent("timerdone", params.ontimerdonefn)
    end

    return buff
end

--------------------------------------------------------------------------
--[[ all nightmare elixirs ]]
--------------------------------------------------------------------------
elixirs.all_nightmare_elixirs = {
    duration = TUNING.TOTAL_DAY_TIME / 2,
}
elixirs.all_nightmare_elixirs.donightmareburst = function(abigail, sanity, scale, range_end, range_start)
    scale = (scale or 1.0) * 1.5
    range_end = range_end or 10.0
    range_start = range_start or 5.0
    if range_start == range_end then
        range_end = range_start + 1
    end
    local abigail_pos = abigail.Transform:GetWorldPosition()
    local x, y, z = abigail_pos
    local necessary_tags = { "player" }
    local nearby_players = GLOBAL.TheSim:FindEntities(x, y, z, range_end, necessary_tags)
    for _, p in ipairs(nearby_players) do
        if p.components.sanity ~= nil then
            local player_pos = p.Transform:GetWorldPosition()
            local distance = (player_pos - abigail_pos):Length()
            local distance_proportion = (distance - range_start) / (range_end - range_start)
            local distance_multiplier = 1.0 - (math.max(0.0, math.min(1.0, distance_proportion)))
            p.components.sanity:DoDelta(sanity * distance_multiplier)
        end
    end
    local nightmare_burst = GLOBAL.SpawnPrefab("stalker_shield")
    nightmare_burst.Transform:SetPosition(abigail:GetPosition():Get())
    nightmare_burst.AnimState:SetScale(scale, scale, scale)
    abigail.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
end
elixirs.all_nightmare_elixirs.ontimerdonefn = function(buff)
    if buff.target ~= nil and buff.target.prefab == "abigail" then
        -- do small nightmare burst if a nightmare elixir reaches the end of its duration
        elixirs.all_nightmare_elixirs.donightmareburst(buff.target, -TUNING.SANITY_LARGE, 1.2, 7.0, 3.0)
    end
end
elixirs.all_nightmare_elixirs.postbufffn = function(buff)
    if not GLOBAL.TheWorld.ismastersim then return buff end

    buff:AddComponent("sanityaura")
    buff.components.sanityaura.aura = TUNING.NEW_ELIXIRS.ALL_NIGHTMARE_ELIXIRS.SANITYAURA

    return buff
end

--------------------------------------------------------------------------
--[[ newelixir_sanityaura ]]
--------------------------------------------------------------------------
elixirs.newelixir_sanityaura =
{
    nightmare = false,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "ghostlyelixir_slowregen_dripfx",
}
elixirs.newelixir_sanityaura.postbufffn = function(buff)
    if not GLOBAL.TheWorld.ismastersim then return buff end

    buff:AddComponent("sanityaura")
    buff.components.sanityaura.aura = TUNING.NEW_ELIXIRS.SANITYAURA.AURA

    return buff
end

--------------------------------------------------------------------------
--[[ newelixir_lightaura ]]
--------------------------------------------------------------------------
elixirs.newelixir_lightaura =
{
    nightmare = false,
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

    return inst
end
elixirs.newelixir_lightaura.postbufffn = function(buff)
    if not GLOBAL.TheWorld.ismastersim then return buff end

    buff:AddComponent("heater")
    buff.components.heater.heat = TUNING.NEW_ELIXIRS.LIGHTAURA.TEMPERATURE

    return buff
end

--------------------------------------------------------------------------
--[[ newelixir_healthdamage ]]
--------------------------------------------------------------------------
elixirs.newelixir_healthdamage =
{
    nightmare = false,
    applyfx = "ghostlyelixir_retaliation_fx",
    dripfx = "ghostlyelixir_retaliation_dripfx",
}
elixirs.newelixir_healthdamage.calcmultiplier_wendyvex = function(wendy)
    if wendy.components.health ~= nil then
        local health_percent = wendy.components.health:GetPercent()
        local tuning = TUNING.NEW_ELIXIRS.HEALTHDAMAGE
        if health_percent <= tuning.LOW_HEALTH then
            return tuning.WENDYVEX.BONUS_DAMAGE_MULT
        end
        local deltaY = tuning.WENDYVEX.MIN_DAMAGE_MULT - tuning.WENDYVEX.MAX_DAMAGE_MULT
        local deltaX = tuning.HIGH_HEALTH - tuning.LOW_HEALTH
        if deltaX == 0 then
            return tuning.WENDYVEX.MAX_DAMAGE_MULT
        end
        local m = deltaY / deltaX
        return m * (health_percent - tuning.HIGH_HEALTH) + tuning.WENDYVEX.MIN_DAMAGE_MULT
    end
    return TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD
end
elixirs.newelixir_healthdamage.calcmultiplier_abigail = function(wendy)
    if wendy.components.health ~= nil then
        local health_percent = wendy.components.health:GetPercent()
        local tuning = TUNING.NEW_ELIXIRS.HEALTHDAMAGE
        if health_percent <= tuning.LOW_HEALTH then
            return tuning.ABIGAIL.BONUS_DAMAGE_MULT
        end
        local deltaY = tuning.ABIGAIL.MIN_DAMAGE_MULT - tuning.ABIGAIL.MAX_DAMAGE_MULT
        local deltaX = tuning.HIGH_HEALTH - tuning.LOW_HEALTH
        if deltaX == 0 then
            return tuning.ABIGAIL.MAX_DAMAGE_MULT
        end
        local m = deltaY / deltaX
        return m * (health_percent - tuning.HIGH_HEALTH) + tuning.ABIGAIL.MIN_DAMAGE_MULT
    end
    return 1
end
elixirs.newelixir_healthdamage.postinit_wendy = function(wendy)
    if wendy.components.combat ~= nil then
        local old_customdamagemultfn = wendy.components.combat.customdamagemultfn
        wendy.components.combat.customdamagemultfn = function(self, target)
            local abigail = self.components.ghostlybond ~= nil and self.components.ghostlybond.ghost
            local active_elixir = abigail:GetDebuff("elixir_buff")
            if target:HasDebuff("abigail_vex_debuff") and active_elixir == "newelixir_healthdamage_buff" then
                return elixirs.newelixir_healthdamage.calcmultiplier_wendyvex(self)
            end
            return old_customdamagemultfn(self, target)
        end
    end
end
elixirs.newelixir_healthdamage.ontickfn = function(buff, abigail)
    if abigail ~= nil and abigail.components.combat ~= nil then
        if abigail._playerlink ~= nil then
            local wendy = abigail._playerlink
            local multiplier = elixirs.newelixir_healthdamage.calcmultiplier_abigail(wendy)
            abigail.components.combat.externaldamagemultipliers:SetModifier(buff, multiplier)
        end
    end
end
elixirs.newelixir_healthdamage.ondetachfn = function(buff, abigail)
    if abigail.components.combat ~= nil then
        abigail.components.combat.externaldamagemultipliers:RemoveModifier(buff)
    end
end
-- TODO implement damage functions in postinit

--------------------------------------------------------------------------
--[[ newelixir_insanitydamage ]]
--------------------------------------------------------------------------
elixirs.newelixir_insanitydamage =
{
    nightmare = true,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "shadow_trap_debuff_fx",
}
elixirs.newelixir_insanitydamage.calcmultiplier_wendyvex = function(_, abigail)
    if abigail._playerlink ~= nil then
        local wendy = abigail._playerlink
        if wendy.components.sanity ~= nil then
            local sanity_percent = wendy.components.sanity:GetPercent()
            local tuning = TUNING.NEW_ELIXIRS.INSANITYDAMAGE
            if sanity_percent <= tuning.LOW_SANITY then
                return tuning.WENDYVEX.BONUS_DAMAGE_MULT
            end
            local deltaY = tuning.WENDYVEX.MIN_DAMAGE_MULT - tuning.WENDYVEX.MAX_DAMAGE_MULT
            local deltaX = tuning.HIGH_SANITY - tuning.LOW_SANITY
            if deltaX == 0 then
                return tuning.WENDYVEX.MAX_DAMAGE_MULT
            end
            local m = deltaY / deltaX
            return m * (sanity_percent - tuning.HIGH_SANITY) + tuning.WENDYVEX.MIN_DAMAGE_MULT
        end
    end
    return TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD
end
elixirs.newelixir_insanitydamage.calcmultiplier_abigail = function(_, abigail)
    if abigail._playerlink ~= nil then
        local wendy = abigail._playerlink
        if wendy.components.sanity ~= nil then
            local sanity_percent = wendy.components.sanity:GetPercent()
            local tuning = TUNING.NEW_ELIXIRS.INSANITYDAMAGE
            if sanity_percent <= tuning.LOW_SANITY then
                return tuning.ABIGAIL.BONUS_DAMAGE_MULT
            end
            local deltaY = tuning.ABIGAIL.MIN_DAMAGE_MULT - tuning.ABIGAIL.MAX_DAMAGE_MULT
            local deltaX = tuning.HIGH_SANITY - tuning.LOW_SANITY
            if deltaX == 0 then
                return tuning.ABIGAIL.MAX_DAMAGE_MULT
            end
            local m = deltaY / deltaX
            return m * (sanity_percent - tuning.HIGH_SANITY) + tuning.ABIGAIL.MIN_DAMAGE_MULT
        end
    end
    return 1
end
elixirs.newelixir_insanitydamage.postinit_wendy = function(wendy)
    if wendy.components.combat ~= nil then
        local old_customdamagemultfn = wendy.components.combat.customdamagemultfn
        wendy.components.combat.customdamagemultfn = function(self, target)
            local abigail = self.components.ghostlybond ~= nil and self.components.ghostlybond.ghost
            local active_elixir = abigail:GetDebuff("elixir_buff")
            if target:HasDebuff("abigail_vex_debuff") and active_elixir == "newelixir_insanitydamage_buff" then
                return elixirs.newelixir_insanitydamage.calcmultiplier_wendyvex(self)
            end
            return old_customdamagemultfn(self, target)
        end
    end
end
elixirs.newelixir_insanitydamage.ontickfn = function(buff, abigail)
    if abigail ~= nil and abigail.components.combat ~= nil then
        if abigail._playerlink ~= nil then
            local wendy = abigail._playerlink
            local multiplier = elixirs.newelixir_insanitydamage.calcmultiplier_abigail(wendy)
            abigail.components.combat.externaldamagemultipliers:SetModifier(buff, multiplier)
        end
    end
end
elixirs.newelixir_healthdamage.ondetachfn = function(buff, abigail)
    if abigail.components.combat ~= nil then
        abigail.components.combat.externaldamagemultipliers:RemoveModifier(buff)
    end
end
-- TODO define dripfxfn
-- TODO define damage function
-- TODO implement damage functions in postinit

--------------------------------------------------------------------------
--[[ newelixir_shadowfighter ]]
--------------------------------------------------------------------------
elixirs.newelixir_shadowfighter =
{
    nightmare = true,
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
    -- allows abigail to attack shadow creatures
    abigail:AddTag("crazy")
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
    applyfx = "ghostlyelixir_attack_fx",
    dripfx = "electrichitsparks",
}
-- TODO define dripfxfn, this might go in onattach?
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
--[[ newelixir_cleanse ]]
--------------------------------------------------------------------------
elixirs.newelixir_cleanse =
{
    nightmare = false,
    duration = 0.1,
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
-- TODO spawn ghostflowers on cleanse

return elixirs