-- ============================================
-- 灵晶预制件
-- ============================================
local assets = {
    Asset("ANIM", "anim/spirit_crystal.zip"),
    Asset("ATLAS", "images/inventoryimages/spirit_crystal.xml"),
    Asset("IMAGE", "images/inventoryimages/spirit_crystal.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("spirit_crystal")

    inst.AnimState:SetBank("spirit_crystal")
    inst.AnimState:SetBuild("spirit_crystal")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "spirit_crystal"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/spirit_crystal.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 10

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

    -- 发光效果
    local light = inst.entity:AddLight()
    light:SetIntensity(0.5)
    light:SetRadius(0.4)
    light:SetFalloff(0.7)
    light:SetColour(100/255, 200/255, 255/255)
    light:Enable(true)

    MakeInventoryPhysics(inst)
    MakeSmallBurnable(inst)
    MakeSmallPropFunction(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("spirit_crystal", fn, assets)
