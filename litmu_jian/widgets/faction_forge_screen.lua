-- ============================================
-- 阵营锻造界面
-- ============================================

local Widget = require("widgets")
local Image = require("image")
local Text = require("text")
local ImageButton = require("imagebutton")

local FactionForgeScreen = Class(Widget, function(self)
    Widget._ctor(self, "FactionForgeScreen")
    
    self.forge_inst = nil
    
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    
    -- 背景
    self.bg = self.root:AddChild(Image("images/forge_bg.tex", "forge_bg.xml"))
    self.bg:SetSize(500, 600)
    
    -- 标题
    self.title = self.root:AddChild(Text(BOLDFONT, 45))
    self.title:SetString("阵营锻造")
    self.title:SetPosition(0, 250)
    self.title:SetColour(1, 0.9, 0.6, 1)
    
    -- 状态显示
    self.status = self.root:AddChild(Text(BFONT, 28))
    self.status:SetString("当前状态：进阶")
    self.status:SetPosition(0, 200)
    
    -- 月亮阵营按钮
    self.lunar_btn = self.root:AddChild(ImageButton("images/button_carny_LONG.tex", "button_carny_LONG.xml"))
    self.lunar_btn:SetPosition(-120, 100)
    self.lunar_btn:SetText("月亮阵营")
    self.lunar_btn:SetScale(0.9)
    
    -- 月亮阵营需求
    self.lunar_req = self.root:AddChild(Text(BFONT, 22))
    self.lunar_req:SetString("需求：黄宝石×3 + 亮茄碎片×6\n效果：对暗影伤害×2，召唤月之虚影")
    self.lunar_req:SetPosition(-120, 40)
    self.lunar_req:SetColour(0.7, 0.7, 0.7, 1)
    
    -- 暗影阵营按钮
    self.shadow_btn = self.root:AddChild(ImageButton("images/button_carny_LONG.tex", "button_carny_LONG.xml"))
    self.shadow_btn:SetPosition(120, 100)
    self.shadow_btn:SetText("暗影阵营")
    self.shadow_btn:SetScale(0.9)
    
    -- 暗影阵营需求
    self.shadow_req = self.root:AddChild(Text(BFONT, 22))
    self.shadow_req:SetString("需求：紫宝石×3 + 暗影触手×6\n效果：对月亮伤害×2，召唤暗影触手")
    self.shadow_req:SetPosition(120, 40)
    self.shadow_req:SetColour(0.7, 0.7, 0.7, 1)
    
    -- 武器显示
    self.weapon_info = self.root:AddChild(Text(BFONT, 26))
    self.weapon_info:SetPosition(0, -50)
    self.weapon_info:SetString("请放入进阶后的武器")
    
    -- 关闭按钮
    self.close_btn = self.root:AddChild(ImageButton("images/close.tex", "close.xml"))
    self.close_btn:SetPosition(220, 260)
    self.close_btn:SetScale(0.5)
    
    -- 事件绑定
    self.lunar_btn:SetOnClick(function() self:ChooseFaction("lunar") end)
    self.shadow_btn:SetOnClick(function() self:ChooseFaction("shadow") end)
    self.close_btn:SetOnClick(function() self:Close() end)
end)

function FactionForgeScreen:Open(forge_inst)
    self.forge_inst = forge_inst
    self:Show()
    self:UpdateDisplay()
end

function FactionForgeScreen:Close()
    self:Hide()
    TheFrontEnd:PopScreen()
end

function FactionForgeScreen:UpdateDisplay()
    if not self.forge_inst then return end
    
    local container = self.forge_inst.components.container
    if not container then return end
    
    local weapon = container:GetItem(5)
    if weapon then
        local data = weapon.components.inventoryitem:GetData()
        local state = data.state or 0
        local faction = data.faction or ""
        
        if state >= 1 then
            if faction == "lunar" then
                self.weapon_info:SetString("武器已选择：月亮阵营\n耐久：800\n效果：对暗影伤害×2，召唤月之虚影")
                self.lunar_btn:SetEnabled(false)
                self.shadow_btn:SetEnabled(false)
            elseif faction == "shadow" then
                self.weapon_info:SetString("武器已选择：暗影阵营\n耐久：800\n效果：对月亮伤害×2，召唤暗影触手")
                self.lunar_btn:SetEnabled(false)
                self.shadow_btn:SetEnabled(false)
            else
                self.weapon_info:SetString("武器状态：进阶\n可选择阵营")
                self.lunar_btn:SetEnabled(true)
                self.shadow_btn:SetEnabled(true)
            end
        else
            self.weapon_info:SetString("武器未达到进阶状态\n无法选择阵营")
            self.lunar_btn:SetEnabled(false)
            self.shadow_btn:SetEnabled(false)
        end
    else
        self.weapon_info:SetString("请放入武器")
    end
end

function FactionForgeScreen:ChooseFaction(faction_type)
    if not self.forge_inst then return end
    
    local container = self.forge_inst.components.container
    if not container then return end
    
    local weapon = container:GetItem(5)
    if not weapon then return end
    
    local data = weapon.components.inventoryitem:GetData()
    local state = data.state or 0
    
    if state < 1 then return end
    if data.faction and data.faction ~= "" then return end
    
    -- 检查材料
    local recipe = (faction_type == "lunar") and {
        {prefab = "yellowgem", count = 3},
        {prefab = "lightbulb", count = 6},
    } or {
        {prefab = "purplegem", count = 3},
        {prefab = " Tentacle", count = 6}, -- Tentacle
    }
    
    -- 检查材料是否足够
    local can_forge = true
    for _, req in ipairs(recipe) do
        local found = 0
        for i = 1, 4 do
            local item = container:GetItem(i)
            if item and item.prefab == req.prefab then
                found = found + (item.components.stackable and item.components.stackable:GetStackSize() or 1)
            end
        end
        if found < req.count then
            can_forge = false
            break
        end
    end
    
    if not can_forge then return end
    
    -- 消耗材料
    for _, req in ipairs(recipe) do
        local need = req.count
        for i = 1, 4 do
            local item = container:GetItem(i)
            if item and item.prefab == req.prefab and need > 0 then
                local take = math.min(need, item.components.stackable:GetStackSize())
                item:DoDelta(-take)
                need = need - take
            end
        end
    end
    
    -- 设置阵营
    data.faction = faction_type
    data.state = 2
    data.durability = 800
    
    if faction_type == "lunar" then
        data.extra_bonus = 30
    else
        data.shadow_bonus = 30
    end
    
    weapon.components.inventoryitem:SetData(data)
    weapon.components.finiteuses:SetUses(800)
    weapon.components.weapon:SetDamage(27.2 + (data.combat_level or 0) * 0.08 + (data.material_bonus or 0) + 30)
    
    self.forge_inst.SoundEmitter:PlaySound("dontstarve/common/repair_station_finish")
    self:UpdateDisplay()
end

return FactionForgeScreen