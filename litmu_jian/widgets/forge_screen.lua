-- ============================================
-- 锻造炉UI Widget
-- ============================================

local Widget = require("widgets")
local Image = require("image")
local Text = require("text")
local ImageButton = require("imagebutton")
local TEMPLATES = require("ui/templates")

local ForgeScreen = Class(Widget, function(self)
    Widget._ctor(self, "ForgeScreen")
    
    self.forge_inst = nil
    self.weapon_data = nil
    
    -- 根节点
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    -- 背景
    self.bg = self.root:AddChild(Image("images/forge_bg.tex", "forge_bg.xml"))
    self.bg:SetSize(400, 500)
    self.bg:SetPosition(0, 0)
    
    -- 标题
    self.title = self.root:AddChild(Text(BOLDFONT, 40))
    self.title:SetString("锻造炉")
    self.title:SetPosition(0, 220)
    self.title:SetColour(1, 0.9, 0.6, 1)
    
    -- 材料格显示
    self:BuildMaterialSlots()
    
    -- 武器格显示
    self:BuildWeaponSlot()
    
    -- 属性显示
    self:BuildStats()
    
    -- 锻造按钮
    self:BuildForgeButton()
    
    -- 关闭按钮
    self:BuildCloseButton()
end)

function ForgeScreen:BuildMaterialSlots()
    self.material_slots = {}
    local positions = {
        {-120, 120}, {0, 120}, {120, 120}, {-60, 60}
    }
    
    for i, pos in ipairs(positions) do
        local slot = self.root:AddChild(Widget("slot"..i))
        slot:SetPosition(pos[1], pos[2])
        
        local bg = slot:AddChild(Image("images/inventoryimages_bg.tex", "inventoryimages_bg.xml"))
        bg:SetSize(60, 60)
        
        local count = slot:AddChild(Text(BOLDFONT, 30))
        count:SetString("")
        count:SetPosition(20, -20)
        
        self.material_slots[i] = {widget = slot, count = count, item = nil}
    end
end

function ForgeScreen:BuildWeaponSlot()
    self.weapon_slot = self.root:AddChild(Widget("weapon_slot"))
    self.weapon_slot:SetPosition(0, -60)
    
    local bg = self.weapon_slot:AddChild(Image("images/inventoryimages_bg.tex", "inventoryimages_bg.xml"))
    bg:SetSize(80, 80)
    
    self.weapon_icon = self.weapon_slot:AddChild(Image("images/inventoryimages/wooden_sword.tex", "wooden_sword.xml"))
    self.weapon_icon:SetSize(64, 64)
    self.weapon_icon:Hide()
    
    self.weapon_name = self.root:AddChild(Text(BOLDFONT, 28))
    self.weapon_name:SetString("请放入武器")
    self.weapon_name:SetPosition(0, -140)
    self.weapon_name:SetColour(0.7, 0.7, 0.7, 1)
end

function ForgeScreen:BuildStats()
    self.stats_text = self.root:AddChild(Text(BFONT, 24))
    self.stats_text:SetString("伤害: 27.2\n耐久: 150\n材料: 0")
    self.stats_text:SetPosition(0, -180)
end

function ForgeScreen:BuildForgeButton()
    self.forge_btn = self.root:AddChild(ImageButton("images/button_carny_LONG.tex", "button_carny_LONG.xml", "锻造"))
    self.forge_btn:SetPosition(0, -250)
    self.forge_btn:SetScale(0.8)
    
    self.forge_btn:SetOnClick(function()
        self:DoForge()
    end)
end

function ForgeScreen:BuildCloseButton()
    self.close_btn = self.root:AddChild(ImageButton("images/close.tex", "close.xml", ""))
    self.close_btn:SetPosition(180, 220)
    self.close_btn:SetScale(0.5)
    
    self.close_btn:SetOnClick(function()
        self:Close()
    end)
end

function ForgeScreen:Open(forge_inst)
    self.forge_inst = forge_inst
    self:Show()
    self:UpdateDisplay()
end

function ForgeScreen:Close()
    self:Hide()
    if self.forge_inst and self.forge_inst.components.container then
        self.forge_inst.components.container:Close()
    end
    TheFrontEnd:PopScreen()
end

function ForgeScreen:DoForge()
    -- 锻造逻辑在 forge.lua 组件中处理
    self:UpdateDisplay()
end

function ForgeScreen:UpdateDisplay()
    if not self.forge_inst then return end
    
    local container = self.forge_inst.components.container
    if not container then return end
    
    -- 更新材料格
    for i = 1, 4 do
        local item = container:GetItem(i)
        if item then
            self.material_slots[i].item = item
            local stack = item.components.stackable and item.components.stackable:GetStackSize() or 1
            self.material_slots[i].count:SetString(tostring(stack))
        else
            self.material_slots[i].item = nil
            self.material_slots[i].count:SetString("")
        end
    end
    
    -- 更新武器格
    local weapon = container:GetItem(5)
    if weapon then
        self.weapon_name:SetString("小木剑")
        self.weapon_name:SetColour(1, 0.9, 0.6, 1)
        self.weapon_icon:Show()
        
        local data = weapon.components.inventoryitem:GetData()
        local dmg = (data.attack or 27.2) + (data.combat_level or 0) * 0.08 + (data.material_bonus or 0)
        local dur = data.durability or 150
        local state = data.state or 0
        local state_name = (state == 0 and "基础") or (state == 1 and "进阶") or "月后/影后"
        
        local equip_str = ""
        for k, v in pairs(data.equip or {}) do
            if v > 0 then
                equip_str = equip_str .. k .. ":" .. v .. " "
            end
        end
        
        self.stats_text:SetString(
            string.format("伤害: %.1f\n耐久: %d / %d\n状态: %s\n材料: %s", 
            dmg, dur, (state == 1 and 600) or (state == 2 and 800) or 150,
            state_name, equip_str)
        )
    else
        self.weapon_name:SetString("请放入武器")
        self.weapon_name:SetColour(0.7, 0.7, 0.7, 1)
        self.weapon_icon:Hide()
        self.stats_text:SetString("伤害: -\n耐久: -\n状态: -\n材料: -")
    end
end

return ForgeScreen