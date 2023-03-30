local function SetNightmareForm(abigail, enable)
    if enable then
        abigail.AnimState:SetBuild("ghost_abigail_nightmare_build")
        abigail.nightmare = true
    else
        abigail.AnimState:SetBuild("ghost_abigail_build")
        abigail.nightmare = false
    end
    if abigail.is_defensive then
        abigail.AnimState:ClearOverrideSymbol("ghost_eyes")
    else
        abigail.AnimState:OverrideSymbol("ghost_eyes", abigail.AnimState:GetBuild(), "angry_ghost_eyes")
    end
end

local function DoNightmareBurst(abigail, sanity, scale, range_end, range_start)
    scale = scale or 1.0
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

AddPrefabPostInit("abigail", function(abigail)
    if not GLOBAL.TheWorld.ismastersim then return abigail end

    abigail.nightmare = (abigail.AnimState:GetBuild() == "ghost_abigail_nightmare_build")

    abigail.SetNightmareForm = SetNightmareForm
    abigail.DoNightmareBurst = DoNightmareBurst

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

    -- huge nightmare burst on death while in nightmare form
    abigail:ListenForEvent("death", function()
        if abigail.nightmare then
            abigail:DoNightmareBurst(-TUNING.SANITY_HUGE, 1.5)
        end
    end)
end)

local function FindNodeAt(root, node_path)
    local current_node = root
    local current_index = 1
    while current_index <= #node_path do
        local search_name = node_path[current_index]
        local found = false
        for _, child in ipairs(current_node.children) do
            if child.name == search_name then
                current_node = child
                found = true
                break
            end
        end
        if not found then
            return nil
        end
        current_index = current_index + 1
    end
    return current_node
end

AddBrainPostInit("abigailbrain", function(brain)
    local root = brain.bt.root -- priority
    --local defensive_mode = root.children[1] -- while
    --local defensive_priority = defensive_mode.children[#defensive_mode.children] -- priority
    --local follow_node
    --for _, node in ipairs(defensive_priority.children) do
    --    if node.name == "Follow" then
    --        follow_node = node
    --        break
    --    end
    --end
    local follow_node = FindNodeAt(root, { "Parallel", "Priority", "Follow" })
    local old_min_dist_fn = follow_node.min_dist_fn
    follow_node.min_dist_fn = function(abigail)
        return abigail.min_dist_override or (old_min_dist_fn and old_min_dist_fn() or TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW)
    end
    local old_target_dist_fn = follow_node.target_dist_fn
    follow_node.target_dist_fn = function(abigail)
        return abigail.med_dist_override or (old_target_dist_fn and old_target_dist_fn() or TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW)
    end
    local old_max_dist_fn = follow_node.max_dist_fn
    follow_node.max_dist_fn = function(abigail)
        return abigail.max_dist_override or (old_max_dist_fn and old_max_dist_fn() or TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW)
    end
end)