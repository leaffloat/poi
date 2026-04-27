-- ============================================
-- 锻造炉预制件（参考 Carney MOD 写法）
-- ============================================
local assets = {
    Asset("ANIM", "anim/forge.zip"),
    Asset("ATLAS", "images/inventoryimages/forge.xml"),
    Asset("IMAGE", "images/inventoryimages/forge.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("forge")
    inst.AnimState:SetBuild("forge")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("forge")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "forge"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/forge.xml"

    inst:AddComponent("inspectable")

    -- 容器组件（5格子：上4 材料 + 下1 武器）
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("forge", 5)
    inst.components.container.onopen = function(inst)
        if inst.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/common/craftable")
        end
    end
    inst.components.container.onclose = function(inst)
        if inst.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/common/crafting")
        end
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("forge", fn, assets)
