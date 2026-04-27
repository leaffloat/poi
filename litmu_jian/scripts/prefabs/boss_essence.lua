-- ============================================
-- 晶髓预制件（参考 Carney MOD 写法）
-- ============================================
local assets = {
    Asset("ANIM", "anim/boss_essence.zip"),
    Asset("ATLAS", "images/inventoryimages/boss_essence.xml"),
    Asset("IMAGE", "images/inventoryimages/boss_essence.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boss_essence")
    inst.AnimState:SetBuild("boss_essence")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("boss_essence")
    inst:AddTag("essence")
    inst:AddTag("forge_material")
    inst:AddTag("precious")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "boss_essence"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/boss_essence.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 20

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

    -- 发光效果（紫色光）
    local light = inst.entity:AddLight()
    light:SetIntensity(0.5)
    light:SetRadius(0.5)
    light:SetFalloff(0.7)
    light:SetColour(200/255, 150/255, 255/255)
    light:Enable(true)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("boss_essence", fn, assets)
