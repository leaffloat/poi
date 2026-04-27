# 小木剑模组 (Wooden Sword Mod)

## 概述

为饥荒联机版（DST）添加增强版小木剑，早期过渡的理想武器。

---

## 物品属性

| 属性 | 数值 |
|------|------|
| 攻击力 | 45 |
| 攻击范围 | 1.2 |
| 耐久度 | 60 次使用 |
| 附魔能力 | 兼容 DST 武器系统 |

## 合成配方

```
[木板/原木] × 1
[树枝] × 1
─────────────
  小木剑 × 1
```

- 无需科技解锁，初始即可合成

---

## 📁 模组结构

```
wooden_sword/
├── modinfo.lua                    ← 模组信息
├── modmain.lua                    ← 入口文件（注册物品+配方）
├── scripts/
│   └── prefabs/
│       └── wooden_sword.lua       ← 物品属性定义
├── images/
│   ├── modicon.png / .xml         ← 模组列表图标
│   ├── wooden_sword.png / .xml    ← 地面掉落图标
│   └── inventoryimages/
│       └── wooden_sword.png / .xml ← 背包/快捷栏图标
├── TEX_CONVERT_GUIDE.md           ← .tex 转换指南
├── README.md                      ← 本文件
├── TECHNICAL.md                   ← 技术设计文档
└── CHANGELOG.md                   ← 版本记录
```

---

## 🚀 安装方法

1. 将 `wooden_sword` 文件夹放入：
   - **本地模组**：`%UserProfile%\Documents\Klei\DoNotStarveTogether\mods\`
   - **服务器模组**：服务器 `mods/` 目录
2. 启动游戏 → 模组页面 → 启用「小木剑」
3. 进入游戏后即可在物品栏找到

> ⚠️ **重要**：`.png` 贴图需要转换为 `.tex` 格式才能在游戏中正常显示。
> 详见 `TEX_CONVERT_GUIDE.md`

---

## ⚙️ 自定义参数

编辑 `scripts/prefabs/wooden_sword.lua` 中的以下行：

```lua
-- 攻击力
inst.components.weapon:SetDamage(45)     -- 修改数值调整伤害

-- 攻击范围
inst.components.weapon:SetRange(1.2)    -- 修改数值调整距离

-- 耐久度
inst.components.finiteuses:SetMaxUses(60)  -- 修改数值调整耐久
```

---

## 📋 待完成

- [ ] 将 `.png` 贴图转换为 `.tex` 格式
- [ ] 创建 `wooden_sword.zip` 动画构建文件（可选，用于手持动画）
- [ ] 测试游戏内效果

---

## 许可证

本项目仅供学习和个人使用。
