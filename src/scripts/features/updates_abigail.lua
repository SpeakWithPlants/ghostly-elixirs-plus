function FindBehaviorNodeAt(brain, node_path)
    local current_node = brain.bt.root
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

local function replace_speed(abigail, old_fn, modded_follow_distance, default_follow_dist)
    local buff = abigail:GetDebuff("elixir_buff")
    if buff ~= nil and buff.prefab == "ghostlyelixir_speed_buff" then
        return modded_follow_distance
    else
        if old_fn ~= nil then
            return old_fn(abigail)
        end
        return default_follow_dist
    end
end

AddPrefabPostInit("abigail", function(abigail)
    if not GLOBAL.TheWorld.ismastersim then return abigail end

    abigail.nightmare = (abigail.AnimState:GetBuild() == "ghost_abigail_nightmare_build")

    abigail.SetNightmareForm = SetNightmareForm

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
end)

AddBrainPostInit("abigailbrain", function(brain)
    if not GLOBAL.TheWorld.ismastersim then return brain end

    local follow_node = FindBehaviorNodeAt(brain, { "Parallel", "Priority", "Follow" })

    local old_min_dist_fn = follow_node.min_dist_fn
    follow_node.min_dist_fn = function(abigail)
        return replace_speed(abigail, old_min_dist_fn, TUNING.NEW_ELIXIRS.SPEED.MIN_FOLLOW_DIST, TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW)
    end

    local old_max_dist_fn = follow_node.max_dist_fn
    follow_node.max_dist_fn = function(abigail)
        return replace_speed(abigail, old_max_dist_fn, TUNING.NEW_ELIXIRS.SPEED.MAX_FOLLOW_DIST, TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW)
    end

    local old_target_dist_fn = follow_node.target_dist_fn
    follow_node.target_dist_fn = function(abigail)
        return replace_speed(abigail, old_target_dist_fn, TUNING.NEW_ELIXIRS.SPEED.MED_FOLLOW_DIST, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW)
    end
end)