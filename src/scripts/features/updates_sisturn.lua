local CONTAINERS = require("containers")

local OldItemTestFn = CONTAINERS.params.sisturn.itemtestfn

CONTAINERS.params.sisturn.itemtestfn = function(container, item, slot)
    return OldItemTestFn(container, item, slot) or item.prefab == "glommerflower"
end
