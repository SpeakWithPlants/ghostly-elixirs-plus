local function GetOfferingValue(moondial, offering)
    if not offering:HasTag("trinket") then
        return 0
    end
    local ritual_complete = moondial.pending_trinkets >= TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_COMPLETE_TRINKETS
    local item_value = offering.components.tradable and math.ceil(offering.components.tradable.goldvalue / 2.0) or 0
    if item_value > 0 then
        if ritual_complete then
            if TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_COMPLETE_FLOWERS >= 0 then
                item_value = TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_COMPLETE_FLOWERS
            end
        else
            if TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_STARTED_FLOWERS >= 0 then
                item_value = TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_STARTED_FLOWERS
            end
        end
    end
    return item_value or 0
end

local function SpewGhostFlowers(moondial)
    local flowers = moondial.pending_ghostflowers or 0
    if flowers > 0 then
        for k = 1, flowers do
            moondial:DoTaskInTime(k * 0.1 + 1.5, function(center)
                local loot = GLOBAL.SpawnPrefab("ghostflower")
                if loot ~= nil then
                    -- fling ghostflowers
                    local rand = math.random()
                    local angle = rand * 2 * GLOBAL.PI
                    local sinangle = math.sin(angle)
                    local cosangle = math.cos(angle)
                    local pt = center:GetPosition()
                    pt.y = 2.0
                    loot.Transform:SetPosition(pt:Get())
                    if loot.Physics ~= nil then
                        loot.Physics:SetVel(2 * cosangle, 12, 2 * -sinangle)
                    end
                    if math.fmod(k, 3) then
                        local fx = GLOBAL.SpawnPrefab("splash")
                        fx.Transform:SetPosition(pt:Get())
                    end
                end
            end)
        end
    end
    moondial.SoundEmitter:KillSound("idlesound")
    moondial.SoundEmitter:KillSound("howl")
    moondial.pending_trinkets = 0
    moondial.pending_ghostflowers = 0
end

local function AddOffering(moondial, offering)
    local offering_value = moondial:GetOfferingValue(offering)
    moondial.pending_trinkets = moondial.pending_trinkets + 1
    moondial.pending_ghostflowers = moondial.pending_ghostflowers + offering_value
    if moondial.pending_trinkets == TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_COMPLETE_TRINKETS then
        moondial.pending_ghostflowers = moondial.pending_ghostflowers + TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_COMPLETE_BONUS_FLOWERS
        moondial.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/active")
    end
    if moondial.pending_trinkets >= TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_COMPLETE_TRINKETS then
        moondial.Light:SetRadius(10.0)
    else
        moondial.Light:SetRadius(7.0)
    end

    -- fx
    local pt = moondial:GetPosition()
    pt.y = 2.0
    local fx = GLOBAL.SpawnPrefab("splash")
    fx.Transform:SetPosition(pt:Get())
    moondial.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")
    if not moondial.SoundEmitter:PlayingSound("idlesound") then
        moondial.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/idle_LP", "idlesound")
    end
    if not moondial.SoundEmitter:PlayingSound("howl") then
        moondial.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")
    end
end

AddAction("MOONOFFERING", "Offer", function(act)
    -- guard clauses
    if not act.invobject or not act.doer.components.inventory or not act.target then
        return
    end
    local player = act.doer
    local moondial = act.target
    local offering = player.components.inventory:RemoveItem(act.invobject)
    if not offering then
        return
    end

    -- failure reasons
    local reason
    if moondial:GetOfferingValue(offering) <= 0 then
        reason = "NO_VALUE"
    elseif moondial.is_glassed then
        reason = "GLASSED"
    elseif GLOBAL.TheWorld.state.phase ~= "night" then
        reason = "NO_NIGHT"
    elseif GLOBAL.TheWorld.state.moonphase ~= "full" then
        reason = "NO_FULLMOON"
    end
    if reason then
        player.components.inventory:GiveItem(offering)
        moondial.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
        return false, reason
    end

    moondial:AddOffering(offering)
    if player.components.sanity ~= nil then
        player.components.sanity:DoDelta(TUNING.SANITY_TINY)
    end
    return true
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.MOONOFFERING, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.MOONOFFERING, "dolongaction"))

AddPrefabPostInit("moondial", function(moondial)
    moondial.pending_trinkets = 0
    moondial.pending_ghostflowers = 0

    moondial.GetOfferingValue = GetOfferingValue
    moondial.AddOffering = AddOffering

    if moondial.components.inspectable ~= nil then
        local OldGetStatus = moondial.components.inspectable.getstatus
        moondial.components.inspectable.getstatus = function(self, viewer)
            if viewer.prefab == "wendy" then
                if self.pending_trinkets >= TUNING.NEW_ELIXIRS.MOONDIAL.RITUAL_COMPLETE_TRINKETS then
                    return "RITUAL_COMPLETE"
                elseif self.pending_trinkets > 0 then
                    return "RITUAL_STARTED"
                end
            else
                return OldGetStatus(self, viewer)
            end
        end
    end

    -- spew pending ghostflowers at dawn
    moondial:WatchWorldState("isday", function(self, isday)
        if not isday then return end
        SpewGhostFlowers(self)
    end)
end)