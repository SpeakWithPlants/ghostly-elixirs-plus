local elixirs = require "libraries/custom_elixirs_params"

for _, elixir in ipairs(elixirs.all_elixir_prefabs) do
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
            elixirs.ghostlyelixir_speed.onattachfn(self, abigail)
        end
    end

    local old_detach_fn = elixir.potion_tunings.ONDETACH
    elixir.potion_tunings.ONDETACH = function(self, abigail)
        if old_detach_fn ~= nil then
            old_detach_fn(self, abigail)
        end
        if elixirs.ghostlyelixir_speed.ondetachfn ~= nil then
            elixirs.ghostlyelixir_speed.ondetachfn(self, abigail)
        end
    end
end)
if elixirs.ghostlyelixir_speed.new_speed_mult ~= nil then
    TUNING.GHOSTLYELIXIR_SPEED_LOCO_MULT = elixirs.ghostlyelixir_speed.new_speed_mult
end

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