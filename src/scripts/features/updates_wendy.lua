local elixirs = require "libraries/custom_elixirs_params"

AddPrefabPostInit("wendy", function(wendy)
    if wendy.components.combat ~= nil then
        local old_customdamagemultfn = wendy.components.combat.customdamagemultfn
        wendy.components.combat.customdamagemultfn = function(self, target)
            local abigail = self.components.ghostlybond ~= nil and self.components.ghostlybond.ghost
            local active_elixir = abigail:GetDebuff("elixir_buff")
            local multiplier = 1
            if active_elixir ~= nil and target:HasDebuff("abigail_vex_debuff") then
                if active_elixir.prefab == "newelixir_healthdamage_buff" then
                    multiplier = elixirs.newelixir_healthdamage.calcmultiplier_wendy_vex(self, abigail)
                elseif active_elixir.prefab == "newelixir_insanitydamage_buff" then
                    multiplier = elixirs.newelixir_insanitydamage.calcmultiplier_wendy_vex(self, abigail)
                elseif active_elixir.prefab == "newelixir_shadowfighter_buff" then
                    if target:HasTag("shadowcreature") then
                        multiplier = TUNING.NEW_ELIXIRS.SHADOWFIGHTER.WENDY_VEX.DAMAGE_MULT
                    end
                end
            end
            if old_customdamagemultfn ~= nil then
                multiplier = multiplier * old_customdamagemultfn(self, target)
            end
            return multiplier
        end
    end
end)