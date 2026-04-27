-- ============================================
-- 小木jian MOD (Littermu jian)
-- 作者: 117 | 版本: 1.0.0
-- 参考 Carney MOD 架构
-- ============================================

local _G = GLOBAL
local STRINGS = _G.STRINGS
local TUNING = _G.TUNING
local RECIPETABS = _G.RECIPETABS
local TECH = _G.TECH

-- ============================================
-- 预制件列表（相对于 scripts/ 目录）
-- ============================================
PrefabFiles = {
    "wooden_sword",
    "spirit_crystal",
    "boss_essence",
    "fused_protein",
    "wooden_arrow",
    "feather_kite",
    "initial_hat",
    "initial_kite",
    "wooden_sword_book",
    "forge",
}

-- ============================================
-- 字符串定义
-- ============================================
STRINGS.NAMES.WOODEN_SWORD = "小木剑"
STRINGS.NAMES.FORGE = "锻造炉"
STRINGS.NAMES.SPIRIT_CRYSTAL = "灵晶"
STRINGS.NAMES.BOSS_ESSENCE = "晶髓"
STRINGS.NAMES.FUSED_PROTEIN = "融合角质"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.WOODEN_SWORD = "一把可以升级的小木剑"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FORGE = "用于各种锻造的熔炉"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPIRIT_CRYSTAL = "蕴含灵气的水晶碎片"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOSS_ESSENCE = "Boss的精华"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FUSED_PROTEIN = "融合角质"

-- 新物品
STRINGS.NAMES.WOODEN_ARROW = "小木箭"
STRINGS.NAMES.FEATHER_KITE = "羽毛风筝"
STRINGS.NAMES.INITIAL_HAT = "精编草帽"
STRINGS.NAMES.INITIAL_KITE = "新手风筝"
STRINGS.NAMES.WOODEN_SWORD_BOOK = "小木剑手册"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.WOODEN_ARROW = "可发射的小木箭"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FEATHER_KITE = "收集羽毛可永久加速"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.INITIAL_HAT = "50%防御，可不断升级"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.INITIAL_KITE = "基础移速加成"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WOODEN_SWORD_BOOK = "介绍模组使用方法的书籍"

-- ============================================
-- 配置获取（参考 Carney MOD 写法）
-- ============================================
local function GetConfig(key, default)
    local val = GetModConfigData(key)
    if val == nil then
        return default
    end
    return val
end

-- 数值配置（直接获取，避免 nil 错误）
local CFG = {
    sword_base_damage = GetConfig("SwordBaseDamage") or 27.2,
    sword_base_durability = GetConfig("SwordBaseDurability") or 150,
    enable_forge = GetConfig("EnableForge") ~= false,
    enable_special_forge = GetConfig("EnableSpecialForge") ~= false,
    enable_drops = true,
    enable_debug_log = GetConfig("EnableDebugLog") == true,
    enable_test_recipes = GetConfig("EnableTestRecipes") == true,
}

-- TUNING 配置
TUNING.WOODEN_SWORD_BASE_DAMAGE = CFG.sword_base_damage
TUNING.WOODEN_SWORD_BASE_DURABILITY = CFG.sword_base_durability

-- ============================================
-- 调试日志
-- ============================================
local function Log(...)
    if CFG.enable_debug_log then
        print("[小木jian]", ...)
    end
end

-- ============================================
-- 配方注册（延迟到游戏脚本加载完成后执行）
-- ============================================
local function RegisterRecipes()
    -- 测试配方：免费制作
    if CFG.enable_test_recipes then
        AddRecipe("wooden_sword", {}, RECIPETABS.FIGHT, TECH.NONE,
            nil, nil, nil, nil, nil,
            "images/inventoryimages/wooden_sword.xml", "wooden_sword.tex"
        )
        AddRecipe("forge", {}, RECIPETABS.FIGHT, TECH.NONE,
            nil, nil, nil, nil, nil,
            "images/inventoryimages/forge.xml", "forge.tex"
        )
        AddRecipe("fused_protein", {}, RECIPETABS.FIGHT, TECH.NONE,
            nil, nil, nil, nil, nil,
            "images/inventoryimages/fused_protein.xml", "fused_protein.tex"
        )
        Log("测试配方已启用（免费制作）")
    else
        -- 正常配方
        AddRecipe("wooden_sword",
            { Ingredient("wood", 8), Ingredient("cutgrass", 6) },
            RECIPETABS.FIGHT, TECH.SCIENCE_ONE,
            nil, nil, nil, nil, nil,
            "images/inventoryimages/wooden_sword.xml", "wooden_sword.tex"
        )

        AddRecipe("forge",
            { Ingredient("dragon_scales", 1), Ingredient("goldnugget", 8),
              Ingredient("cutstone", 8), Ingredient("greengem", 2) },
            RECIPETABS.FIGHT, TECH.SCIENCE_TWO,
            nil, nil, nil, nil, nil,
            "images/inventoryimages/forge.xml", "forge.tex"
        )

        AddRecipe("fused_protein",
            { Ingredient("voltgoathorn", 1), Ingredient("tentaclespots", 1), Ingredient("narwhalhorn", 1) },
            RECIPETABS.FIGHT, TECH.SCIENCE_TWO,
            nil, nil, nil, nil, nil,
            "images/inventoryimages/fused_protein.xml", "fused_protein.tex"
        )
    end

    Log("配方注册完成")
end

AddSimPostInit(RegisterRecipes)

-- ============================================
-- 组件后初始化
-- ============================================

-- 武器组件：战斗升级
AddComponentPostInit("weapon", function(self)
    self.inst:ListenForEvent("onattackother", function(inst, data)
        if not inst.components.inventory then return end

        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if weapon and weapon:HasTag("wooden_sword") then
            local current_damage = weapon.components.weapon.damage
            weapon.components.weapon:SetDamage(current_damage + 0.08)

            if CFG.enable_debug_log then
                print("[小木jian] 攻击伤害:", weapon.components.weapon.damage)
            end

            if weapon.components.finiteuses then
                weapon.components.finiteuses:Use(1)
            end
        end
    end)
end)

-- ============================================
-- 预制件后初始化
-- ============================================
AddPrefabPostInit("world", function(inst)
    Log("世界初始化完成")
end)

AddPrefabPostInit("player", function(inst)
    inst:DoTaskInTime(0, function()
        Log("玩家", inst.prefab, "初始化完成")
    end)
end)

-- ============================================
-- 掉落系统
-- ============================================
if CFG.enable_drops then
    AddPrefabPostInit("spider", function(inst)
        inst:ListenForEvent("death", function(inst, data)
            if inst.components.lootdropper and math.random() < 0.3 then
                local loot = SpawnPrefab("spirit_crystal")
                if loot then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    loot.Transform:SetPosition(x, 0, z)
                end
            end
        end)
    end)

    AddPrefabPostInit("hound", function(inst)
        inst:ListenForEvent("death", function(inst, data)
            if inst.components.lootdropper and math.random() < 0.3 then
                local loot = SpawnPrefab("spirit_crystal")
                if loot then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    loot.Transform:SetPosition(x, 0, z)
                end
            end
        end)
    end)
end

-- ============================================
-- 材料升级动作处理
-- ============================================
local function CanUpgradeSword(inst, doer, target)
    if not (doer and doer.components.inventory) then return false end
    local sword = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if not (sword and sword:HasTag("wooden_sword")) then return false end
    if not target.components.stackable then return false end

    local material = target.prefab
    local valid_materials = { flint = true, rocks = true, goldnugget = true, marble = true }
    if not valid_materials[material] then return false end

    if sword.IsMaterialMaxed and sword:IsMaterialMaxed(material) then return false end

    return true
end

local function DoUpgradeSword(inst, doer, target)
    local sword = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if not sword then return false end

    local material = target.prefab
    local amount = target.components.stackable and target.components.stackable.stacksize or 1

    if sword.UpgradeMaterial then
        local consumed = sword:UpgradeMaterial(material, amount)
        if consumed > 0 then
            target.components.stackable:Get(consumed):Remove()
            if target.components.stackable.stacksize <= 0 then
                target:Remove()
            end
            return true
        end
    end
    return false
end

-- 添加动作组件到材料物品
AddPrefabPostInit("flint", function(inst)
    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = DoUpgradeSword
    inst.components.activatable.CanActivate = CanUpgradeSword
    inst.components.activatable.actiontype = "UPGRADE_SWORD"
end)

AddPrefabPostInit("rocks", function(inst)
    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = DoUpgradeSword
    inst.components.activatable.CanActivate = CanUpgradeSword
    inst.components.activatable.actiontype = "UPGRADE_SWORD"
end)

AddPrefabPostInit("goldnugget", function(inst)
    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = DoUpgradeSword
    inst.components.activatable.CanActivate = CanUpgradeSword
    inst.components.activatable.actiontype = "UPGRADE_SWORD"
end)

AddPrefabPostInit("marble", function(inst)
    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = DoUpgradeSword
    inst.components.activatable.CanActivate = CanUpgradeSword
    inst.components.activatable.actiontype = "UPGRADE_SWORD"
end)

-- ============================================
-- 初始化
-- ============================================
Log("MOD 加载完成！基础伤害:", CFG.sword_base_damage, "基础耐久:", CFG.sword_base_durability)

-- ============================================
-- 控制台调试命令
-- ============================================
_G.WS_Debug = {
    -- 生成小木剑
    GiveSword = function()
        local player = _G.ThePlayer
        if player then
            local sword = _G.SpawnPrefab("wooden_sword")
            if sword then
                player.components.inventory:GiveItem(sword)
                print("[小木剑调试] 已生成小木剑")
            end
        end
    end,
    -- 生成锻造炉
    GiveForge = function()
        local player = _G.ThePlayer
        if player then
            local forge = _G.SpawnPrefab("forge")
            if forge then
                player.components.inventory:GiveItem(forge)
                print("[小木剑调试] 已生成锻造炉")
            end
        end
    end,
    -- 查看当前武器伤害
    CheckDamage = function()
        local player = _G.ThePlayer
        if player and player.components.inventory then
            local weapon = player.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if weapon and weapon.components.weapon then
                print("[小木剑调试] 当前武器伤害:", weapon.components.weapon.damage)
            else
                print("[小木剑调试] 未装备武器")
            end
        end
    end,
    -- 重置伤害
    ResetDamage = function()
        local player = _G.ThePlayer
        if player and player.components.inventory then
            local weapon = player.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if weapon and weapon:HasTag("wooden_sword") then
                weapon.components.weapon:SetDamage(CFG.sword_base_damage)
                print("[小木剑调试] 伤害已重置为:", CFG.sword_base_damage)
            end
        end
    end,
    -- 材料升级
    Upgrade = function(material, amount)
        local player = _G.ThePlayer
        if player and player.components.inventory then
            local sword = player.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if sword and sword:HasTag("wooden_sword") and sword.UpgradeMaterial then
                local consumed = sword:UpgradeMaterial(material, amount or 20)
                print("[小木剑调试] 升级消耗:", consumed, material)
            end
        end
    end,
    -- 锻造宝石
    ForgeGem = function(gem_type)
        local player = _G.ThePlayer
        if player and player.components.inventory then
            local sword = player.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if sword and sword:HasTag("wooden_sword") and sword.ForgeGem then
                local success, err = sword:ForgeGem(gem_type)
                if success then
                    print("[小木剑调试] 锻造成功:", gem_type)
                else
                    print("[小木剑调试] 锻造失败:", err)
                end
            end
        end
    end,
    -- 选择阵营
    SetFaction = function(faction)
        local player = _G.ThePlayer
        if player and player.components.inventory then
            local sword = player.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if sword and sword:HasTag("wooden_sword") and sword.SetFaction then
                sword:SetFaction(faction)
                print("[小木剑调试] 阵营设置为:", faction)
            end
        end
    end,
    -- 查看升级信息
    Info = function()
        local player = _G.ThePlayer
        if player and player.components.inventory then
            local sword = player.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if sword and sword:HasTag("wooden_sword") then
                print("[小木剑调试] 升级信息:")
                if sword.GetUpgradeInfo then
                    print("  材料:", sword:GetUpgradeInfo())
                end
                print("  伤害:", sword.components.weapon.damage)
                print("  阵营:", sword.faction or "无")
                print("  宝石:", sword.forged_gems and next(sword.forged_gems) and "有" or "无")
            end
        end
    end,
}
