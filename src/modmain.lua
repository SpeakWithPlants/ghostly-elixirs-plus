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
	Asset("IMAGE", "images/inventoryimages/newelixir_insanitydamage.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_insanitydamage.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_shadowfighter.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_shadowfighter.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_lightning.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_lightning.xml"),
	Asset("IMAGE", "images/inventoryimages/newelixir_cleanse.tex"),
	Asset("ATLAS", "images/inventoryimages/newelixir_cleanse.xml"),
}

PrefabFiles = {
	"custom_elixirs",
	"gravestone_placer",
	"nightmare_burst"
}

modimport "scripts/tuning"
modimport "scripts/constants"

-- add tag to all trinket items
for k = 1, GLOBAL.NUM_TRINKETS do
	AddPrefabPostInit("trinket_"..tostring(k), function(inst)
		inst:AddTag("trinket")
	end)
end

modimport "scripts/features/moon_dial_offerings"
modimport "scripts/features/reusable_graves"
modimport "scripts/features/updates_sisturn"
modimport "scripts/features/updates_abigail"
modimport "scripts/features/updates_elixirs"
modimport "scripts/features/updates_wendy"

-- allow items to be offered to the moon dial
-- allow trinkets to be buried in open mounds
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, _)
	if doer:HasTag("elixirbrewer") and target.prefab == "moondial" then
		table.insert(actions, GLOBAL.ACTIONS.MOONOFFERING)
	end
	if inst:HasTag("trinket") and target.prefab == "mound" and target.AnimState:IsCurrentAnimation("dug") then
		table.insert(actions, GLOBAL.ACTIONS.BURY)
	end
end)

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

modimport "scripts/recipes"

-- TODO remove debug mode
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require('debugkeys')
