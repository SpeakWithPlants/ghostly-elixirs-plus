local function buff_OnTick(inst, target)
	if target.components.health ~= nil and not target.components.health:IsDead() then
			inst.potion_tunings.ONTICK(inst, target)
	else
			inst.components.debuff:Stop()
	end
end

local function buff_DripFx(inst, target)
	if not target.inlimbo and not target.sg:HasStateTag("busy") then
			local x, y, z = target.Transform:GetWorldPosition()
			if inst.potion_tunings.dripfx == "electrichitsparks" then
				y = y + 1.5
			end
			SpawnPrefab(inst.potion_tunings.dripfx).Transform:SetPosition(x, y, z)
	end
end

local function buff_OnTimerDone(inst, data)
	if data.name == "decay" then
		inst.components.debuff:Stop()
	end
end

local function buff_OnAttached(inst, target)
	inst.entity:SetParent(target.entity)
	inst.Transform:SetPosition(0, 0, 0)

	target:SetNightmareAbigail(inst.potion_tunings.NIGHTMARE_ELIXIR)
	if inst.potion_tunings.NIGHTMARE_ELIXIR then
		local nightmare_core = SpawnPrefab("newelixir_nightmare_core")
		nightmare_core.entity:SetParent(target.entity)
		nightmare_core.Transform:SetPosition(0, 0, 0)
		target.nightmare_core = nightmare_core
	end

	if inst.potion_tunings.ONAPPLY ~= nil then
		inst.potion_tunings.ONAPPLY(inst, target)
	end

	if inst.potion_tunings.ONTICK ~= nil then
		inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
	end

	inst.driptask = inst:DoPeriodicTask(TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY, buff_DripFx, TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY * 0.25, target)

	inst:ListenForEvent("death", function()
		inst.components.debuff:Stop()
	end, target)

	if inst.potion_tunings.fx ~= nil and not target.inlimbo then
		local fx = SpawnPrefab(inst.potion_tunings.fx)
		fx.entity:SetParent(target.entity)
	end
end

local function buff_OnExtended(inst, target)
	if (inst.components.timer:GetTimeLeft("decay") or 0) < inst.potion_tunings.DURATION then
		inst.components.timer:StopTimer("decay")
		inst.components.timer:StartTimer("decay", inst.potion_tunings.DURATION)
	end
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
	end

	if inst.potion_tunings.fx ~= nil and not target.inlimbo then
		local fx = SpawnPrefab(inst.potion_tunings.fx)
		fx.entity:SetParent(target.entity)
	end
end

local function buff_OnDetached(inst, target)
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
	end
	if inst.driptask ~= nil then
		inst.driptask:Cancel()
		inst.driptask = nil
	end

	target:SetNightmareAbigail(false)
	if target.nightmare_core ~= nil then
		target.nightmare_core:Remove()
		target.nightmare_core = nil
	end

	if inst.potion_tunings.ONDETACH ~= nil then
		inst.potion_tunings.ONDETACH(inst, target)
	end
	inst:Remove()
end

local function post_init_buff_fn(inst, _, data)
	inst.entity:Hide()
	inst.persists = false

	inst.potion_tunings = data

	inst:AddTag("CLASSIFIED")

	inst:AddComponent("debuff")
	inst.components.debuff:SetAttachedFn(buff_OnAttached)
	inst.components.debuff:SetDetachedFn(buff_OnDetached)
	inst.components.debuff:SetExtendedFn(buff_OnExtended)
	inst.components.debuff.keepondespawn = true

	inst:AddComponent("timer")
	inst.components.timer:StartTimer("decay", data.DURATION)
	inst:ListenForEvent("timerdone", buff_OnTimerDone)

	return inst
end

local function nightmare_elixir_core_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddNetwork()

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddTag("NOCLICK")

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE

	return inst
end

-- attempt lightning strike on nearby enemies
local function try_smite_fn(attacker)
	if math.random() < TUNING.ELIXIRS_PLUS.LIGHTNING.SMITE_CHANCE then
		local x, y, z = attacker.Transform:GetWorldPosition()
		local necessarytags = { "_combat" }
		local ignoretags = {}
		local radius = 4
		if attacker.components.aura ~= nil then
			ignoretags = attacker.components.aura.auraexcludetags or {}
			radius = attacker.components.aura.radius or 4
		end
		local ents = TheSim:FindEntities(x, y, z, radius, necessarytags, ignoretags)
		local smitees = {}
		local found = false
		for i, ent in ipairs(ents) do
			if attacker:auratest(ent) then
				smitees[i] = ent
				found = true
			end
		end
		if not found then return end
		local smitee = GetRandomItem(smitees)
		if smitee ~= nil then
			TheWorld:PushEvent("ms_sendlightningstrike", smitee:GetPosition())
		end
	end
end

-- bonus damage function for wet enemies
local function zap_damage_fn(attacker, target, damage)
	if target ~= nil and target:GetIsWet() then
		SpawnPrefab("electrichitsparks"):AlignToTarget(target, attacker, true)
		return damage * 1.5
	end
	return damage * 0.5
end

-- bonus damage function for low wendy sanity
local function insane_damage_fn(attacker, _, damage)
	if attacker._playerlink ~= nil and attacker._playerlink.components.sanity ~= nil then
		local sanity_level = attacker._playerlink.components.sanity:GetPercent()
		return damage * (1 - sanity_level)
	end
end

-- bonus damage function for low wendy health
local function health_vex_damage_fn(abigail, reset)
	if not reset then
		if abigail._playerlink ~= nil and abigail._playerlink.components.health ~= nil then
			local health_level = abigail._playerlink.components.health:GetPercent()
			if health_level <= TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.LOW_HEALTH then
				TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.CRIT_DAMAGE_MULT
			elseif health_level <= TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.MED_HEALTH then
				TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.HIGH_DAMAGE_MULT
			elseif health_level <= TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.HIGH_HEALTH then
				TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.MED_DAMAGE_MULT
			else
				TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.LOW_DAMAGE_MULT
			end
		end
	else
		TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = TUNING.ELIXIRS_PLUS.HEALTHDAMAGE.LOW_DAMAGE_MULT
	end
end

local potion_tunings = {
	-- complete elixir tunings
	newelixir_sanityaura = {
		NIGHTMARE_ELIXIR = false,
		DURATION = TUNING.TOTAL_DAY_TIME,
		ONAPPLY = function(_, target)
			target:AddComponent("sanityaura")
			target.components.sanityaura.aura = TUNING.ELIXIRS_PLUS.SANITYAURA.AURA
			if target._playerlink ~= nil then
				target._playerlink.components.sanity:RemoveSanityAuraImmunity("ghost")
			end
		end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
	},
	newelixir_lightaura = {
		NIGHTMARE_ELIXIR = false,
		DURATION = TUNING.TOTAL_DAY_TIME,
		PREFABFN = function(elixir_type, data)
			local inst = CreateEntity()

			inst.entity:AddTransform()
			inst.entity:AddLight()
			inst.entity:AddNetwork()

			inst:AddTag("FX")

			inst.Light:SetIntensity(.5)
			inst.Light:SetRadius(TUNING.ELIXIRS_PLUS.LIGHTAURA.LIGHT_RADIUS)
			inst.Light:SetFalloff(1)
			inst.Light:Enable(true)
			inst.Light:SetColour(255 / 255, 160 / 255, 160 / 255)

			inst.entity:SetPristine()

			if not TheWorld.ismastersim then
				return inst
			end

			return post_init_buff_fn(inst, elixir_type, data)
		end,
		ONAPPLY = function(_, target)
			target:AddComponent("heater")
			target.components.heater.heat = TUNING.ELIXIRS_PLUS.LIGHTAURA.TEMPERATURE
		end,
		ONDETACH = function(_, target)
			target:RemoveComponent("heater")
		end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
	},
	newelixir_healthdamage = {
		NIGHTMARE_ELIXIR = false,
		DURATION = TUNING.TOTAL_DAY_TIME,
		TICK_RATE = 0.5,
		ONTICK = function(_, target)
			health_vex_damage_fn(target)
		end,
		ONDETACH = function(_, target)
			health_vex_damage_fn(target, true)
		end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
	},
	newelixir_cleanse = {
		NIGHTMARE_ELIXIR = false,
		DURATION = 0.1,
		ONAPPLY = function(_, target)
			local healing = target.components.health:GetMaxWithPenalty() * TUNING.ELIXIRS_PLUS.CLEANSE.HEAL_MULT
			target.components.health:DoDelta(healing)
			if target._playerlink ~= nil then
				target._playerlink.components.sanity:DoDelta(TUNING.ELIXIRS_PLUS.CLEANSE.SANITY_GAIN)
			end
		end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
	},
	newelixir_insanitydamage = {
		NIGHTMARE_ELIXIR = true,
		DURATION = TUNING.TOTAL_DAY_TIME * 0.5,
		TICK_RATE = 0.5,
		ONAPPLY = function(_, target)
			if target.components.combat ~= nil then
				target.components.combat.bonusdamagefn = insane_damage_fn
			end
		end,
		ONDETACH = function(_, target)
			if target.components.combat ~= nil then
				target.components.combat.bonusdamagefn = nil
			end
		end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
	},
	newelixir_shadowfighter = {
		NIGHTMARE_ELIXIR = true,
		DURATION = TUNING.TOTAL_DAY_TIME * 0.5,
		ONAPPLY = function(_, target)
			target:AddTag("crazy")
		end,
		ONDETACH = function(_, target)
			target:RemoveTag("crazy")
		end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
	},
	newelixir_lightning = {
		NIGHTMARE_ELIXIR = true,
		DURATION = TUNING.TOTAL_DAY_TIME * 0.5,
		ONAPPLY = function(_, target)
			if target.components.combat ~= nil then
				target.components.combat.bonusdamagefn = zap_damage_fn
			end
			if target.components.aura ~= nil then
				target.components.aura.pretickfn = try_smite_fn
			end
		end,
		ONDETACH = function(_, target)
			if target.components.combat ~= nil then
				target.components.combat.bonusdamagefn = nil
			end
			if target.components.aura ~= nil then
				target.components.aura.pretickfn = nil
			end
		end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "electrichitsparks",
	},

	-- this one is just for copy/pasting
	--[[
	newelixir_unused = {
		NIGHTMARE_ELIXIR = false,
		DURATION = TUNING.TOTAL_DAY_TIME * 0.5,
		PREFABFN = function(elixir_type, data) end,
		-- inst is the buff prefab, target is abigail
		ONAPPLY = function(inst, target) end,
		ONTICK = function(inst, target) end,
		ONDETACH = function(inst, target) end,
		fx = "ghostlyelixir_slowregen_fx",
		dripfx = "ghostlyelixir_slowregen_dripfx",
	},
	]]
}

local function buff_fn(elixir_type, data)
	local inst = CreateEntity()

	if not TheWorld.ismastersim then
		-- Not meant for client!
		inst:DoTaskInTime(0, inst.Remove)
		return inst
	end

	inst.entity:AddTransform()
	return post_init_buff_fn(inst, elixir_type, data)
end

local function elixir_fn(elixir_type, data, buff_prefab)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("new_elixirs")
	inst.AnimState:SetBuild("new_elixirs")
	inst.AnimState:PlayAnimation(elixir_type)

	inst:AddTag("ghostlyelixir")

	MakeInventoryFloatable(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.buff_prefab = buff_prefab
	inst.potion_tunings = data

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "newelixir_"..elixir_type
	inst.components.inventoryitem.atlasname = "images/inventoryimages/newelixir_"..elixir_type..".xml"

	inst:AddComponent("stackable")

	inst:AddComponent("ghostlyelixir")
	--inst.components.ghostlyelixir.doapplyelixerfn = DoApplyElixir

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

	return inst
end

local function AddElixir(elixirs, name)
	local elixir_prefab = "newelixir_"..name
	local buff_prefab = elixir_prefab.."_buff"

	local assets = {
		Asset("ANIM", "anim/new_elixirs.zip"),
		Asset("ANIM", "anim/abigail_buff_drip.zip"),
	}
	local prefabs = {
		buff_prefab,
		potion_tunings[elixir_prefab].fx,
		potion_tunings[elixir_prefab].dripfx,
	}
	-- insert shield_prefab into prefabs here
	local function _buff_fn()
		if potion_tunings[elixir_prefab].PREFABFN ~= nil then
			return potion_tunings[elixir_prefab].PREFABFN(elixir_prefab, potion_tunings[elixir_prefab])
		else
			return buff_fn(elixir_prefab, potion_tunings[elixir_prefab])
		end
	end
	local function _elixir_fn() return elixir_fn(name, potion_tunings[elixir_prefab], buff_prefab) end

	table.insert(elixirs, Prefab(elixir_prefab, _elixir_fn, assets, prefabs))
	table.insert(elixirs, Prefab(buff_prefab, _buff_fn))
end

local elixirs = {}
AddElixir(elixirs, "sanityaura")
AddElixir(elixirs, "lightaura")
AddElixir(elixirs, "healthdamage")
AddElixir(elixirs, "cleanse")
AddElixir(elixirs, "insanitydamage")
AddElixir(elixirs, "shadowfighter")
AddElixir(elixirs, "lightning")
table.insert(elixirs, Prefab("newelixir_nightmare_core", nightmare_elixir_core_fn, {}, {}))
return unpack(elixirs)
