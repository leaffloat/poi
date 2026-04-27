-- 小木箭预制件（参考 Carney 写法）
local assets = {
    Asset("ANIM", "anim/wooden_arrow.zip"),
    Asset("ATLAS", "images/inventoryimages/wooden_arrow.xml"),
    Asset("IMAGE", "images/inventoryimages/wooden_arrow.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wooden_arrow")
    inst.AnimState:SetBuild("wooden_arrow")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wooden_arrow.xml"
    inst.components.inventoryitem.imagename = "wooden_arrow"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 100

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHitDamage(20)

    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wooden_arrow", fn, assets)