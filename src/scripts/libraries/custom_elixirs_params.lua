local elixirs = {}

--[[
 Usable Functions:

 itemfn(prefab, params)                                         - creates the elixir item that wendy uses
 postitemfn(elixir)                                             - executed after the elixir entity has been created
 bufffn(prefab, params)                                         - creates the invisible buff object attached to abigail
 postbufffn(buff)                                               - executed after the buff entity has been created
 onattachfn(buff, target, followsymbol, followoffset, data)     - executed when the buff is added to abigail
 ontickfn(buff, target)                                         - executed at the buff's tick rate until detached
 ondetachfn(buff, target, followsymbol, followoffset, data)     - executed when the buff is removed from abigail
 onextendfn(buff, target, followsymbol, followoffset, data)     - executed when the buff is reapplied to abigail
 ontimerdonefn(buff, data { timername })                        - executed immediately before the buff is removed from abigail due to expiration
]]--

--------------------------------------------------------------------------
--[[ all elixirs ]]
--------------------------------------------------------------------------
elixirs.all_elixirs = {
    duration = TUNING.TOTAL_DAY_TIME,
    tickrate = 0.5,
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

    return buff
end
elixirs.all_elixirs.dripfxfn = function(buff, abigail)
    if not abigail.inlimbo and not abigail.sg:HasStateTag("busy") then
        local x, y, z = abigail.Transform:GetWorldPosition()
        GLOBAL.SpawnPrefab(buff.params.dripfx).Transform:SetPosition(x, y, z)
    end
end
elixirs.all_elixirs.driptaskfn = function(buff, abigail)
    return buff:DoPeriodicTask(TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY, buff.params.dripfxfn, TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY * 0.25, abigail)
end
elixirs.all_elixirs.buffattachfn = function(buff, abigail)
    buff.entity:SetParent(abigail.entity)
    buff.Transform:SetPosition(0, 0, 0)
    abigail:SetNightmareForm(buff.params.nightmare)
    if buff.params.onattachfn ~= nil then
        buff.params.onattachfn(buff, abigail)
    end
    if buff.params.ontickfn ~= nil then
        buff.task = buff:DoPeriodicTask(buff.params.tickrate, buff.params.ontickfn, nil, abigail)
    end
    if buff.params.dripfxfn ~= nil then
        buff.driptask = buff.params.driptaskfn(buff, abigail)
    end
    buff:ListenForEvent("death", function()
        buff.components.debuff:Stop()
    end, abigail)
    if buff.params.applyfx ~= nil and not abigail.inlimbo then
        local applyfx = GLOBAL.SpawnPrefab(buff.params.applyfx)
        applyfx.entity:SetParent(abigail.entity)
    end
end
elixirs.all_elixirs.buffdetachfn = function(buff, abigail)
    if buff.params.ondetachfn ~= nil then
        buff.params.ondetachfn(buff, abigail)
    end
    abigail:SetNightmareForm(false)
    if buff.task ~= nil then
        buff.task:Cancel()
        buff.task = nil
    end
    if buff.driptask ~= nil then
        buff.driptask:Cancel()
        buff.driptask = nil
    end
    buff:Remove()
end
elixirs.all_elixirs.buffextendfn = function(buff, abigail)
    if (buff.components.timer:GetTimeLeft("decay") or 0) < buff.params.duration then
        buff.components.timer:StopTimer("decay")
        buff.components.timer:StartTimer("decay", buff.params.duration)
    end
    if buff.task ~= nil then
        buff.task:Cancel()
        buff.task = buff:DoPeriodicTask(buff.params.tickrate, buff.params.ontickfn, nil, abigail)
    end
    if buff.params.applyfx ~= nil and not abigail.inlimbo then
        local applyfx = GLOBAL.SpawnPrefab(buff.params.applyfx)
        applyfx.entity:SetParent(abigail.entity)
    end
end
elixirs.all_elixirs.bufftimerdonefn = function(buff, data)
    if data.name == "decay" then
        if buff.params.ontimerdonefn ~= nil then
            buff.params.ontimerdonefn(buff)
        end
        buff.components.debuff:Stop()
    end
end
elixirs.all_elixirs.postbufffn = function(buff)
    if not GLOBAL.TheWorld.ismastersim then return buff end

    buff:AddComponent("debuff")
    buff.components.debuff:SetAttachedFn(elixirs.all_elixirs.buffattachfn)
    buff.components.debuff:SetDetachedFn(elixirs.all_elixirs.buffdetachfn)
    buff.components.debuff:SetExtendedFn(elixirs.all_elixirs.buffextendfn)
    buff.components.debuff.keepondespawn = true
    buff:AddComponent("timer")
    buff.components.timer:StartTimer("decay", buff.params.duration)
    buff:ListenForEvent("timerdone", elixirs.all_elixirs.bufftimerdonefn)

    return buff
end

--------------------------------------------------------------------------
--[[ all nightmare elixirs ]]
--------------------------------------------------------------------------
elixirs.all_nightmare_elixirs = {
    duration = TUNING.TOTAL_DAY_TIME / 2,
}
elixirs.all_nightmare_elixirs.ontimerdonefn = function(buff)
    if buff.target ~= nil and buff.target.prefab == "abigail" then
        -- do small nightmare burst if a nightmare elixir reaches the end of its duration
        buff.target:DoNightmareBurst(-TUNING.SANITY_LARGE, 1.2, 7.0, 3.0)
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
    applyfx = "ghostlyelixir_retaliation_fx",
    dripfx = "ghostlyelixir_retaliation_dripfx",
}
elixirs.newelixir_healthdamage.calcmultiplier_wendy_vex = function(wendy)
    if wendy.components.health ~= nil then
        local health_percent = wendy.components.health:GetPercent()
        local tuning = TUNING.NEW_ELIXIRS.HEALTHDAMAGE
        if health_percent <= tuning.LOW_HEALTH then
            return tuning.WENDY_VEX.BONUS_DAMAGE_MULT
        end
        local deltaY = tuning.WENDY_VEX.MIN_DAMAGE_MULT - tuning.WENDY_VEX.MAX_DAMAGE_MULT
        local deltaX = tuning.HIGH_HEALTH - tuning.LOW_HEALTH
        if deltaX == 0 then
            return tuning.WENDY_VEX.MAX_DAMAGE_MULT
        end
        local m = deltaY / deltaX
        return m * (health_percent - tuning.HIGH_HEALTH) + tuning.WENDY_VEX.MIN_DAMAGE_MULT
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
            local has_elixir = active_elixir ~= nil and active_elixir.prefab == "newelixir_healthdamage_buff"
            if target:HasDebuff("abigail_vex_debuff") and has_elixir then
                return elixirs.newelixir_healthdamage.calcmultiplier_wendy_vex(self)
            end
            if old_customdamagemultfn ~= nil then
                return old_customdamagemultfn(self, target)
            end
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

--------------------------------------------------------------------------
--[[ newelixir_insanitydamage ]]
--------------------------------------------------------------------------
elixirs.newelixir_insanitydamage =
{
    nightmare = true,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "shadow_trap_debuff_fx",
    -- TODO define dripfxfn and driptaskfn
}
elixirs.newelixir_insanitydamage.calcmultiplier_wendy_vex = function(_, abigail)
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
            local has_elixir = active_elixir ~= nil and active_elixir.prefab == "newelixir_insanitydamage_buff"
            if target:HasDebuff("abigail_vex_debuff") and has_elixir then
                return elixirs.newelixir_insanitydamage.calcmultiplier_wendy_vex(self)
            end
            if old_customdamagemultfn ~= nil then
                return old_customdamagemultfn(self, target)
            end
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
elixirs.newelixir_insanitydamage.ondetachfn = function(buff, abigail)
    if abigail.components.combat ~= nil then
        abigail.components.combat.externaldamagemultipliers:RemoveModifier(buff)
    end
end
-- TODO implement damage functions in postinit

--------------------------------------------------------------------------
--[[ newelixir_shadowfighter ]]
--------------------------------------------------------------------------
elixirs.newelixir_shadowfighter =
{
    nightmare = true,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "thurible_smoke",
    -- TODO define dripfxfn and driptaskfn
}
elixirs.newelixir_shadowfighter.postinit_wendy = function(wendy)
    if wendy.components.combat ~= nil then
        local old_customdamagemultfn = wendy.components.combat.customdamagemultfn
        wendy.components.combat.customdamagemultfn = function(self, target)
            local abigail = self.components.ghostlybond ~= nil and self.components.ghostlybond.ghost
            local active_elixir = abigail:GetDebuff("elixir_buff")
            local has_elixir = active_elixir ~= nil and active_elixir.prefab == "newelixir_shadowfighter_buff"
            if target:HasTag("shadowcreature") and target:HasDebuff("abigail_vex_debuff") and has_elixir then
                return TUNING.NEW_ELIXIRS.SHADOWFIGHTER.WENDY_VEX.DAMAGE_MULT
            end
            if old_customdamagemultfn ~= nil then
                return old_customdamagemultfn(self, target)
            end
        end
    end
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
    -- TODO define dripfxfn and driptaskfn
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
--[[ newelixir_cleanse ]]
--------------------------------------------------------------------------
elixirs.newelixir_cleanse =
{
    duration = 0.1,
    applyfx = "ghostlyelixir_slowregen_fx",
    dripfx = "ghostlyelixir_slowregen_dripfx",
}
elixirs.newelixir_cleanse.spawnghostflowers = function(abigail)
    local loot_table = { 1.0, 0.5, 0.5 }
    local ax, ay, az = abigail.Transform:GetWorldPosition()
    for _, chance in ipairs(loot_table) do
        if math.random() < chance then
            local ghostflower = GLOBAL.SpawnPrefab("ghostflower")
            local angle = math.random(0, GLOBAL.PI2)
            ghostflower.Transform:SetPosition(ax + math.cos(angle), ay, az - math.sin(angle))
            ghostflower:DelayedGrow()
        end
    end
end
elixirs.newelixir_cleanse.onattachfn = function(_, abigail)
    local healing = abigail.components.health:GetMaxWithPenalty() * TUNING.NEW_ELIXIRS.CLEANSE.HEALTH_GAIN
    abigail.components.health:DoDelta(healing)
    if abigail._playerlink ~= nil and abigail._playerlink.components.sanity ~= nil then
        abigail._playerlink.components.sanity:DoDelta(TUNING.NEW_ELIXIRS.CLEANSE.SANITY_GAIN)
    end
    elixirs.newelixir_cleanse.spawnghostflowers(abigail)
end

return elixirs