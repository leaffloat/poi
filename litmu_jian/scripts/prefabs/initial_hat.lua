-- scripts/prefabs/initial_hat.lua
-- 初始帽子：二本科技制作，绳子×2 + 莎草纸×2
-- 效果：+1san值，50%防御，100耐久
-- 可通过锻造炉升级

local assets = {
    Asset("ANIM", "anim/initial_hat.zip"),
    Asset("ATLAS", "images/inventoryimages/initial_hat.xml"),
    Asset("IMAGE", "images/inventoryimages/initial_hat.tex"),
}

local prefabs = {}

-- ============================================
-- 初始属性（设计文档v4）
-- ============================================
local INITIAL_DEFENSE = 0.50      -- 50%防御
local INITIAL_DURABILITY = 100     -- 100耐久
local INITIAL_SANITY_BONUS = 1     -- +1 san/min

-- ============================================
-- 装备/卸下回调（参考 Carney）
-- ============================================
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "initial_hat", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
end

-- ============================================
-- 帽子状态数据
-- ============================================
local function init_hat_data(inst)
    inst._hat_data = {
        -- 防御锻造阶段
        defense_tier = 0,          -- 0=基础, 1=金块, 2=大理石, 3=钢羊毛
        defense_pct = INITIAL_DEFENSE,
        durability = INITIAL_DURABILITY,
        max_durability = INITIAL_DURABILITY,

        -- 免疫/特殊
        fire_immunity = false,     -- 龙蝇鳞片
        freeze_immunity = 0,       -- 熊皮：免疫层数
        anti_angry_bees = false,   -- 蜜脾
        anti_angry_beefalo = false, -- 牛角
        anti_bunnyman_meat = false, -- 兔绒
        can_shell = false,         -- 外壳碎片×20
        has_rainbow_gem = false,   -- 彩虹宝石
        rainbow_cooldown = 0,
        rainbow_active = false,
        rainbow_timer = 0,
        windproof = false,         -- 猪皮×4：防风

        -- 插槽（萤火虫开启）
        has_slot = false,
        slot_contents = {},
        is_eternal_light = false,  -- 启迪碎片：永亮
        slot_light_cooldown = 0,   -- 插槽照明冷却

        -- 保暖阶段（必须按顺序）
        warmth_tier = 0,           -- 0=无, 1=牛毛, 2=贝雷帽
        warmth = 0,
        sanity_bonus = INITIAL_SANITY_BONUS,

        -- 防水阶段（必须按顺序）
        waterproof_tier = 0,       -- 0=无, 1=蜘蛛丝, 2=饼干切割机壳
        waterprooftness = 0,

        -- 隔热阶段（必须按顺序）
        insulation_tier = 0,       -- 0=无, 1=多肉植物, 2=仙人掌花
        insulation = 0,
    }
end

-- ============================================
-- 更新帽子数值
-- ============================================
local function update_hat_stats(inst)
    local data = inst._hat_data
    
    -- 更新armor
    if inst.components.armor then
        inst.components.armor:SetAbsorption(data.defense_pct)
        inst.components.armor:SetCondition(data.durability, data.max_durability)
    end
    
    -- 更新insulator（保暖/隔热）
    if inst.components.insulator then
        inst.components.insulator:SetSummer(data.insulation)
        inst.components.insulator:SetWinter(data.warmth)
    end
    
    -- 更新waterproofer
    if inst.components.waterproofer then
        inst.components.waterproofer:SetEffectiveness(data.waterprooftness)
    end
    
    -- 更新dapper (san值)
    if inst.components.dapper then
        inst.components.dapper:SetBonus(data.sanity_bonus)
    end
end

-- ============================================
-- 防御路线（必须按顺序）
-- ============================================
local function upgrade_defense(inst, material)
    local data = inst._hat_data

    if material == "goldnugget" and data.defense_tier == 0 then
        -- 金块×4 → +80%防御，1000耐久
        data.defense_tier = 1
        data.defense_pct = 0.80
        data.max_durability = 1000
        data.durability = 1000
    elseif material == "marble" and data.defense_tier == 1 then
        -- 大理石×3 → +90%防御，1600耐久
        data.defense_tier = 2
        data.defense_pct = 0.90
        data.max_durability = 1600
        data.durability = 1600
    elseif material == "steelwool" and data.defense_tier == 2 then
        -- 钢丝绵 → +3000耐久
        data.defense_tier = 3
        data.max_durability = data.max_durability + 3000
        data.durability = data.durability + 3000
    end

    update_hat_stats(inst)
end

-- ============================================
-- 修复（完整针线包 = +200耐久）
-- ============================================
local function repair_hat(inst, amount)
    local data = inst._hat_data
    amount = amount or 200
    if data.durability >= data.max_durability then return false end
    
    data.durability = math.min(data.max_durability, data.durability + amount)
    update_hat_stats(inst)
    return true
end

-- ============================================
-- 插槽路线（必须按顺序）
-- ============================================
local function open_slot(inst, material)
    local data = inst._hat_data
    
    if material == "fireflies" and not data.has_slot then
        -- 萤火虫 → 开启1个插槽
        data.has_slot = true
        data.slot_contents.illumination = true
        data.slot_contents.illumination_timer = 0
        return true
    elseif material == "enlightenment_shard" and data.has_slot and not data.is_eternal_light then
        -- 启迪碎片（前置：必须已加萤火虫）
        data.is_eternal_light = true
        data.sanity_bonus = data.sanity_bonus + 10  -- +10san值
        data.slot_contents = {}  -- 清空插槽，之后只能嵌天体珠宝
        return true
    end
    return false
end

-- ============================================
-- 无顺序要求的锻造
-- ============================================
local function upgrade_immunity(inst, material)
    local data = inst._hat_data

    if material == "dragon_scales" then
        data.fire_immunity = true
    elseif material == "bearger_fur" then
        data.freeze_immunity = data.freeze_immunity + 1
    elseif material == "shell_bell" then
        data.can_shell = true
    elseif material == "honeycomb" then
        data.anti_angry_bees = true
    elseif material == "horn" then
        data.anti_angry_beefalo = true
    elseif material == "rabbit_puff" then
        data.anti_bunnyman_meat = true
    elseif material == "pigskin" then
        data.windproof = true
    elseif material == "rainbow_gem" then
        data.has_rainbow_gem = true
    end
    
    update_hat_stats(inst)
end

-- ============================================
-- 保暖路线（必须按顺序）
-- ============================================
local function upgrade_warmth(inst, material)
    local data = inst._hat_data

    if material == "beefalowool" and data.warmth_tier == 0 then
        -- 牛毛×8 → +120保暖
        data.warmth_tier = 1
        data.warmth = 120
    elseif material == "beret" and data.warmth_tier == 1 then
        -- 贝雷帽 → +240保暖 +6.66san值
        data.warmth_tier = 2
        data.warmth = 240
        data.sanity_bonus = data.sanity_bonus + 6.66
    end
    
    update_hat_stats(inst)
end

-- ============================================
-- 防水路线（必须按顺序）
-- ============================================
local function upgrade_waterproof(inst, material)
    local data = inst._hat_data

    if material == "silk" and data.waterproof_tier == 0 then
        -- 蜘蛛丝×10 → +70%防水
        data.waterproof_tier = 1
        data.waterprooftness = 0.70
    elseif material == "barnacle" and data.waterproof_tier == 1 then
        -- 饼干切割机壳×10 → +100%防水
        data.waterproof_tier = 2
        data.waterprooftness = 1.0
    end
    
    update_hat_stats(inst)
end

-- ============================================
-- 隔热路线（必须按顺序）
-- ============================================
local function upgrade_insulation(inst, material)
    local data = inst._hat_data

    if material == "cactus_flesh" and data.insulation_tier == 0 then
        -- 多肉植物×8 → +120隔热
        data.insulation_tier = 1
        data.insulation = 120
    elseif material == "cactus_flower" and data.insulation_tier == 1 then
        -- 仙人掌花×10 → +240隔热
        data.insulation_tier = 2
        data.insulation = 240
    end
    
    update_hat_stats(inst)
end

-- ============================================
-- 彩虹宝石效果
-- ============================================
local function activate_rainbow_gem(inst)
    local data = inst._hat_data
    if not data.has_rainbow_gem or data.rainbow_cooldown > 0 then return false end

    data.rainbow_active = true
    data.rainbow_timer = 6
    data.durability = math.max(0, data.durability - 5)
    data.rainbow_cooldown = 5
    
    update_hat_stats(inst)
    return true
end

-- ============================================
-- 插槽照明tick
-- ============================================
local function update_slot_lighting(inst)
    local data = inst._hat_data
    if not data.has_slot then return end
    
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if not owner then return end
    
    if data.is_eternal_light then
        -- 启迪碎片：永亮
        if not inst._light then
            inst._light = owner.entity:AddLight()
            inst._light:SetIntensity(0.8)
            inst._light:SetRadius(5)
            inst._light:SetFalloff(0.5)
            inst._light:Enable(true)
        end
    elseif data.slot_contents.illumination and data.slot_contents.illumination_timer > 0 then
        -- 萤火虫插槽照明
        if not inst._light then
            inst._light = owner.entity:AddLight()
            inst._light:SetIntensity(0.5)
            inst._light:SetRadius(3)
            inst._light:SetFalloff(0.6)
            inst._light:Enable(true)
        end
        data.slot_contents.illumination_timer = data.slot_contents.illumination_timer - 1
        if data.slot_contents.illumination_timer <= 0 then
            data.slot_contents.illumination = false
            if inst._light then
                inst._light:Enable(false)
            end
        end
    end
end

-- ============================================
-- 定期tick
-- ============================================
local function tick_hat(inst)
    local data = inst._hat_data
    if not data then return end

    -- 彩虹宝石计时
    if data.rainbow_active then
        data.rainbow_timer = data.rainbow_timer - 1
        if data.rainbow_timer <= 0 then
            data.rainbow_active = false
        end
    end
    if data.rainbow_cooldown > 0 then
        data.rainbow_cooldown = data.rainbow_cooldown - 1
    end
    
    -- 更新照明
    update_slot_lighting(inst)
end

-- ============================================
-- 装备/卸下回调
-- ============================================
local function onequip(inst, owner)
    -- 防火
    if inst._hat_data.fire_immunity and owner.components.burnable then
        owner.components.burnable:SetImmuneFire(true)
    end
    
    -- 防冰冻
    if inst._hat_data.freeze_immunity > 0 then
        inst:AddTag("freezeprevent")
    end
    
    -- 照明
    update_slot_lighting(inst)
    
    -- 开启tick
    inst._tick_task = inst:DoPeriodicTask(1, function() tick_hat(inst) end)
end

local function onunequip(inst, owner)
    -- 移除防火
    if owner and owner.components.burnable then
        owner.components.burnable:SetImmuneFire(false)
    end
    
    -- 移除防冰冻
    if owner and owner.components.freezable then
        owner.components.freezable:AddColdResistance(-inst._hat_data.freeze_immunity)
    end
    
    -- 关闭照明
    if inst._light then
        inst._light:Enable(false)
        inst._light = nil
    end
    
    -- 关闭tick
    if inst._tick_task then
        inst._tick_task:Cancel()
        inst._tick_task = nil
    end
end

-- ============================================
-- 锻造炉交互
-- ============================================
local function forge_interaction(inst, doer, material)
    if not TheWorld.ismastersim then return end
    
    -- 防御路线
    upgrade_defense(inst, material)
    -- 免疫/特殊
    upgrade_immunity(inst, material)
    -- 插槽
    if open_slot(inst, material) then return true end
    -- 保暖
    upgrade_warmth(inst, material)
    -- 防水
    upgrade_waterproof(inst, material)
    -- 隔热
    upgrade_insulation(inst, material)
    -- 彩虹宝石
    activate_rainbow_gem(inst)
    
    return false
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

    inst.AnimState:SetBank("initial_hat")
    inst.AnimState:SetBuild("initial_hat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")
    inst:AddTag("show_spoilage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- 初始化数据
    init_hat_data(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/initial_hat.xml"
    inst.components.inventoryitem.imagename = "initial_hat"

    inst:AddComponent("inspectable")

    -- 装备组件
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- 防御组件（使用 Carney 写法）
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(INITIAL_DURABILITY, INITIAL_DEFENSE)

    -- 保暖/隔热
    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer(0)
    inst.components.insulator:SetWinter(0)

    -- 防水
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    -- 理智加成（使用 dapperness 组件）
    inst:AddComponent("dapperness")
    inst.components.dapperness.dapperness = INITIAL_SANITY_BONUS

    -- 锻造API
    inst.ForgeInteraction = forge_interaction
    inst.RepairHat = repair_hat

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("initial_hat", fn, assets, prefabs)