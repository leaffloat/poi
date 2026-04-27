-- ============================================
-- 小木jian MOD - 中文语言包
-- ============================================
local LANG = {}

-- ========== 物品名称 ==========
LANG.NAMES = {
    wooden_sword = "小木剑",
    forge = "锻造炉",
    wooden_arrow = "小木箭",
    spirit_crystal = "灵晶",
    boss_essence = "晶髓",
    initial_hat = "匠人之帽",
    initial_kite = "初始风筝",
    feather_kite = "羽毛风筝",
    wooden_sword_book = "木剑宝典",
    arrow_core = "箭矢核心",
    fused_protein = "融合角质",
}

-- ========== 物品描述 ==========
LANG.DESCRIPTIONS = {
    wooden_sword = "一把可以不断成长的小木剑",
    forge = "用于锻造升级的工坊",
    wooden_arrow = "小木剑发射的箭矢",
    spirit_crystal = "从生物身上掉落的灵性结晶",
    boss_essence = "从Boss身上掉落的精华",
    initial_hat = "可锻造升级的帽子，初始50%防御",
    initial_kite = "手持加速10%，耐久6分钟",
    feather_kite = "可收集羽毛升级，永久凌空飞行",
    wooden_sword_book = "小木剑模组使用说明书",
    arrow_core = "用于解锁小木箭功能的材料",
    fused_protein = "用于解锁潮湿电击功能的材料",
}

-- ========== 配方描述 ==========
LANG.RECIPE_DESC = {
    wooden_sword = "8木头 + 6草",
    forge = "鳞片 + 金块×8 + 石砖×8 + 绿宝石×2",
    wooden_arrow = "4木头 + 2燧石 + 2乌鸦羽毛",
    initial_hat = "2绳子 + 2莎草纸",
    initial_kite = "4莎草纸 + 3树枝 + 6蜘蛛丝",
    feather_kite = "初始风筝 + 红羽×10 + 蓝羽×5 + 黑羽×20 + 黄羽×2 + 鹅羽×5 + 翁羽×5",
    wooden_sword_book = "10莎草纸 + 2羽毛笔",
}

-- ========== 锻造提示 ==========
LANG.FORGE = {
    unlock_success = "锻造炉功能已解锁！",
    unlock_fail = "无法锻造，需要齿轮×1 + 废料×1",
    success = "锻造成功！",
    fail = "锻造失败，材料不足",
    no_target = "请将小木剑或初始风筝放入中间槽位",
    invalid_target = "只能锻造小木剑或初始风筝",
    missing_materials = "材料不足",
    already_unlocked = "锻造炉已解锁",
    faction_locked = "阵营已选定，无法更改",
    lunar_faction = "月亮阵营已选定！后续可用纯粹辉煌升级",
    shadow_faction = "暗影阵营已选定！后续可用纯粹恐惧升级",
    arrow_unlock = "小木箭功能解锁！右键可发射箭矢",
    electric_unlock = "潮湿电击功能解锁！右键可冲刺攻击",
    upgrade_speed = "海象牙锻造成功！+25%%移速",
    upgrade_range = "猫尾锻造成功！+1攻击距离",
    upgrade_planar = "约束静电锻造成功！+10位面伤害",
    upgrade_lifesteal = "蝙蝠翅膀锻造成功！15%%概率吸血+6",
    upgrade_eye = "眼球锻造成功！每4下50%%概率激光100伤害",
    upgrade_sand = "沙之石锻造成功！每4下50%%概率沙刺伤害",
    upgrade_red = "红宝石锻造成功！33.3%%概率点燃",
    upgrade_blue = "蓝宝石锻造成功！33.3%%概率冰冻",
    upgrade_purple = "紫宝石锻造成功！50%%概率闪电光球",
    upgrade_yellow = "黄宝石锻造成功！激光伤害×1.5",
    upgrade_orange = "橙宝石锻造成功！沙刺伤害×1.5",
    upgrade_green = "绿宝石锻造成功！闪电光球数量×2",
    upgrade_electric = "潮湿电击已解锁！攻击潮湿目标时造成额外电击伤害",
}

-- ========== 风筝提示 ==========
LANG.KITE = {
    activate = "站在羽毛风筝上，准备起飞！",
    deactivate = "羽毛风筝能量耗尽了！",
    need_feathers = "羽毛风筝能量不足，需要添加更多羽毛！",
    permanent = "羽毛风筝已获得永久能量！",
}

-- ========== 帽子提示 ==========
LANG.HAT = {
    upgrade_defense = "防御力提升！",
    upgrade_slot = "插槽已开启！",
    upgrade_warmth = "保暖能力提升！",
    upgrade_waterproof = "防水能力提升！",
    upgrade_insulation = "隔热能力提升！",
    upgrade_immune = "获得特殊免疫！",
    rainbow_activate = "彩虹宝石激活！",
}

-- ========== 其他 ==========
LANG.MISC = {
    mod_loaded = "小木jian MOD 加载完成！",
    forge_upgrade = "锻造成功！",
    forge_fail = "锻造失败，材料不足或顺序错误",
    module_disabled = "模块已禁用: ",
    error_occurred = "发生错误: ",
}

return LANG
