-- scripts/components/wooden_sword_data.lua
-- 小木剑数据管理组件
-- 替代直接在 prefab 中存储，便于网络同步和存档

local WoodenSwordData = Class(function(self, inst)
    self.inst = inst

    -- 基础状态
    self.is_forged = false              -- 是否已触发锻造炉状态
    self.base_damage = 27.2
    self.durability = 150
    self.max_durability = 150

    -- 打怪升级
    self.hit_damage_bonus = 0           -- 累计伤害加成
    self.hit_count = 0                  -- 总命中次数
    self.max_hit_bonus = 72.8

    -- 材料升级
    self.upgrades = {
        flint = { count = 0, damage = 0 },
        rocks = { count = 0, damage = 0 },
        goldnugget = { count = 0, damage = 0 },
        marble = { count = 0, damage = 0 },
    }
    self.total_material_bonus = 0

    -- 宝石
    self.gems = {}                      -- {red_gem=true, ...}
    self.gem_order = []                 -- 锻造顺序
    self.has_red_gem = false
    self.has_blue_gem = false
    self.has_purple_gem = false
    self.has_yellow_gem = false
    self.has_orange_gem = false
    self.has_green_gem = false
    self.freeze_cooldown = 0

    -- 阵营
    self.faction = nil                  -- "moon" / "shadow"
    self.faction_locked = false
    self.is_post_boss = false
    self.post_boss_type = nil           -- "moon_post" / "shadow_post"

    -- 特殊锻造
    self.has_speed = false              -- 海象牙
    self.has_cat_tail = false           -- 猫尾
    self.has_planar_dmg = false         -- 约束静电
    self.has_bat_wing = false           -- 蝙蝠翅膀
    self.has_charge_attack = false      -- 冲刺攻击
    self.has_arrow_mode = false         -- 小木箭
    self.has_eyeball = false            -- 眼球
    self.has_sand_stone = false         -- 沙之石
    self.attack_counter = 0             -- 攻击计数（眼球/沙之石触发）

    -- 当前计算值（缓存）
    self.current_damage = 27.2
    self.current_planar_damage = 0
    self.current_range = 1.0
end)

-- ===== 计算总伤害 =====
function WoodenSwordData:RecalcDamage()
    local dmg = self.base_damage
    dmg = dmg + self.hit_damage_bonus
    dmg = dmg + self.total_material_bonus
    self.current_damage = math.floor(dmg * 100 + 0.5) / 100
    return self.current_damage
end

-- ===== 获取对特定目标的伤害（含阵营加成）=====
function WoodenSwordData:GetDamageVs(target)
    local dmg = self.current_damage
    if self.faction and target then
        if self.faction == "moon" and target:HasTag("shadow") then
            dmg = dmg * 1.1
        elseif self.faction == "shadow" and target:HasTag("moon") then
            dmg = dmg * 1.1
        end
    end
    -- 月后/影后加成
    if self.is_post_boss then
        if self.post_boss_type == "moon_post" and target:HasTag("shadow") then
            dmg = dmg * 2.0
        elseif self.post_boss_type == "shadow_post" and target:HasTag("moon") then
            dmg = dmg * 1.75
        end
    end
    return math.floor(dmg * 100 + 0.5) / 100
end

-- ===== 位面伤害 =====
function WoodenSwordData:GetPlanarDamage()
    local pdmg = 0
    if self.has_planar_dmg then pdmg = pdmg + 10 end
    if self.is_post_boss then
        if self.post_boss_type == "moon_post" then pdmg = pdmg + 30 end
        if self.post_boss_type == "shadow_post" then pdmg = pdmg + 22 end
    end
    return pdmg
end

-- ===== 攻击距离 =====
function WoodenSwordData:GetRange()
    local r = 1.0
    if self.has_cat_tail then r = r + 1 end
    return r
end

-- ===== 移速加成 =====
function WoodenSwordData:GetSpeedBonus()
    if self.has_speed then return 0.25 end
    return 0
end

-- ===== 材料升级 =====
function WoodenSwordData:UpgradeMaterial(material_type, amount)
    local upgrade_configs = {
        flint   = { per = 20, dmg = 0.25, max = 6  },
        rocks   = { per = 20, dmg = 0.25, max = 6  },
        goldnugget = { per = 20, dmg = 1.0,  max = 6  },
        marble  = { per = 20, dmg = 2.0,  max = 4  },
    }

    local cfg = upgrade_configs[material_type]
    if not cfg then return 0 end

    local up = self.upgrades[material_type]
    local remaining = cfg.max - up.count
    if remaining <= 0 then return 0 end

    local can_upgrade = math.min(math.floor(amount / cfg.per), remaining)
    if can_upgrade <= 0 then return 0 end

    local consumed = can_upgrade * cfg.per
    local dmg_gain = can_upgrade * cfg.dmg

    up.count = up.count + can_upgrade
    up.damage = up.damage + dmg_gain
    self.total_material_bonus = self.total_material_bonus + dmg_gain

    self:RecalcDamage()
    return consumed
end

-- ===== 检查所有材料是否已满 =====
function WoodenSwordData:AllMaterialsMaxed()
    for key, up in pairs(self.upgrades) do
        local max_count = 0
        if key == "marble" then max_count = 4 else max_count = 6 end
        if up.count < max_count then return false end
    end
    return true
end

-- ===== 触发锻造状态 =====
function WoodenSwordData:TriggerForgeState()
    if self.is_forged then return end
    self.is_forged = true
    self.max_durability = 600
    self.durability = 600
end

-- ===== 使用耐久 =====
function WoodenSwordData:UseDurability(amount)
    amount = amount or 1
    self.durability = math.max(0, self.durability - amount)

    if self.durability <= 0 then
        if self.is_forged then
            self.current_damage = 27.2
        else
            self.current_damage = 0
        end
    end
end

-- ===== 宝石锻造 =====
function WoodenSwordData:ForgeGem(gem_type)
    if self.gems[gem_type] then return false, "already_forged" end

    -- 前置检查
    if gem_type == "yellow_gem" and not self.has_eyeball then
        return false, "requires_eyeball"
    end
    if gem_type == "orange_gem" and not self.has_sand_stone then
        return false, "requires_sand_stone"
    end
    if gem_type == "green_gem" and not self.has_purple_gem then
        return false, "requires_purple_gem"
    end

    self.gems[gem_type] = true
    table.insert(self.gem_order, gem_type)

    if gem_type == "red_gem" then self.has_red_gem = true end
    if gem_type == "blue_gem" then self.has_blue_gem = true end
    if gem_type == "purple_gem" then self.has_purple_gem = true end
    if gem_type == "yellow_gem" then self.has_yellow_gem = true end
    if gem_type == "orange_gem" then self.has_orange_gem = true end
    if gem_type == "green_gem" then self.has_green_gem = true end

    return true
end

-- ===== 选择阵营 =====
function WoodenSwordData:ChooseFaction(faction)
    if self.faction_locked then return false end
    self.faction = faction
    self.faction_locked = true
    return true
end

-- ===== 序列化（存档）=====
function WoodenSwordData:OnSave()
    return {
        is_forged = self.is_forged,
        base_damage = self.base_damage,
        durability = self.durability,
        max_durability = self.max_durability,
        hit_damage_bonus = self.hit_damage_bonus,
        hit_count = self.hit_count,
        upgrades = self.upgrades,
        total_material_bonus = self.total_material_bonus,
        gems = self.gems,
        gem_order = self.gem_order,
        faction = self.faction,
        faction_locked = self.faction_locked,
        is_post_boss = self.is_post_boss,
        post_boss_type = self.post_boss_type,
        has_speed = self.has_speed,
        has_cat_tail = self.has_cat_tail,
        has_planar_dmg = self.has_planar_dmg,
        has_bat_wing = self.has_bat_wing,
        has_charge_attack = self.has_charge_attack,
        has_arrow_mode = self.has_arrow_mode,
        has_eyeball = self.has_eyeball,
        has_sand_stone = self.has_sand_stone,
        current_damage = self.current_damage,
    }
end

-- ===== 反序列化（读档）=====
function WoodenSwordData:OnLoad(data)
    if not data then return end
    for k, v in pairs(data) do
        self[k] = v
    end
end

return WoodenSwordData
