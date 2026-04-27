-- ============================================
-- Little Wooden Sword MOD - English Language
-- ============================================
local LANG = {}

LANG.NAMES = {
    wooden_sword = "Little Wooden Sword",
    forge = "Forge",
    wooden_arrow = "Wooden Arrow",
    spirit_crystal = "Spirit Crystal",
    boss_essence = "Boss Essence",
    initial_hat = "Craftsman's Hat",
    initial_kite = "Starter Kite",
    feather_kite = "Feather Kite",
    wooden_sword_book = "Wooden Sword Manual",
    arrow_core = "Arrow Core",
    fusion_protein = "Fusion Protein",
}

LANG.DESCRIPTIONS = {
    wooden_sword = "A wooden sword that can grow stronger",
    forge = "Workshop for forging upgrades",
    wooden_arrow = "Arrow shot by the Wooden Sword",
    spirit_crystal = "Spiritual crystal dropped from creatures",
    boss_essence = "Essence dropped from Bosses",
    initial_hat = "Forgeable hat, 50%% defense initially",
    initial_kite = "+10%% speed while held, 6 min durability",
    feather_kite = "Upgradeable with feathers, permanent flight",
    wooden_sword_book = "Wooden Sword Mod Manual",
    arrow_core = "Material for unlocking arrow function",
    fusion_protein = "Material for unlocking electric function",
}

LANG.RECIPE_DESC = {
    wooden_sword = "8 Wood + 6 Cut Grass",
    forge = "Scale + Gold×8 + Cutstone×8 + Green Gem×2",
    wooden_arrow = "4 Wood + 2 Flint + 2 Crow Feather",
    initial_hat = "2 Rope + 2 Papyrus",
    initial_kite = "4 Papyrus + 3 Twigs + 6 Silk",
    feather_kite = "Starter Kite + Red×10 + Blue×5 + Black×20 + Gold×2 + Goose×5 + Malbatross×5",
    wooden_sword_book = "10 Papyrus + 2 Feather Pen",
}

LANG.FORGE = {
    unlock_success = "Forge unlocked!",
    unlock_fail = "Cannot forge, need Gear×1 + Scrap×1",
    success = "Forge successful!",
    fail = "Forge failed, insufficient materials",
    no_target = "Place Wooden Sword or Starter Kite in the middle slot",
    invalid_target = "Only Wooden Sword or Starter Kite can be forged",
    missing_materials = "Insufficient materials",
    already_unlocked = "Forge already unlocked",
    faction_locked = "Faction already chosen, cannot change",
    lunar_faction = "Lunar faction chosen! Upgrade with Pure Brilliance",
    shadow_faction = "Shadow faction chosen! Upgrade with Pure Horror",
    arrow_unlock = "Arrow function unlocked! Right click to shoot",
    electric_unlock = "Electric function unlocked! Right click to dash",
    upgrade_speed = "Walrus Tusk forged! +25%% speed",
    upgrade_range = "Cat Tail forged! +1 attack range",
    upgrade_planar = "Static Energy forged! +10 planar damage",
    upgrade_lifesteal = "Bat Wing forged! 15%% chance to heal +6",
    upgrade_eye = "Eye forged! 50%% chance laser every 4 hits",
    upgrade_sand = "Sand Stone forged! 50%% chance sand spike every 4 hits",
    upgrade_red = "Red Gem forged! 33.3%% chance to ignite",
    upgrade_blue = "Blue Gem forged! 33.3%% chance to freeze",
    upgrade_purple = "Purple Gem forged! 50%% chance lightning ball",
    upgrade_yellow = "Yellow Gem forged! Laser damage ×1.5",
    upgrade_orange = "Orange Gem forged! Sand spike damage ×1.5",
    upgrade_green = "Green Gem forged! Lightning ball count ×2",
}

LANG.KITE = {
    activate = "Standing on Feather Kite, ready to fly!",
    deactivate = "Feather Kite energy depleted!",
    need_feathers = "Feather Kite needs more feathers!",
    permanent = "Feather Kite has permanent energy!",
}

LANG.HAT = {
    upgrade_defense = "Defense increased!",
    upgrade_slot = "Slot unlocked!",
    upgrade_warmth = "Warmth increased!",
    upgrade_waterproof = "Waterproof increased!",
    upgrade_insulation = "Insulation increased!",
    upgrade_immune = "Special immunity gained!",
    rainbow_activate = "Rainbow Gem activated!",
}

LANG.MISC = {
    mod_loaded = "Littermu jian MOD Loaded!",
    module_disabled = "Module disabled: ",
    error_occurred = "Error occurred: ",
}

return LANG
