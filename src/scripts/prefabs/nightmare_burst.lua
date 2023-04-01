local assets = {
    Asset("ANIM", "anim/stalker_shield.zip"),
}

local function InsanityBombFn(burst)
    if burst.range_start == burst.range_end then
        burst.range_end = burst.range_start + 1
    end
    local x, y, z = burst.Transform:GetWorldPosition()
    local necessary_tags = { "player" }
    local nearby_players = TheSim:FindEntities(x, y, z, burst.range_end, necessary_tags)
    for _, p in ipairs(nearby_players) do
        if p.components.sanity ~= nil then
            local distance = math.sqrt(p:GetDistanceSqToPoint(x, y, z))
            local distance_proportion = math.clamp((distance - burst.range_start) / (burst.range_end - burst.range_start), 0, 1)
            local distance_multiplier = 1.0 - (math.max(0.0, math.min(1.0, distance_proportion)))
            p.components.sanity:DoDelta(burst.sanitydrain * distance_multiplier)
        end
    end
end

local function MakeBurst(name, scale, sanitydrain, range_end, range_start)
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

        inst.sanitydrain = sanitydrain or -TUNING.SANITY_LARGE
        inst.range_end = range_end or 10.0
        inst.range_start = range_start or 5.0
        inst.InsanityBombFn = InsanityBombFn

        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

        inst.persists = false
        inst:ListenForEvent("animover", inst.Remove)
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)
        inst:DoTaskInTime(0.1, InsanityBombFn)

        return inst
    end

    return Prefab(name, fn, assets)
end

return  MakeBurst("nightmare_burst", 1.5, -TUNING.SANITY_HUGE),
        MakeBurst("nightmare_burst_small", 1.0, -TUNING.SANITY_LARGE)