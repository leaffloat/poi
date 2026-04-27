-- scripts/actions/wooden_sword_actions.lua
-- 小木剑相关自定义动作

local Action = GLOBAL.Action
local ACTIONS = GLOBAL.ACTIONS

-- ===== 小木剑升级动作 =====
ACTIONS.UPGRADE_SWORD = Action()
ACTIONS.UPGRADE_SWORD.str = "升级小木剑"
ACTIONS.UPGRADE_SWORD.id = "UPGRADE_SWORD"
ACTIONS.UPGRADE_SWORD.mount_valid = false
ACTIONS.UPGRADE_SWORD.distance = 3

-- ===== 小木剑锻造动作 =====
ACTIONS.FORGE_SWORD = Action()
ACTIONS.FORGE_SWORD.str = "锻造"
ACTIONS.FORGE_SWORD.id = "FORGE_SWORD"
ACTIONS.FORGE_SWORD.mount_valid = false

-- ===== 帽子锻造动作 =====
ACTIONS.FORGE_HAT = Action()
ACTIONS.FORGE_HAT.str = "锻造帽子"
ACTIONS.FORGE_HAT.id = "FORGE_HAT"
ACTIONS.FORGE_HAT.mount_valid = false

-- ===== 帽子插槽动作 =====
ACTIONS.UPGRADE_HAT_SLOT = Action()
ACTIONS.UPGRADE_HAT_SLOT.str = "升级插槽"
ACTIONS.UPGRADE_HAT_SLOT.id = "UPGRADE_HAT_SLOT"
ACTIONS.UPGRADE_HAT_SLOT.mount_valid = false

-- ===== 风筝升级动作 =====
ACTIONS.UPGRADE_KITE = Action()
ACTIONS.UPGRADE_KITE.str = "升级风筝"
ACTIONS.UPGRADE_KITE.id = "UPGRADE_KITE"
ACTIONS.UPGRADE_KITE.mount_valid = false

-- ===== 缩壳动作 =====
ACTIONS.SHELL_HIDE = Action()
ACTIONS.SHELL_HIDE.str = "缩进壳里"
ACTIONS.SHELL_HIDE.id = "SHELL_HIDE"
ACTIONS.SHELL_HIDE.mount_valid = false

return ACTIONS
