function FindBehaviorNodeAt(brain, node_path)
    local current_node = brain.bt.root
    local current_index = 1
    while current_index <= #node_path do
        local search_name = node_path[current_index]
        local found = false
        for _, child in ipairs(current_node.children) do
            if child.name == search_name then
                current_node = child
                found = true
                break
            end
        end
        if not found then
            return nil
        end
        current_index = current_index + 1
    end
    return current_node
end