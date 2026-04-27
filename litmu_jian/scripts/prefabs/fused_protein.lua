-- ============================================
-- 融合角质预制件
-- ============================================
local assets = {
    Asset("ANIM", "anim/fused_protein.zip"),
    Asset("ATLAS", "images/inventoryimages/fused_protein.xml"),
    Asset("IMAGE", "images/inventoryimages/fused_protein.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("fused_protein")

    inst.AnimState:SetBank("fused_protein")
    inst.AnimState:SetBuild("fused_protein")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "fused_protein"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/fused_protein.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 10

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

    MakeInventoryPhysics(inst)
    MakeSmallBurnable(inst)
    MakeSmallPropFunction(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("fused_protein", fn, assets)
