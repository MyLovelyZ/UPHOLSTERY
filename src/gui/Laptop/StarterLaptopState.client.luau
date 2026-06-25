local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local LaptopGui = PlayerGui:WaitForChild("LaptopGui")
local LaptopScreen = LaptopGui:WaitForChild("LaptopScreen")
local Apps = LaptopScreen:WaitForChild("Apps")
local Browsah_Tab = Apps:WaitForChild("Browsah_Tab")
local MoneyMaker_Tab = Apps:WaitForChild("MoneyMaker_Tab")
local Shop_Tab = Apps:WaitForChild("Shop_Tab")
local Talkogram_Tab = Apps:WaitForChild("Talkogram_Tab")
local Miscellaneous = Apps:WaitForChild("Miscellaneous")

LaptopGui.Enabled = true

-- state awal ketika player join
LaptopScreen.Visible = false
LaptopScreen.Active = true

-- state untuk default apps
Apps.Visible = false
Apps.Active = true

-- state untuk default tab
Browsah_Tab.Visible = false
MoneyMaker_Tab.Visible = false
Shop_Tab.Visible = false
Talkogram_Tab.Visible = false
Miscellaneous.Visible = false

-- Desktop state

local Desktop = LaptopScreen:WaitForChild("Desktop")
Desktop.Visible = true
Desktop.Active = true

local LeftPanel = Desktop:WaitForChild("LeftPanel")
local TaskBar = Desktop:WaitForChild("TaskBar")
local BrowsahButton = Desktop:WaitForChild("BrowsahButton")
local QuoteLabel = Desktop:WaitForChild("QuoteLabel")

LeftPanel.Visible = true
TaskBar.Visible = true
BrowsahButton.Visible = true
QuoteLabel.Visible = true

-- kita setting bagian Shop_Tab ygy

local ShopBody = Shop_Tab:WaitForChild("Body")
local ShopScrollingFrame = ShopBody:WaitForChild("ScrollingFrame")
local ShopItemDetail = ShopBody:WaitForChild("itemDetail")

ShopScrollingFrame.Visible = true
ShopItemDetail.Visible = false

ShopScrollingFrame.Size = UDim2.new(0.964, 0, 0.972, 0)

-- bagian shop item detail beb

ShopItemDetail:WaitForChild("buyButton").Visible = true
ShopItemDetail:WaitForChild("buyButton").Active = true
ShopItemDetail:WaitForChild("itemImage").Visible = true
ShopItemDetail:WaitForChild("itemDes").Visible = true
ShopItemDetail:WaitForChild("itemName").Visible = true