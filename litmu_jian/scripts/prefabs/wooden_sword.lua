-- ============================================
-- 小木剑预制件（参考 Carney MOD 写法）
-- ============================================
local assets = {
    Asset("ANIM", "anim/wooden_sword.zip"),
    Asset("ANIM", "anim/swap_wooden_sword.zip"),
    Asset("ATLAS", "images/inventoryimages/wooden_sword.xml"),
    Asset("IMAGE", "images/inventoryimages/wooden_sword.tex"),
}

-- 材料升级配置
local UPGRADE_CONFIGS = {
    flint = { per = 20, dmg = 0.25, max = 6 },
    rocks = { per = 20, dmg = 0.25, max = 6 },
    goldnugget = { per = 20, dmg = 1.0, max = 6 },
    marble = { per = 20, dmg = 2.0, max = 4 },
}

-- 宝石配置
local GEM_EFFECTS = {
    red_gem = { type = "fire", dmg_bonus = 5 },
    blue_gem = { type = "ice", dmg_bonus = 5 },
    purple_gem = { type = "shadow", dmg_bonus = 10 },
    yellow_gem = { type = "light", dmg_bonus = 5 },
    orange_gem = { type = "speed", dmg_bonus = 5 },
    green_gem = { type = "poison", dmg_bonus = 10 },
}

-- 装备回调：手持动画
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_wooden_sword", "swap_wooden_sword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

-- 卸下回调
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

-- 攻击回调
local function onattack(inst, attacker, target)
    if attacker and attacker.SoundEmitter then
        attacker.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
    end
end

-- 材料升级函数
local function UpgradeMaterial(inst, material_type, amount)
    if not inst.upgrades then
        inst.upgrades = { flint = 0, rocks = 0, goldnugget = 0, marble = 0 }
        inst.material_bonus = 0
    end

    local cfg = UPGRADE_CONFIGS[material_type]
    if not cfg then return 0 end

    local current = inst.upgrades[material_type] or 0
    local remaining = cfg.max - current
    if remaining <= 0 then return 0 end

    local can_upgrade = math.min(math.floor(amount / cfg.per), remaining)
    if can_upgrade <= 0 then return 0 end

    local consumed = can_upgrade * cfg.per
    local dmg_gain = can_upgrade * cfg.dmg

    inst.upgrades[material_type] = current + can_upgrade
    inst.material_bonus = (inst.material_bonus or 0) + dmg_gain

    -- 更新武器伤害
    local base_dmg = TUNING.WOODEN_SWORD_BASE_DAMAGE or 27.2
    local new_dmg = base_dmg + (inst.hit_bonus or 0) + inst.material_bonus
    inst.components.weapon:SetDamage(new_dmg)

    -- 播放特效
    if inst.SoundEmitter then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/put_down_generic")
    end

    print(string.format("[小木剑] 材料升级: %s x%d, 伤害+%.2f, 当前伤害:%.2f",
        material_type, can_upgrade, dmg_gain, new_dmg))

    return consumed
end

-- 检查材料是否已满
local function IsMaterialMaxed(inst, material_type)
    if not inst.upgrades then return false end
    local cfg = UPGRADE_CONFIGS[material_type]
    if not cfg then return true end
    return (inst.upgrades[material_type] or 0) >= cfg.max
end

-- 获取升级信息
local function GetUpgradeInfo(inst)
    if not inst.upgrades then
        return "未升级"
    end
    local info = {}
    for mat, cfg in pairs(UPGRADE_CONFIGS) do
        local count = inst.upgrades[mat] or 0
        table.insert(info, string.format("%s:%d/%d", mat, count, cfg.max))
    end
    return table.concat(info, ", ")
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wooden_sword")
    inst.AnimState:SetBuild("wooden_sword")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("wooden_sword")
    inst:AddTag("sharp")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- 升级数据初始化
    inst.upgrades = { flint = 0, rocks = 0, goldnugget = 0, marble = 0 }
    inst.material_bonus = 0
    inst.hit_bonus = 0

    -- 库存组件
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wooden_sword"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wooden_sword.xml"

    -- 武器组件
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.WOODEN_SWORD_BASE_DAMAGE or 27.2)
    inst.components.weapon:SetOnAttack(onattack)

    -- 耐久组件
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.WOODEN_SWORD_BASE_DURABILITY or 150)
    inst.components.finiteuses:SetUses(TUNING.WOODEN_SWORD_BASE_DURABILITY or 150)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    -- 可堆叠（不堆叠）
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 1

    -- 可检查 - 显示升级信息
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        return GetUpgradeInfo(inst)
    end

    -- 装备组件
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- 宝石系统
    inst.forged_gems = {}
    inst.gem_bonus = 0

    -- 锻造宝石
    inst.ForgeGem = function(inst, gem_type)
        if inst.forged_gems[gem_type] then return false, "already_forged" end

        -- 前置检查
        if gem_type == "yellow_gem" and not inst.has_eyeball then
            return false, "requires_eyeball"
        end
        if gem_type == "orange_gem" and not inst.has_sand_stone then
            return false, "requires_sand_stone"
        end
        if gem_type == "green_gem" and not inst.forged_gems["purple_gem"] then
            return false, "requires_purple_gem"
        end

        inst.forged_gems[gem_type] = true
        local effect = GEM_EFFECTS[gem_type]
        if effect then
            inst.gem_bonus = inst.gem_bonus + effect.dmg_bonus
            -- 更新伤害
            local base_dmg = TUNING.WOODEN_SWORD_BASE_DAMAGE or 27.2
            inst.components.weapon:SetDamage(base_dmg + (inst.hit_bonus or 0) +
                (inst.material_bonus or 0) + inst.gem_bonus)
        end

        -- 特殊效果标记
        if gem_type == "red_gem" then inst.has_fire = true end
        if gem_type == "blue_gem" then inst.has_ice = true end
        if gem_type == "purple_gem" then inst.has_shadow = true end
        if gem_type == "yellow_gem" then inst.has_light = true end
        if gem_type == "orange_gem" then inst.has_speed_attack = true end
        if gem_type == "green_gem" then inst.has_poison = true end

        print(string.format("[小木剑] 锻造宝石: %s, 伤害+%d", gem_type, effect and effect.dmg_bonus or 0))
        return true
    end

    -- 阵营系统
    inst.faction = nil
    inst.faction_locked = false

    inst.SetFaction = function(inst, faction)
        if inst.faction_locked then return false end
        inst.faction = faction
        inst.faction_locked = true
        print("[小木剑] 选择阵营:", faction)
        return true
    end

    -- 添加材料升级接口
    inst.UpgradeMaterial = UpgradeMaterial
    inst.IsMaterialMaxed = IsMaterialMaxed
    inst.GetUpgradeInfo = GetUpgradeInfo

    -- 存档支持
    inst.OnSave = function(inst, data)
        data.upgrades = inst.upgrades
        data.material_bonus = inst.material_bonus
        data.hit_bonus = inst.hit_bonus
        data.forged_gems = inst.forged_gems
        data.gem_bonus = inst.gem_bonus
        data.faction = inst.faction
        data.faction_locked = inst.faction_locked
        data.has_fire = inst.has_fire
        data.has_ice = inst.has_ice
        data.has_shadow = inst.has_shadow
        data.has_light = inst.has_light
        data.has_speed_attack = inst.has_speed_attack
        data.has_poison = inst.has_poison
    end

    inst.OnLoad = function(inst, data)
        if data then
            inst.upgrades = data.upgrades or { flint = 0, rocks = 0, goldnugget = 0, marble = 0 }
            inst.material_bonus = data.material_bonus or 0
            inst.hit_bonus = data.hit_bonus or 0
            inst.forged_gems = data.forged_gems or {}
            inst.gem_bonus = data.gem_bonus or 0
            inst.faction = data.faction
            inst.faction_locked = data.faction_locked
            inst.has_fire = data.has_fire
            inst.has_ice = data.has_ice
            inst.has_shadow = data.has_shadow
            inst.has_light = data.has_light
            inst.has_speed_attack = data.has_speed_attack
            inst.has_poison = data.has_poison
            -- 重新计算伤害
            local base_dmg = TUNING.WOODEN_SWORD_BASE_DAMAGE or 27.2
            inst.components.weapon:SetDamage(base_dmg + inst.hit_bonus +
                inst.material_bonus + inst.gem_bonus)
        end
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wooden_sword", fn, assets)
