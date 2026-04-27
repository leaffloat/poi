# 贴图转换指南

饥荒联机版（DST）使用 Klei 专有的 `.tex` 纹理格式，**不能直接使用 `.png` 文件**。

---

## 方法一：使用官方工具（推荐）

1. 下载 **texconv** 工具：
   - 来自 DST 模组工具：https://forums.kleientertainment.com/forums/topic/54094-dedicated-server-how-to-convert-tex-to-png/
   - 或使用社区工具：https://github.com/notprathap/dstex

2. 转换命令（以 dstex 为例）：

```powershell
# 安装工具
pip install dstex

# 转换所有 png → tex
cd D:\mods\wooden_sword\images

dstex encode inventoryimages/wooden_sword.png inventoryimages/wooden_sword.tex
dstex encode wooden_sword.png wooden_sword.tex
dstex encode modicon.png modicon.tex
```

---

## 方法二：使用在线转换

1. 访问 https://tex.klei.com/ （如可用）
2. 上传 `.png` 文件
3. 下载 `.tex` 文件放入对应目录

---

## 需要转换的文件

| PNG 源文件 | 目标 .tex 位置 | 用途 |
|-----------|--------------|------|
| `images/inventoryimages/wooden_sword.png` | `images/inventoryimages/wooden_sword.tex` | 背包/快捷栏图标 |
| `images/wooden_sword.png` | `images/wooden_sword.tex` | 地面掉落图标 |
| `images/modicon.png` | `images/modicon.tex` | 模组列表图标 |

---

## 贴图规格要求

| 文件 | 尺寸 | 格式 |
|------|------|------|
| 背包图标 | 256×256（推荐） | RGBA |
| 地面图标 | 256×256（推荐） | RGBA |
| 模组图标 | 64×64 | RGB/RGBA |

---

转换完成后，目录中应同时存在 `.png`（源文件）和 `.tex`（游戏使用文件）。
