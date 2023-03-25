local function UpdateEyes(abigail)
    if abigail.is_defensive then
        abigail.AnimState:ClearOverrideSymbol("ghost_eyes")
    else
        abigail.AnimState:OverrideSymbol("ghost_eyes", abigail.AnimState:GetBuild(), "angry_ghost_eyes")
    end
end

local function SetNightmare(abigail, enable)
    if enable then
        abigail.AnimState:SetBuild("ghost_abigail_nightmare_build")
        abigail.nightmare = true
    else
        abigail.AnimState:SetBuild("ghost_abigail_build")
        abigail.nightmare = false
    end
    abigail:UpdateEyes()
end

local function DoNightmareBurst(abigail, scale, long_range, close_range)
    scale = (scale or 1.0) * 1.5
    long_range = long_range or 10.0
    close_range = close_range or 5.0
    if close_range == long_range then
        long_range = close_range + 1
    end
    local abigail_pos = abigail.Transform:GetWorldPosition()
    local x, y, z = abigail_pos
    local necessary_tags = { "player" }
    local nearby_players = GLOBAL.TheSim:FindEntities(x, y, z, long_range, necessary_tags)
    for _, p in ipairs(nearby_players) do
        if p.components.sanity ~= nil then
            local player_pos = p.Transform:GetWorldPosition()
            local distance = (player_pos - abigail_pos):Length()
            local distance_proportion = (distance - close_range) / (long_range - close_range)
            local distance_multiplier = 1.0 - (math.max(0.0, math.min(1.0, distance_proportion)))
            p.components.sanity:DoDelta(-TUNING.SANITY_HUGE * distance_multiplier)
        end
    end
    local nightmare_burst = GLOBAL.SpawnPrefab("stalker_shield")
    nightmare_burst.Transform:SetPosition(abigail:GetPosition():Get())
    nightmare_burst.AnimState:SetScale(scale, scale, scale)
    abigail.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
end

local function DoNightmareBurstSmall(abigail)
    local scale = 1.0 / 1.5
    abigail:DoNightmareBurst(scale, 5.0, 1.0)
end

AddPrefabPostInit("abigail", function(abigail)
    abigail.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then return abigail end

    abigail.nightmare = (abigail.AnimState:GetBuild() == "ghost_abigail_nightmare_build")

    abigail.UpdateEyes = UpdateEyes
    abigail.SetNightmare = SetNightmare
    abigail.DoNightmareBurst = DoNightmareBurst
    abigail.DoNightmareBurstSmall = DoNightmareBurstSmall

    -- add wendy inspect dialogue for nightmare abigail
    local OldGetStatus = abigail.components.inspectable.getstatus
    abigail.components.inspectable.getstatus = function(self, viewer)
        if viewer.prefab == "wendy" and self.nightmare then
            return "NIGHTMARE"
        end
        return OldGetStatus(self, viewer)
    end

    -- let abigail use any build's angry eyes when riled up (we need this for when she has the nightmare build)
    local OldBecomeAggressive = abigail.BecomeAggressive
    abigail.BecomeAggressive = function(self)
        local current_build = self.AnimState:GetBuild()
        OldBecomeAggressive(self)
        self.AnimState:OverrideSymbol("ghost_eyes", current_build, "angry_ghost_eyes")
    end

    -- TODO add damage resistance function against shadow creatures, damage resistance should be 100% when wendy is not crazy
    -- TODO (or better yet, de-aggro all shadow creatures on abigail when wendy is not crazy)

    -- sanity bomb nearby players when abigail dies with a nightmare elixir equipped
    --abigail:ListenForEvent("stopaura", function(self)
    --    if self.nightmare then
    --        local x, y, z = self.Transform:GetWorldPosition()
    --        local necessary_tags = { "player" }
    --        local nearby_players = GLOBAL.TheSim:FindEntities(x, y, z, 15, necessary_tags)
    --        for _, p in ipairs(nearby_players) do
    --            if p.components.sanity ~= nil then
    --                p.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    --            end
    --        end
    --        local nightmare_burst = GLOBAL.SpawnPrefab("stalker_shield")
    --        nightmare_burst.Transform:SetPosition(self:GetPosition():Get())
    --        nightmare_burst.AnimState:SetScale(1.5, 1.5, 1.5)
    --        self.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
    --    end
    --end)
end)