-- ============================================
-- 小木jian MOD - 特殊锻造系统
-- 处理各种宝石和材料的升级效果
-- ============================================




local ForgeUtils = require("components/forge_utils")
local Modules = require("modules/init")
local ModuleManager = Modules.ModuleManager

-- ============================================
-- 特殊锻造配方（v5文档更新）
-- ============================================
local SpecialForgeRecipes = {
    -- ==================== 特殊能力 ====================
    -- +25%移速
    {
        materials = { walrustusk = 1, spirit_crystal = 10 },
        effect = "upgrade_speed",
        flag = "speed_bonus",
        value = 0.25,
    },

    -- +1攻击距离（猫尾：coontail）
    {
        materials = { coontail = 1, spirit_crystal = 10 },
        effect = "upgrade_range",
        flag = "range_bonus",
        value = 1,
    },

    -- +10位面伤害
    {
        materials = { thulecite = 1 },
        effect = "upgrade_planar",
        flag = "planar_bonus",
        value = 10,
    },

    -- 吸血（15%概率+6）
    {
        materials = { batwing = 1, spirit_crystal = 10 },
        effect = "upgrade_lifesteal",
        flag = "lifesteal_chance",
        value = 0.15,
        extra = { lifesteal_amount = 6 },
    },

    -- ==================== 宝石锻造 ====================
    -- 红宝石：33.3%点燃
    {
        materials = { redgem = 2, nitre = 10, spirit_crystal = 10 },
        effect = "upgrade_red",
        flag = "has_red_gem",
        value = true,
    },

    -- 蓝宝石：33.3%冰冻
    {
        materials = { bluegem = 2, ice = 20, spirit_crystal = 10 },
        effect = "upgrade_blue",
        flag = "has_blue_gem",
        value = true,
    },

    -- 紫宝石：50%闪电光球
    {
        materials = { purplegem = 2, transistor = 2, spirit_crystal = 10 },
        effect = "upgrade_purple",
        flag = "has_purple_gem",
        value = true,
    },

    -- ==================== 宝石强化（需前置） ====================
    -- 激光伤害×1.5（需已锻造眼球）
    {
        materials = { yellowgem = 1, boss_essence = 1 },
        effect = "upgrade_yellow",
        flag = "laser_mult",
        value = 1.5,
        requires = "has_eye",
    },

    -- 沙刺伤害×1.5（需已锻造沙之石）
    {
        materials = { orangegem = 1, boss_essence = 1 },
        effect = "upgrade_orange",
        flag = "sand_mult",
        value = 1.5,
        requires = "has_sand",
    },

    -- 闪电光球数量×2（需已锻造紫宝石）
    {
        materials = { greengem = 1, boss_essence = 1 },
        effect = "upgrade_green",
        flag = "lightning_mult",
        value = 2,
        requires = "has_purple_gem",
    },

    -- ==================== 眼球与沙之石 ====================
    -- 眼球激光（100伤害+6范围80溅射）
    {
        materials = { eyeball_turkey = 1, boss_essence = 1 },
        effect = "upgrade_eye",
        flag = "has_eye",
        value = true,
    },

    -- 沙刺（沙之石：antliontrinket）
    {
        materials = { antliontrinket = 5, boss_essence = 1 },
        effect = "upgrade_sand",
        flag = "has_sand",
        value = true,
    },

    -- ==================== 阵营选择 ====================
    -- 月亮阵营
    {
        materials = { moonrock = 5, moonshards = 10, boss_essence = 1 },
        effect = "faction_moon",
        flag = "faction",
        value = "moon",
    },

    -- 暗影阵营
    {
        materials = { nightmare = 10, thulecite = 3, boss_essence = 1 },
        effect = "faction_shadow",
        flag = "faction",
        value = "shadow",
    },

    -- ==================== 箭矢功能解锁 ====================
    -- 解锁小木箭
    {
        materials = { wooden_arrow = 1, goose_feather = 1, living_logs = 5, boss_essence = 1 },
        effect = "upgrade_arrow",
        flag = "has_arrow",
        value = true,
    },

    -- ==================== 潮湿电击解锁 ====================
    -- 解锁潮湿电击功能（烂电线：trinket_6）
    {
        materials = { fused_protein = 1, transistor = 1, trinket_6 = 2, boss_essence = 1 },
        effect = "upgrade_electric",
        flag = "has_electric",
        value = true,
    },
}

-- ============================================
-- 检查并执行特殊锻造
-- ============================================
local function TrySpecialForge(inst, doer, sword)
    if not ModuleManager.GetConfigValue("enable_special_forge") then
        return false
    end

    local container = inst.components.container
    if not container then return false end

    -- 检查所有配方
    for _, recipe in ipairs(SpecialForgeRecipes) do
        -- 检查前置条件
        if recipe.requires and not sword[recipe.requires] then
            goto continue
        end

        if ForgeUtils.HasAllMaterials(container, recipe.materials) then
            -- 消耗材料
            ForgeUtils.ConsumeMaterials(container, recipe.materials)

            -- 应用效果
            ForgeUtils.ApplyWeaponBonus(sword, recipe.flag, recipe.value, recipe.extra)

            -- 触发阵营升级检测（如果有阵营）
            if recipe.flag == "faction" then
                sword:check_state_upgrade()
            end

            ForgeUtils.Notify(doer, recipe.effect)
            return true
        end

        ::continue::
    end

    return false
end

-- ============================================
-- 导出
-- ============================================
return {
    TrySpecialForge = TrySpecialForge,
}
