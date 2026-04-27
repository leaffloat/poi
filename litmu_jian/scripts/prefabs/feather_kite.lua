-- scripts/prefabs/feather_kite.lua
-- 羽毛风筝：右键站立上面进入凌空状态
-- 加速效果不与步行手杖/小木剑等同时生效

local assets = {
    Asset("ANIM", "anim/feather_kite.zip"),
    Asset("ATLAS", "images/inventoryimages/feather_kite.xml"),
    Asset("IMAGE", "images/inventoryimages/feather_kite.tex"),
}

local prefabs = {}

-- ============================================
-- 设计文档v4 数值配置
-- ============================================
local BASE_SPEED_BONUS = 0.10      -- 基础+10%移速
local BASE_DURATION = 360          -- 6分钟 = 360秒

-- 羽毛类型及配置
-- 红羽10+灵晶×2 → 1分钟
-- 蓝羽5+灵晶×2  → 1分钟
-- 黑羽20+灵晶×2 → 1分钟
-- 黄羽2+灵晶×3  → 2分钟
-- 鹅羽5+灵晶×3  → 2分钟
-- 翁羽5+灵晶×3  → 2分钟
-- 叠加到9分钟后变为永久
local FEATHER_TYPES = {
    red_feather   = { count = 10, spirit = 2, duration = 60,  speed = 0.25, tag = "red",  display = "红羽" },
    blue_feather  = { count = 5,  spirit = 2, duration = 60,  speed = 0.25, tag = "blue", display = "蓝羽" },
    black_feather = { count = 20, spirit = 2, duration = 60,  speed = 0.25, tag = "black", display = "黑羽" },
    gold_feather  = { count = 2,  spirit = 3, duration = 120, speed = 0.50, tag = "gold", display = "黄羽" },
    goose_feather = { count =5,  spirit = 3, duration = 120, speed = 0.50, tag = "goose", display = "鹅羽" },
    malbatross_feather = { count =5, spirit = 3, duration = 120, speed = 0.50, tag = "malbatross", display = "翁羽" },
}

local PERMANENT_TOTAL_DURATION = 540  -- 9分钟 = 540秒，达到后变永久

-- ============================================
-- 风筝数据
-- ============================================
local function init_kite_data(inst)
    inst._kite_data = {
        active_effects = {},      -- {tag = {speed, end_time}}
        all_collected = {red=false, blue=false, black=false, gold=false, goose=false, malbatross=false},
        is_permanent = false,      -- 永久站立
        is_active = false,         -- 是否在凌空状态
        remaining_duration = 0,    -- 剩余时间（秒）
        total_speed = BASE_SPEED_BONUS,
    }
end

-- ============================================
-- 计算总移速
-- ============================================
local function calc_total_speed(inst)
    local data = inst._kite_data
    if data.is_permanent then 
        return 1.0  -- 永久最大加速+100%
    end

    local total = BASE_SPEED_BONUS
    local now = GetTime()
    for tag, effect in pairs(data.active_effects) do
        if effect.end_time > now then
            total = total + effect.speed
        else
            data.active_effects[tag] = nil
        end
    end
    return total
end

-- ============================================
-- 更新移速（不与手杖/小木剑叠加）
-- ============================================
local function update_speed(inst, owner)
    if not owner or not owner.components.locomotor then return end
    
    -- 检查是否有冲突的加速装备
    local has_conflict = false
    if owner.components.inventory then
        local equipped = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equipped and (equipped.prefab == "cane" or equipped.prefab == "wooden_sword") then
            has_conflict = true
        end
    end
    
    if has_conflict then
        owner.components.locomotor:RemoveExternalSpeedAdder(inst, "feather_kite_speed")
    else
        local speed = calc_total_speed(inst)
        owner.components.locomotor:SetExternalSpeedAdder(inst, "feather_kite_speed", speed)
    end
end

-- ============================================
-- 添加羽毛效果
-- ============================================
local function add_feather_effect(inst, feather_type)
    local data = inst._kite_data
    local ftype = FEATHER_TYPES[feather_type]
    if not ftype then return false end

    -- 标记已收集
    data.all_collected[ftype.tag] = true

    -- 计算当前总持续时间
    local total_duration = 0
    for _, effect in pairs(data.active_effects) do
        local remaining = effect.end_time - GetTime()
        if remaining > 0 then
            total_duration = total_duration + remaining
        end
    end
    total_duration = total_duration + ftype.duration
    
    -- 检查是否达到永久
    if total_duration >= PERMANENT_TOTAL_DURATION then
        data.is_permanent = true
        data.active_effects = {}
    else
        data.active_effects[ftype.tag] = {
            speed = ftype.speed,
            end_time = GetTime() + ftype.duration,
        }
    end
    
    data.total_speed = calc_total_speed(inst)
    
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        update_speed(inst, owner)
    end
    
    return true
end

-- ============================================
-- 活化风筝（右键站立）
-- ============================================
local function activate_kite(inst, doer)
    if not doer then return false end
    
    local data = inst._kite_data
    
    if data.is_active then return false end
    
    if not data.is_permanent then
        local now = GetTime()
        local has_active = false
        for _, effect in pairs(data.active_effects) do
            if effect.end_time > now then
                has_active = true
                break
            end
        end
        if not has_active then
            if doer.components.talker then
                doer.components.talker:Say("羽毛风筝没有能量了，需要添加更多羽毛！")
            end
            return false
        end
    end
    
    data.is_active = true
    
    if doer.components.locomotor then
        update_speed(inst, doer)
    end
    
    if doer.components.talker then
        doer.components.talker:Say("站在羽毛风筝上，准备起飞！")
    end
    
    inst._active_task = inst:DoPeriodicTask(1, function()
        local current_owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if not current_owner or current_owner ~= doer then
            if inst._active_task then
                inst._active_task:Cancel()
                inst._active_task = nil
            end
            data.is_active = false
            return
        end
        
        if not data.is_permanent then
            local need_clean = false
            local now = GetTime()
            for tag, effect in pairs(data.active_effects) do
                if effect.end_time <= now then
                    data.active_effects[tag] = nil
                    need_clean = true
                end
            end
            if need_clean then
                data.total_speed = calc_total_speed(inst)
                update_speed(inst, doer)
            end
            
            local has_effect = false
            for _ in pairs(data.active_effects) do
                has_effect = true
                break
            end
            if not has_effect then
                if inst._active_task then
                    inst._active_task:Cancel()
                    inst._active_task = nil
                end
                data.is_active = false
                update_speed(inst, doer)
                if doer.components.talker then
                    doer.components.talker:Say("羽毛风筝能量耗尽了！")
                end
            end
        end
    end)
    
    return true
end

-- ============================================
-- 拾取/丢弃回调
-- ============================================
local function onpickup(inst, picker)
    local data = inst._kite_data
    if not data.is_active then
        update_speed(inst, picker)
    end
end

local function ondrop(inst)
    local data = inst._kite_data
    if data.is_active then
        data.is_active = false
        if inst._active_task then
            inst._active_task:Cancel()
            inst._active_task = nil
        end
    end
    
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.locomotor then
        owner.components.locomotor:RemoveExternalSpeedAdder(inst, "feather_kite_speed")
    end
end

-- ============================================
-- 装备回调
-- ============================================
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "feather_kite", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if not inst._kite_data.is_active then
        update_speed(inst, owner)
    end
end

-- ============================================
-- 卸下回调
-- ============================================
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    if owner and owner.components.locomotor then
        owner.components.locomotor:RemoveExternalSpeedAdder(inst, "feather_kite_speed")
    end
end

-- ============================================
-- 主函数
-- ============================================
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("feather_kite")
    inst.AnimState:SetBuild("feather_kite")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("feather_kite")
    inst:AddTag("nopassable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    init_kite_data(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/feather_kite.xml"
    inst.components.inventoryitem.imagename = "feather_kite"
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem:SetOnDroppedFn(ondrop)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- 燃料组件（右键激活）
    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetMaxUses(PERMANENT_TOTAL_DURATION)
    inst.components.fueled:SetUses(PERMANENT_TOTAL_DURATION)
    
    -- 暴露API
    inst.add_feather_effect = add_feather_effect
    inst.activate_kite = activate_kite

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("feather_kite", fn, assets, prefabs)