local elixirs = require "libraries/custom_elixirs_params"

local all_elixir_prefabs = {
    "ghostlyelixir_slowregen",
    "ghostlyelixir_fastregen",
    "ghostlyelixir_speed",
    "ghostlyelixir_attack",
    "ghostlyelixir_shield",
    "ghostlyelixir_retaliation",
    "newelixir_sanityaura",
    "newelixir_lightaura",
    "newelixir_healthdamage",
    "newelixir_insanitydamage",
    "newelixir_shadowfighter",
    "newelixir_lightning",
    "newelixir_cleanse",
}
for _, elixir in ipairs(all_elixir_prefabs) do
    AddPrefabPostInit(elixir, function(self)
        if self.components.ghostlyelixir ~= nil then
            self.components.ghostlyelixir.doapplyelixerfn = elixirs.all_elixirs.doapplyelixirfn
        end
    end)
end

-- update (improve) old elixir buffs
AddPrefabPostInit("ghostlyelixir_speed", function(elixir)
    if not elixir.potion_tunings then
        return
    end
    local old_apply_fn = elixir.potion_tunings.ONAPPLY
    elixir.potion_tunings.ONAPPLY = function(self, abigail)
        if old_apply_fn ~= nil then
            old_apply_fn(self, abigail)
        end
        if elixirs.ghostlyelixir_speed.onattachfn ~= nil then
            elixirs.ghostlyelixir_speed.onattachfn(abigail)
        end
    end

    local old_detach_fn = elixir.potion_tunings.ONDETACH
    elixir.potion_tunings.ONDETACH = function(self, abigail)
        if old_detach_fn ~= nil then
            old_detach_fn(self, abigail)
        end
        if elixirs.ghostlyelixir_speed.ondetachfn ~= nil then
            elixirs.ghostlyelixir_speed.ondetachfn(abigail)
        end
    end
end)

AddPrefabPostInit("ghostlyelixir_slowregen", function(elixir)
    if not elixir.potion_tunings then
        return
    end
    local old_apply_fn = elixir.potion_tunings.ONAPPLY
    elixir.potion_tunings.ONAPPLY = function(self, abigail)
        if old_apply_fn ~= nil then
            old_apply_fn(self, abigail)
        end
        if abigail._playerlink ~= nil then
            abigail._playerlink.components.ghostlybond:SetBondTimeMultiplier(self.prefab, TUNING.NEW_ELIXIRS.SLOWREGEN.BOND_TIME_MULT)
        end
    end

    local old_detach_fn = elixir.potion_tunings.ONDETACH
    elixir.potion_tunings.ONDETACH = function(self, abigail)
        if old_detach_fn ~= nil then
            old_detach_fn(self, abigail)
        end
        if abigail._playerlink ~= nil then
            abigail._playerlink.components.ghostlybond:SetBondTimeMultiplier(self.prefab, nil)
        end
    end
end)