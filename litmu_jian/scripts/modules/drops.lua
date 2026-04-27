-- ============================================
-- 掉落系统（简化版）
-- ============================================
-- 这个文件在 PrefabFiles 中被加载
-- 实际逻辑在 modmain.lua 中实现

-- 确保预制件存在
local function RegisterDropAssets()
    _G.assert(_G.Assets, "Assets not loaded")
end

RegisterDropAssets()
