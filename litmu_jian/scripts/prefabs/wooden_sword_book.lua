-- scripts/prefabs/wooden_sword_book.lua
-- 模组之书 — 介绍模组内容

local assets = {
    Asset("ATLAS", "images/inventoryimages/wooden_sword_book.xml"),
    Asset("ANIM", "anim/wooden_sword_book.zip"),
}

local prefabs = {}

-- 书页内容（设计文档内容）
local book_text = [[
═══════════════════════════════════
       🗡️ 小木剑模组 使用手册
═══════════════════════════════════

【初始小木剑】
配方：原木×8 + 草×6
伤害27.2 | 耐久150
修复：木板×1→+75 | 绳子×1→+50

【状态系统】
基础(state0)：150耐久
进阶(state1)：600耐久
月后/影后(state2)：800耐久

【升级系统】
• 战斗升级：每命中+0.08伤害，上限+72.8
• 燧石：每20块+0.25伤害，上限120块
• 石头：每20块+0.25伤害，上限120块
• 金块：每20块+1伤害，上限120块
• 大理石：每20块+2伤害，上限80块

【特殊锻造】
• 海象牙：+25%移速
• 猫尾：+1攻击距离
• 眼球：激光100伤害
• 沙之石×5：沙刺伤害

【宝石系统】
• 红宝石：33.3%灼烧
• 蓝宝石：33.3%冰冻
• 红蓝同锻：33.3%定格3秒
• 紫宝石：闪电60伤害

【阵营】
• 月亮：月岩+月亮碎片
• 暗影：噩梦燃料+铥矿
• 选定后不可更改！

═══════════════════════════════════
]]

local function on_read(inst, reader)
    if not reader then return end
    
    -- 显示书籍内容
    if reader.components.talker then
        -- 分段显示（避免一次性显示太多）
        local lines = {}
        for line in book_text:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        
        -- 逐行显示
        for i, line in ipairs(lines) do
            reader:DoTaskInTime(i * 0.3, function()
                if reader.components.talker then
                    reader.components.talker:Say(line)
                end
            end)
        end
    end
    
    -- 播放读书音效
    if reader.SoundEmitter then
        reader.SoundEmitter:PlaySound("dontstarve/common/book_use")
    end
    
    -- 不消耗书
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- 使用 books 动画
    inst.AnimState:SetBank("book")
    inst.AnimState:SetBuild("book")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("book")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wooden_sword_book.xml"
    inst.components.inventoryitem.imagename = "wooden_sword_book"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS

    -- 使用 book 组件实现读书功能
    inst:AddComponent("book")
    inst.components.book:SetOnRead(on_read)

    MakeInventoryPhysics(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wooden_sword_book", fn, assets, prefabs)