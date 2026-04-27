-- ============================================
-- 小木jian MOD (Littermu jian)
-- 作者: 117
-- 版本: 1.0.0
-- ============================================

name = "小木剑"
description = [[
一把可以不断升级的小木剑，从简陋的木剑一路成长为强大的阵营武器！
- 小木剑：8木6草制作，可材料升级+战斗升级+锻造升级
- 锻造炉：鳞片+金块+石砖+绿宝石制作，用于各种锻造
- 羽毛风筝：莎草纸+树枝+蜘蛛丝制作，可飞行加速
- 帽子：绳子+莎草纸制作，可叠加多种防御/保暖/防水/隔热/插槽效果
- 灵晶/晶髓：从各种生物掉落，用于锻造材料

不卖精灵不抽卡，打怪掉落全靠肝！
]]
author = "117"
version = "1.0.0"
forumthread = ""
api_version = 10

dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod = true
clients_only = false
server_only_tags = {}

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

server_filter_tags = {}

-- ============================================
-- 配置选项（模块化开关）
-- ============================================
configuration_options = {
    -- 语言选择
    {
        name = "Language",
        label = "语言 / Language",
        options = {
            {description = "中文", data = "chs"},
            {description = "English", data = "eng"},
        },
        default = "chs",
    },

    -- ========== 锻造系统模块 ==========
    {
        name = "EnableForge",
        label = "启用锻造炉 / Enable Forge",
        options = {{description = "启用", data = true}, {description = "禁用", data = false}},
        default = true,
    },
    {
        name = "EnableSpecialForge",
        label = "启用特殊锻造（宝石/眼球等）/ Enable Special Forge",
        options = {{description = "启用", data = true}, {description = "禁用", data = false}},
        default = true,
    },

    -- ========== 阵营系统模块 ==========
    {
        name = "EnableFaction",
        label = "启用阵营系统 / Enable Faction System",
        options = {{description = "启用", data = true}, {description = "禁用", data = false}},
        default = true,
    },

    -- ========== 风筝系统模块 ==========
    {
        name = "EnableKite",
        label = "启用风筝系统 / Enable Kite System",
        options = {{description = "启用", data = true}, {description = "禁用", data = false}},
        default = true,
    },

    -- ========== 帽子系统模块 ==========
    {
        name = "EnableHat",
        label = "启用帽子系统 / Enable Hat System",
        options = {{description = "启用", data = true}, {description = "禁用", data = false}},
        default = true,
    },

    -- ========== 数值配置 ==========
    {
        name = "SwordBaseDamage",
        label = "木剑基础伤害 / Sword Base Damage",
        options = {
            {description = "27.2 (标准)", data = 27.2},
            {description = "34 (较高)", data = 34},
            {description = "40 (高)", data = 40},
        },
        default = 27.2,
    },
    {
        name = "SwordBaseDurability",
        label = "木剑基础耐久 / Sword Base Durability",
        options = {
            {description = "150 (标准)", data = 150},
            {description = "200 (较高)", data = 200},
            {description = "250 (高)", data = 250},
        },
        default = 150,
    },

    -- ========== 调试选项 ==========
    {
        name = "EnableDebugLog",
        label = "启用调试日志 / Enable Debug Log",
        options = {{description = "启用", data = true}, {description = "禁用", data = false}},
        default = true,
    },

    -- ========== 测试选项 ==========
    {
        name = "EnableTestRecipes",
        label = "启用测试配方（免费制作）/ Enable Test Recipes",
        options = {{description = "启用", data = true}, {description = "禁用", data = false}},
        default = false,
    },
}
