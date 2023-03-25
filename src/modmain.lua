Assets = {
	-- prefab anim files
	Asset("ANIM", "anim/new_elixirs.zip"),
	Asset("ANIM", "anim/gravestones.zip"),

	-- alternate builds
	Asset("ANIM", "anim/ghost_abigail_nightmare_build.zip"),
	Asset("ANIM", "anim/status_newelixir.zip"),

	-- inventory images
	Asset("IMAGE", "images/inventoryimages/gravestone.tex"),
	Asset("ATLAS", "images/inventoryimages/gravestone.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_sanityaura.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_sanityaura.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_lightaura.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_lightaura.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_healthdamage.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_healthdamage.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_cleanse.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_cleanse.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_insanitydamage.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_insanitydamage.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_shadowfighter.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_shadowfighter.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_lightning.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_lightning.xml"),
}

PrefabFiles = {
	"new_elixirs",
	"gravestone_placer",
}

modimport "scripts/tuning.lua"
modimport "scripts/constants.lua"

-- add tag to all trinket items
for k = 1, GLOBAL.NUM_TRINKETS do
	AddPrefabPostInit("trinket_"..tostring(k), function(inst)
		inst:AddTag("trinket")
	end)
end

modimport "scripts/features/moon_dial_offerings.lua"
modimport "scripts/features/reusable_graves.lua"
modimport "scripts/features/updates_sisturn.lua"
modimport "scripts/features/updates_abigail.lua"
modimport "scripts/features/updates_elixirs.lua"

-- allow trinkets to be used on the moon dial
-- allow trinkets to be buried in open mounds
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, _)
	if doer:HasTag("elixirbrewer") and target.prefab == "moondial" then
		table.insert(actions, GLOBAL.ACTIONS.MOONOFFERING)
	end
	if doer:HasTag("ghostlyfriend") and inst:HasTag("trinket") and target.prefab == "mound" and target.AnimState:IsCurrentAnimation("dug") then
		table.insert(actions, GLOBAL.ACTIONS.BURY)
	end
end)

local function DoNightmareElixir(_, _, target)
	target.AnimState:SetBuild("ghost_abigail_nightmare_build")
end

local function DoApplyElixir(inst, giver, target)
	if target ~= nil and target.components.debuffable ~= nil then
		local current_buff = target.components.debuffable:GetDebuff("elixir_buff")
		if current_buff ~= nil then
			if current_buff.potion_tunings.NIGHTMARE_ELIXIR and not inst.potion_tunings.NIGHTMARE_ELIXIR and inst.prefab ~= "newelixir_cleanse" then
				return false, "WRONG_ELIXIR"
			end
			if current_buff.prefab ~= inst.buff_prefab then
				target.components.debuffable:RemoveDebuff("elixir_buff")
			end
		elseif inst.prefab == "newelixir_cleanse" then
			return false, "NO_ELIXIR"
		end
		target.components.debuffable:AddDebuff("elixir_buff", inst.buff_prefab)
		if inst.potion_tunings.NIGHTMARE_ELIXIR then
			DoNightmareElixir(inst, giver, target)
		end
		return true
	end
end

local function UpdateDoApplyElixirFn(inst)
	if inst.components.ghostlyelixir ~= nil then
		inst.components.ghostlyelixir.doapplyelixerfn = DoApplyElixir
	end
end

-- Name suffixes of old elixirs
local OLD_ELIXIRS = {
	"slowregen",
	"fastregen",
	"speed",
	"attack",
	"shield",
	"retaliation",
}

-- Name suffixes of all new elixirs
local NEW_ELIXIRS = {
	"sanityaura",
	"lightaura",
	"healthdamage",
	"cleanse",
	"insanitydamage",
	"shadowfighter",
	"lightning",
}

-- Update apply functions for all elixirs
for _, ELIXIR in ipairs(OLD_ELIXIRS) do
	AddPrefabPostInit("ghostlyelixir_"..ELIXIR, UpdateDoApplyElixirFn)
end
for _, ELIXIR in ipairs(NEW_ELIXIRS) do
	AddPrefabPostInit("newelixir_"..ELIXIR, UpdateDoApplyElixirFn)
end

-- Update (improve) old elixir buffs
AddPrefabPostInit("ghostlyelixir_speed", function(inst)
	if not inst.potion_tunings then
		return
	end
	local old_apply_fn = inst.potion_tunings.ONAPPLY
	inst.potion_tunings.ONAPPLY = function(elixir, target)
		if old_apply_fn ~= nil then
			old_apply_fn(elixir, target)
		end
		elixir.old_min_follow = TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW
		elixir.old_med_follow = TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW
		elixir.old_max_follow = TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW
		TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW = 0.6
		TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW = 1.2
		TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW = 1.5
	end

	local old_detach_fn = inst.potion_tunings.ONDETACH
	inst.potion_tunings.ONDETACH = function(elixir, target)
		if old_detach_fn ~= nil then
			old_detach_fn(elixir, target)
		end
		TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW = elixir.old_min_follow
		TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW = elixir.old_med_follow
		TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW = elixir.old_max_follow
	end
end)

AddPrefabPostInit("ghostlyelixir_slowregen", function(inst)
	if not inst.potion_tunings then
		return
	end
	local old_apply_fn = inst.potion_tunings.ONAPPLY
	inst.potion_tunings.ONAPPLY = function(elixir, target)
		if old_apply_fn ~= nil then
			old_apply_fn(elixir, target)
		end
		if target._playerlink ~= nil then
			target._playerlink.components.ghostlybond:SetBondTimeMultiplier(elixir.prefab, 3)
		end
	end

	local old_detach_fn = inst.potion_tunings.ONDETACH
	inst.potion_tunings.ONDETACH = function(elixir, target)
		if old_detach_fn ~= nil then
			old_detach_fn(elixir, target)
		end
		if target._playerlink ~= nil then
			target._playerlink.components.ghostlybond:SetBondTimeMultiplier(elixir.prefab, nil)
		end
	end
end)

--[[
local normal_ghost_prefabs = {
	"ghost",
	"smallghost",
}

-- Tag non-abigail ghosts for wendy's sanity aura immunities
for _, prefab in ipairs(normal_ghost_prefabs) do
	AddPrefabPostInit(prefab, function(inst)
		inst:AddTag("normalghost")
	end)
end
AddPrefabPostInit("wendy", function(inst)
	if inst.components.sanity ~= nil then
		inst.components.sanity:AddSanityAuraImmunity("normalghost")
	end
end)]]

-- these numbers are copied from debug logs, not sure how to get net_hash vars outside the class without using literals
-- print(abigail._playerlink.components.pethealthbar:GetDebugString()) -> convert symbol hex to decimal
AddClassPostConstruct("widgets/statusdisplays", function(inst)
	if inst.pethealthbadge then
		inst.pethealthbadge:SetBuildForSymbol("status_newelixir", 233052865)	--newelixir_sanityaura_buff
		inst.pethealthbadge:SetBuildForSymbol("status_newelixir", 3759892665)	--newelixir_lightaura_buff
		inst.pethealthbadge:SetBuildForSymbol("status_newelixir", 1525997575)	--newelixir_healthdamage_buff
		inst.pethealthbadge:SetBuildForSymbol("status_newelixir", 3096020880)	--newelixir_insanitydamage_buff
		inst.pethealthbadge:SetBuildForSymbol("status_newelixir", 3487606133)	--newelixir_shadowfighter_buff
		inst.pethealthbadge:SetBuildForSymbol("status_newelixir", 536102728)	--newelixir_lightning_buff
	end
end)

modimport "scripts/recipes.lua"

-- TODO remove debug mode
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require('debugkeys')
