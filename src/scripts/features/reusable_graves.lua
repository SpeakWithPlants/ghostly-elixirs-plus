
local function OnHit(gravestone)
    gravestone.AnimState:PlayAnimation("grave" .. gravestone.random_stone_choice .. "_hit")
    gravestone.AnimState:PushAnimation("grave" .. gravestone.random_stone_choice, false)
end

local function OnDestroy(gravestone, _)
    if gravestone.mound then
        gravestone.mound:DropBuriedTrinket()
        gravestone.mound:Remove()
    end
    local loot = { "marble", "marble", "boneshard" }
    for _, v in ipairs(loot) do
        gravestone.components.lootdropper:SpawnLootPrefab(v)
    end

    gravestone.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    local fx = GLOBAL.SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(gravestone.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    gravestone:Remove()
end

local function RemoveGhost(gravestone)
    if gravestone.ghost then
        gravestone.ghost.sg:GoToState("dissipate")
    end
end

local function OnSecondDig(mound, worker)
    mound:DropBuriedTrinket()
    mound:SetBuriedState(false)
    if worker.components.sanity then
        worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
    end
end

local function DropBuriedTrinket(mound)
    if mound.buried_trinket then
        mound.components.lootdropper:SpawnLootPrefab(mound.buried_trinket)
    end
end

local function SetBuriedState(mound, buried, offering)
    if buried then
        mound.AnimState:PlayAnimation("gravedirt")
        mound:AddComponent("workable")
        mound.components.workable:SetWorkAction(GLOBAL.ACTIONS.DIG)
        mound.components.workable:SetWorkLeft(1)
        mound.components.workable:SetOnFinishCallback(OnSecondDig)
        mound.buried_trinket = offering
    else
        mound.AnimState:PlayAnimation("dug")
        mound:RemoveComponent("workable")
        mound.buried_trinket = nil
    end
end

-- copied this method from prefabs/gravestone.lua and added more conditions to the front
local CANTHAVE_GHOST_TAGS = {"questing"}
local MUSTHAVE_GHOST_TAGS = {"ghostkid"}
local function OnDayChange(gravestone)
    if not gravestone.mound or gravestone.mound.AnimState:IsCurrentAnimation("dug") then
        return
    end
    if gravestone.ghost == nil or not gravestone.ghost:IsValid() and #GLOBAL.AllPlayers > 0 then
        local ghost_spawn_chance = 0
        for _, v in ipairs(GLOBAL.AllPlayers) do
            if v:HasTag("ghostlyfriend") then
                ghost_spawn_chance = ghost_spawn_chance + TUNING.GHOST_GRAVESTONE_CHANCE
            end
        end
        ghost_spawn_chance = math.max(ghost_spawn_chance, TUNING.GHOST_GRAVESTONE_CHANCE)

        if math.random() < ghost_spawn_chance then
            local gx, gy, gz = gravestone.Transform:GetWorldPosition()
            local nearby_ghosts = GLOBAL.TheSim:FindEntities(gx, gy, gz, TUNING.UNIQUE_SMALLGHOST_DISTANCE, MUSTHAVE_GHOST_TAGS, CANTHAVE_GHOST_TAGS)
            if #nearby_ghosts == 0 then
                gravestone.ghost = GLOBAL.SpawnPrefab("smallghost")
                gravestone.ghost.Transform:SetPosition(gx + 0.3, gy, gz + 0.3)
                gravestone.ghost:LinkToHome(gravestone)
            end
        end
    end
end

AddAction("BURY", "Bury", function(act)
    -- guard clauses
    if not act.invobject or not act.doer.components.inventory or not act.target then
        return
    end
    local player = act.doer
    local mound = act.target
    local offering = player.components.inventory:RemoveItem(act.invobject)
    if not offering then
        return
    end

    mound:SetBuriedState(true, offering.prefab)
    mound.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge")
    if player.components.sanity ~= nil then
        player.components.sanity:DoDelta(TUNING.SANITY_SMALL)
    end
    return true
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURY, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BURY, "dolongaction"))

AddPrefabPostInit("gravestone", function(gravestone)
    gravestone.entity:AddSoundEmitter()

    gravestone:AddTag("structure")

    gravestone.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then return gravestone end

    gravestone.RemoveGhost = RemoveGhost

    gravestone.AnimState:PlayAnimation("grave" .. gravestone.random_stone_choice .. "_hit")
    gravestone.AnimState:PushAnimation("grave" .. gravestone.random_stone_choice, false)

    gravestone:AddComponent("finiteuses")
    gravestone.components.finiteuses:SetMaxUses(1)
    gravestone.components.finiteuses:SetUses(0)

    gravestone:AddComponent("lootdropper")

    gravestone:AddComponent("workable")
    gravestone.components.workable:SetWorkAction(GLOBAL.ACTIONS.HAMMER)
    gravestone.components.workable:SetWorkLeft(6)
    gravestone.components.workable:SetOnFinishCallback(OnDestroy)
    gravestone.components.workable:SetOnWorkCallback(OnHit)

    gravestone:StopWatchingWorldState("cycles")
    gravestone.OnDayChange = OnDayChange
    gravestone:WatchWorldState("cycles", gravestone.OnDayChange)

    if #GLOBAL.AllPlayers > 0 then
        -- gravestone was probably created by a player (not worldgen)
        if gravestone.mound then
            gravestone.mound:SetBuriedState(false)
        end
    end

    gravestone:ListenForEvent("onremove", RemoveGhost)
    gravestone:ListenForEvent("worked", function(mound)
        mound.parent:RemoveGhost()
    end, gravestone.mound)
end)

AddPrefabPostInit("mound", function(mound)
    mound.entity:AddSoundEmitter()

    mound.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then return mound end

    mound.DropBuriedTrinket = DropBuriedTrinket
    mound.SetBuriedState = SetBuriedState

    local OldOnSave = mound.OnSave
    mound.OnSave = function(self, data)
        OldOnSave(self, data)
        if data ~= nil then
            data.buried_trinket = self.buried_trinket
        end
    end

    local OldOnLoad = mound.OnLoad
    mound.OnLoad = function(self, data)
        OldOnLoad(self, data)
        if data ~= nil then
            if data.dug then
                self:SetBuriedState(false)
            elseif data.buried_trinket then
                self:SetBuriedState(true, data.buried_trinket)
            end
        end
    end
end)