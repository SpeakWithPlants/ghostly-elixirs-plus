local elixirs = require "scripts/libraries/custom_elixirs_params"

AddPrefabPostInit("wendy", function(wendy)
    if wendy.components.combat ~= nil then
        local old_customdamagemultfn = wendy.components.combat.customdamagemultfn
        wendy.components.combat.customdamagemultfn = function(self, target)
            local abigail = self.components.ghostlybond ~= nil and self.components.ghostlybond.ghost
            local active_elixir = abigail:GetDebuff("elixir_buff")
            if active_elixir ~= nil and target:HasDebuff("abigail_vex_debuff") then
                if active_elixir.prefab == "newelixir_healthdamage_buff" then
                    return elixirs.newelixir_healthdamage.calcmultiplier_wendy_vex(self)
                elseif active_elixir.prefab == "newelixir_insanitydamage_buff" then
                    return elixirs.newelixir_insanitydamage.calcmultiplier_wendy_vex(self)
                elseif active_elixir.prefab == "newelixir_shadowfighter_buff" then
                    if target:HasTag("shadowcreature") then
                        return TUNING.NEW_ELIXIRS.SHADOWFIGHTER.WENDY_VEX.DAMAGE_MULT
                    end
                end
            end
            if old_customdamagemultfn ~= nil then
                return old_customdamagemultfn(self, target)
            end
        end
    end
end)