-- scripts/prefabs/initial_kite.lua
-- 参考 Carney MOD 写法

local assets = {
    Asset("ANIM", "anim/initial_kite.zip"),
    Asset("ATLAS", "images/inventoryimages/initial_kite.xml"),
    Asset("IMAGE", "images/inventoryimages/initial_kite.tex"),
}

local KITE_DURATION = 360  -- 6分钟
local SPEED_BONUS = 0.10   -- +10%移速

-- 装备回调（参考 Carney 使用 SpeedAdder）
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "initial_kite", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if owner and owner.components.locomotor then
        owner.components.locomotor:SetExternalSpeedAdder(inst, SPEED_BONUS)
    end
end

-- 卸下回调
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    if owner and owner.components.locomotor then
        owner.components.locomotor:RemoveExternalSpeedAdder(inst, SPEED_BONUS)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("initial_kite")
    inst.AnimState:SetBuild("initial_kite")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("kite")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/initial_kite.xml"
    inst.components.inventoryitem.imagename = "initial_kite"

    inst:AddComponent("inspectable")

    -- 装备组件
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- 耐久：6分钟
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(KITE_DURATION)
    inst.components.finiteuses:SetUses(KITE_DURATION)
    inst.components.finiteuses:SetOnFinished(function(inst)
        if inst.components.equippable and inst.components.equippable.owner then
            onunequip(inst, inst.components.equippable.owner)
        end
        inst:Remove()
    end)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("initial_kite", fn, assets)