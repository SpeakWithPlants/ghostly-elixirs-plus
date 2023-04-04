local elixirs = require "libraries/custom_elixirs_params"

AddPrefabPostInit("wendy", function(wendy)
    if wendy.components.combat ~= nil then
        local old_customdamagemultfn = wendy.components.combat.customdamagemultfn
        wendy.components.combat.customdamagemultfn = function(self, target, weapon)
            local abigail = self.components.ghostlybond ~= nil and self.components.ghostlybond.ghost
            local active_buff = abigail:GetDebuff("elixir_buff")
            local multiplier = 1
            if active_buff ~= nil and target:HasDebuff("abigail_vex_debuff") then
                if active_buff.prefab == "newelixir_healthdamage_buff" then
                    multiplier = elixirs.newelixir_healthdamage.calcmultiplier_wendy_vex(self, abigail)
                end
                if active_buff.prefab == "newelixir_insanitydamage_buff" then
                    multiplier = elixirs.newelixir_insanitydamage.calcmultiplier_wendy_vex(self, abigail)
                end
                if active_buff.prefab == "newelixir_shadowfighter_buff" then
                    if target:HasTag("shadowcreature") then
                        multiplier = TUNING.NEW_ELIXIRS.SHADOWFIGHTER.WENDY_VEX.DAMAGE_MULT
                    end
                end
                if active_buff.potion_tunings.nightmare and weapon ~= nil and weapon.prefab == "nightsword" then
                    multiplier = multiplier * TUNING.NEW_ELIXIRS.ALL_NIGHTMARE_ELIXIRS.DARK_SWORD_VEX_MULT
                end
            end
            if multiplier == 1 and old_customdamagemultfn ~= nil then
                return old_customdamagemultfn(self, target)
            end
            return multiplier
        end
    end
end)