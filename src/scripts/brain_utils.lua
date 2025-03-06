function FindBehaviorNodeAt(brain, node_path)
    local current_node = brain.bt.root
    local current_index = 1
    while current_index <= #node_path do
        for i, child in ipairs(current_node.children) do
            if i == node_path[current_index] then
                current_node = child
                break
            end
        end
        current_index = current_index + 1
    end
    return current_node
end

function FindAbigailFollowNode(abigailbrain)
    return FindBehaviorNodeAt(abigailbrain, { 1, 2, 5, 2, 6 })
end