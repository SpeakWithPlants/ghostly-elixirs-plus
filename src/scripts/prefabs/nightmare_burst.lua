local assets = {
    Asset("ANIM", "anim/stalker_shield.zip"),
}

local function InsanityBombFn(burst)
    -- TODO decrease sanity of all nearby players
end

local function MakeBurst(name, scale)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        local n = math.random(4)
        local sx = n == 4 and -scale or scale
        local sy = scale
        local sz = scale

        inst.AnimState:SetBank("stalker_shield")
        inst.AnimState:SetBuild("stalker_shield")
        inst.AnimState:PlayAnimation("idle"..tostring(math.min(3, n)))
        inst.AnimState:SetFinalOffset(2)
        inst.AnimState:SetScale(sx, sy, sz)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then return inst end

        inst.InsanityBombFn = InsanityBombFn

        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

        inst.persists = false
        inst:ListenForEvent("animover", inst.Remove)
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)
        inst:DoTaskInTime(0, InsanityBombFn)

        return inst
    end

    return Prefab(name, fn, assets)
end

return  MakeBurst("nightmare_burst", 1.5),
        MakeBurst("nightmare_burst_small", 1.0)