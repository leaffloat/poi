# 技术设计文档 — 小木剑模组

## 1. 架构设计

```
wooden_sword/
├── src/main/java/com/mod/woodensword/
│   ├── WoodenSwordMod.java          # 模组入口
│   ├── item/
│   │   └── ModItems.java            # 物品注册
│   └── config/
│       └── ModConfig.java           # 配置项
├── src/main/resources/
│   ├── assets/woodensword/
│   │   ├── textures/item/
│   │   │   └── wooden_sword.png
│   │   └── models/item/
│   │       └── wooden_sword.json
│   ├── data/woodensword/recipes/
│   │   └── wooden_sword.json
│   └── pack.mcmeta
├── README.md
└── TECHNICAL.md (本文件)
```

## 2. 核心参数

```java
// 物品属性定义
public static final ToolMaterial WOODEN_SWORD_TIER = new ToolMaterial() {
    @Override public int getDurability() { return 60; }
    @Override public float getMiningSpeedMultiplier() { return 1.0F; }
    @Override public float getAttackDamage() { return 3.0F; }  // 基础伤害
    @Override public int getEnchantability() { return 15; }
    @Override public int getMiningLevel() { return 0; }
};
```

## 3. 配置项（可选）

```toml
# wooden_sword.toml
[general]
# 是否启用小木剑
enabled = true
# 基础攻击力覆盖（0 = 使用默认值）
override_attack_damage = 0.0
# 耐久度覆盖（0 = 使用默认值）
override_durability = 0
```

## 4. 兼容性

| 模组加载器 | 支持版本 |
|-----------|---------|
| Forge     | 1.16.5+ |
| Fabric    | 1.16.5+ |
| NeoForge  | 1.20.1+ |

## 5. 注意事项

- 木剑类物品的攻击伤害在 1.16+ 版本中由 `attack_damage` 属性控制
- 贴图文件建议使用 16×16 或 32×32 像素
- 如需添加自定义附魔，需额外注册 Enchantment 对象
