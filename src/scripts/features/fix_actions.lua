local function find_elixirable_fn(item) return item.components.ghostlyelixirable ~= nil end
GLOBAL.ACTIONS.APPLYELIXIR.fn = function(act)
    local doer = act.doer
    local object = act.invobject
    if doer and object and doer.components.inventory then
        if act.target and act.target:HasTag("elixir_drinker") then
            if object:HasTag("super_elixir") then
                return false, "TOO_SUPER"
            else
                return object.components.ghostlyelixir:Apply(doer, act.target)
            end
        else
            local elixirable_item = doer.components.inventory:FindItem(find_elixirable_fn)
            if elixirable_item then
                return object.components.ghostlyelixir:Apply(doer, elixirable_item)
            else
                return false, "NO_ELIXIRABLE"
            end
        end
    end
end