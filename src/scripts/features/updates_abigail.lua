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