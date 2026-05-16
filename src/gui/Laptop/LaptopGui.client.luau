-- --[[
-- 	LaptopGui — fully code-driven
-- 	Creates the entire laptop UI from scratch. No Studio ScreenGui needed.

-- 	To use exclusively:
-- 	  1. Disable / delete the Studio-built LaptopGui ScreenGui
-- 	  2. Disable LaptopBrowser.client.luau
-- 	  3. Keep LaptopInteraction (fires the LaptopOpened BindableEvent)
-- ]]

-- local Players           = game:GetService("Players")
-- local TweenService      = game:GetService("TweenService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local player    = Players.LocalPlayer
-- local PlayerGui = player:WaitForChild("PlayerGui")

-- -- ── Remotes ───────────────────────────────────────────────────────────────

-- local Remotes = ReplicatedStorage:WaitForChild("LaptopRemotes", 10)
-- local function R(name) return Remotes and Remotes:WaitForChild(name, 5) end

-- -- ── Palette ───────────────────────────────────────────────────────────────

-- local C = {
-- 	bg      = Color3.fromRGB(14,  16,  22),
-- 	surface = Color3.fromRGB(20,  24,  34),
-- 	card    = Color3.fromRGB(28,  33,  46),
-- 	border  = Color3.fromRGB(44,  52,  70),
-- 	accent  = Color3.fromRGB(85,  155, 255),
-- 	dim     = Color3.fromRGB(45,  90,  165),
-- 	text    = Color3.fromRGB(220, 226, 238),
-- 	sub     = Color3.fromRGB(120, 132, 158),
-- 	green   = Color3.fromRGB(65,  195, 100),
-- 	red     = Color3.fromRGB(210, 55,  55),
-- }

-- local TIER_COLOR = {
-- 	Mid       = Color3.fromRGB(80,  160, 80),
-- 	Premium   = Color3.fromRGB(70,  120, 210),
-- 	Prestige  = Color3.fromRGB(150, 80,  220),
-- 	Exclusive = Color3.fromRGB(210, 110, 30),
-- 	Elite     = Color3.fromRGB(200, 40,  40),
-- 	Special   = Color3.fromRGB(215, 175, 55),
-- }

-- -- ── Build helpers ─────────────────────────────────────────────────────────

-- local function make(class, props, parent)
-- 	local o = Instance.new(class)
-- 	for k, v in pairs(props) do o[k] = v end
-- 	if parent then o.Parent = parent end
-- 	return o
-- end

-- local function corner(r, p)
-- 	make("UICorner", { CornerRadius = UDim.new(0, r) }, p)
-- end

-- local function pad(px, p)
-- 	make("UIPadding", {
-- 		PaddingTop    = UDim.new(0, px), PaddingBottom = UDim.new(0, px),
-- 		PaddingLeft   = UDim.new(0, px), PaddingRight  = UDim.new(0, px),
-- 	}, p)
-- end

-- local function listV(gap, p)
-- 	make("UIListLayout", {
-- 		FillDirection = Enum.FillDirection.Vertical,
-- 		SortOrder     = Enum.SortOrder.LayoutOrder,
-- 		Padding       = UDim.new(0, gap),
-- 	}, p)
-- end

-- local function listH(gap, valign, p)
-- 	make("UIListLayout", {
-- 		FillDirection     = Enum.FillDirection.Horizontal,
-- 		VerticalAlignment = valign or Enum.VerticalAlignment.Center,
-- 		SortOrder         = Enum.SortOrder.LayoutOrder,
-- 		Padding           = UDim.new(0, gap),
-- 	}, p)
-- end

-- local function lbl(txt, sz, col, bold, xa, parent)
-- 	return make("TextLabel", {
-- 		Text                    = txt,
-- 		TextSize                = sz,
-- 		TextColor3              = col or C.text,
-- 		Font                    = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
-- 		BackgroundTransparency  = 1,
-- 		Size                    = UDim2.new(1, 0, 0, sz + 6),
-- 		TextXAlignment          = xa or Enum.TextXAlignment.Left,
-- 		TextTruncate            = Enum.TextTruncate.AtEnd,
-- 	}, parent)
-- end

-- local function tbtn(txt, bg, sz, parent)
-- 	local b = make("TextButton", {
-- 		Text             = txt,
-- 		TextSize         = sz or 14,
-- 		TextColor3       = C.text,
-- 		Font             = Enum.Font.GothamBold,
-- 		BackgroundColor3 = bg or C.accent,
-- 		Size             = UDim2.new(0, 110, 0, 34),
-- 		AutoButtonColor  = false,
-- 	}, parent)
-- 	corner(8, b)
-- 	return b
-- end

-- local function scrollFrame(parent, size, pos)
-- 	local s = make("ScrollingFrame", {
-- 		Size                 = size or UDim2.new(1, 0, 1, 0),
-- 		Position             = pos or UDim2.new(0, 0, 0, 0),
-- 		BackgroundTransparency = 1,
-- 		BorderSizePixel      = 0,
-- 		ScrollBarThickness   = 4,
-- 		ScrollBarImageColor3 = C.border,
-- 		CanvasSize           = UDim2.new(0, 0, 0, 0),
-- 		AutomaticCanvasSize  = Enum.AutomaticSize.Y,
-- 		ClipsDescendants     = true,
-- 	}, parent)
-- 	return s
-- end

-- local function clearKids(container)
-- 	for _, c in ipairs(container:GetChildren()) do
-- 		if not c:IsA("UIListLayout") and not c:IsA("UIPadding")
-- 			and not c:IsA("UIGridLayout") and not c:IsA("UICorner") then
-- 			c:Destroy()
-- 		end
-- 	end
-- end

-- -- ── Root ScreenGui ────────────────────────────────────────────────────────

-- local gui = make("ScreenGui", {
-- 	Name           = "LaptopGui",
-- 	ResetOnSpawn   = false,
-- 	IgnoreGuiInset = true,
-- 	DisplayOrder   = 10,
-- 	Enabled        = false,
-- }, PlayerGui)

-- -- Dimmer backdrop (click to close)
-- local backdrop = make("TextButton", {
-- 	Size                   = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3       = Color3.new(0, 0, 0),
-- 	BackgroundTransparency = 0.45,
-- 	Text                   = "",
-- 	BorderSizePixel        = 0,
-- 	ZIndex                 = 1,
-- }, gui)

-- -- Laptop bezel
-- local bezel = make("Frame", {
-- 	Size             = UDim2.new(0, 820, 0, 560),
-- 	Position         = UDim2.new(0.5, -410, 0.5, -280),
-- 	BackgroundColor3 = C.bg,
-- 	BorderSizePixel  = 0,
-- 	ZIndex           = 2,
-- }, gui)
-- corner(14, bezel)

-- -- Inner screen (slight inset)
-- local screen = make("Frame", {
-- 	Size             = UDim2.new(1, -16, 1, -16),
-- 	Position         = UDim2.new(0, 8, 0, 8),
-- 	BackgroundColor3 = C.surface,
-- 	ClipsDescendants = true,
-- 	BorderSizePixel  = 0,
-- }, bezel)
-- corner(8, screen)

-- -- ── Page system ───────────────────────────────────────────────────────────

-- local _pages = {}

-- local function reg(name, frame)
-- 	_pages[name] = frame
-- 	frame.Visible = false
-- end

-- local function show(name)
-- 	for k, f in pairs(_pages) do
-- 		f.Visible = (k == name)
-- 	end
-- end

-- -- ── Shared nav bar (browser pages only) ──────────────────────────────────

-- local navBar = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 0, 44),
-- 	BackgroundColor3 = C.bg,
-- 	BorderSizePixel  = 0,
-- 	ZIndex           = 4,
-- 	Visible          = false,
-- }, screen)
-- listH(6, Enum.VerticalAlignment.Center, navBar)
-- pad(8, navBar)

-- local navBack = tbtn("←", C.card, 14, navBar)
-- navBack.Size = UDim2.new(0, 36, 0, 30)

-- local navHome = tbtn("⌂", C.card, 14, navBar)
-- navHome.Size = UDim2.new(0, 36, 0, 30)

-- local addrBar = make("TextLabel", {
-- 	Text                   = "browsah://home",
-- 	TextSize               = 13,
-- 	TextColor3             = C.sub,
-- 	Font                   = Enum.Font.Gotham,
-- 	BackgroundColor3       = C.card,
-- 	BackgroundTransparency = 0,
-- 	Size                   = UDim2.new(1, -134, 0, 30),
-- 	TextXAlignment         = Enum.TextXAlignment.Left,
-- }, navBar)
-- corner(6, addrBar)
-- pad(10, addrBar)

-- local navClose = tbtn("✕", C.red, 13, navBar)
-- navClose.Size  = UDim2.new(0, 36, 0, 30)
-- navClose.Activated:Connect(function() gui.Enabled = false end)

-- -- Content area (below nav bar, browser pages live here)
-- local content = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, -44),
-- 	Position         = UDim2.new(0, 0, 0, 44),
-- 	BackgroundTransparency = 1,
-- 	ClipsDescendants = true,
-- }, screen)

-- -- ── PAGE: Loading Screen ──────────────────────────────────────────────────

-- local loadPage = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3 = C.bg,
-- 	BorderSizePixel  = 0,
-- 	ZIndex           = 6,
-- }, screen)
-- reg("LoadingScreen", loadPage)

-- make("TextLabel", {
-- 	Text           = "UPHOLSTERY!",
-- 	TextSize       = 38,
-- 	TextColor3     = C.accent,
-- 	Font           = Enum.Font.GothamBold,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(0.6, 0, 0, 52),
-- 	Position       = UDim2.new(0.2, 0, 0.33, 0),
-- 	TextXAlignment = Enum.TextXAlignment.Center,
-- 	ZIndex         = 6,
-- }, loadPage)

-- local loadSub = make("TextLabel", {
-- 	Text           = "",
-- 	TextSize       = 13,
-- 	TextColor3     = C.sub,
-- 	Font           = Enum.Font.Gotham,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(0.6, 0, 0, 22),
-- 	Position       = UDim2.new(0.2, 0, 0.44, 0),
-- 	TextXAlignment = Enum.TextXAlignment.Center,
-- 	ZIndex         = 6,
-- }, loadPage)

-- local barBg = make("Frame", {
-- 	Size             = UDim2.new(0.5, 0, 0, 6),
-- 	Position         = UDim2.new(0.25, 0, 0.52, 0),
-- 	BackgroundColor3 = C.card,
-- 	BorderSizePixel  = 0,
-- 	ZIndex           = 6,
-- }, loadPage)
-- corner(3, barBg)

-- local barFill = make("Frame", {
-- 	Size             = UDim2.fromScale(0, 1),
-- 	BackgroundColor3 = C.accent,
-- 	BorderSizePixel  = 0,
-- 	ZIndex           = 6,
-- }, barBg)
-- corner(3, barFill)

-- -- ── PAGE: OS Screen ───────────────────────────────────────────────────────

-- local QUOTES = {
-- 	"every cushion tells a story",
-- 	"stitch by stitch, greatness is sewn",
-- 	"the foam is always greener on the other side",
-- 	"a tack a day keeps the sagging away",
-- 	"measure twice, staple once",
-- 	"fame is just followers. craft is forever.",
-- 	"prestige jobs don't do themselves",
-- 	"you vs the sofa she told you not to worry about",
-- 	"no days off when the fabric calls",
-- }

-- local osPage = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3 = Color3.fromRGB(16, 18, 28),
-- 	BorderSizePixel  = 0,
-- 	ZIndex           = 5,
-- }, screen)
-- reg("OSScreen", osPage)

-- make("UIGradient", {
-- 	Color = ColorSequence.new({
-- 		ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 22, 42)),
-- 		ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 11, 19)),
-- 	}),
-- 	Rotation = 135,
-- }, osPage)

-- make("TextLabel", {
-- 	Text           = "UPHOLSTERY! OS",
-- 	TextSize       = 16,
-- 	TextColor3     = Color3.fromRGB(70, 80, 120),
-- 	Font           = Enum.Font.GothamBold,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, -24, 0, 24),
-- 	Position       = UDim2.new(0, 12, 0, 10),
-- 	TextXAlignment = Enum.TextXAlignment.Left,
-- 	ZIndex         = 5,
-- }, osPage)

-- local osQuote = make("TextLabel", {
-- 	Text           = "",
-- 	TextSize       = 12,
-- 	TextColor3     = Color3.fromRGB(80, 92, 130),
-- 	Font           = Enum.Font.Gotham,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(0.7, 0, 0, 18),
-- 	Position       = UDim2.new(0.15, 0, 0.88, 0),
-- 	TextXAlignment = Enum.TextXAlignment.Center,
-- 	ZIndex         = 5,
-- }, osPage)

-- -- App dock row
-- local dock = make("Frame", {
-- 	Size     = UDim2.new(0, 280, 0, 96),
-- 	Position = UDim2.new(0.5, -140, 0.42, 0),
-- 	BackgroundTransparency = 1,
-- 	ZIndex   = 5,
-- }, osPage)
-- listH(20, Enum.VerticalAlignment.Center, dock)

-- local function appIcon(emoji, label_text, color, parent)
-- 	local wrap = make("Frame", {
-- 		Size             = UDim2.new(0, 70, 0, 88),
-- 		BackgroundTransparency = 1,
-- 		ZIndex           = 5,
-- 	}, parent)
-- 	make("UIListLayout", {
-- 		FillDirection       = Enum.FillDirection.Vertical,
-- 		HorizontalAlignment = Enum.HorizontalAlignment.Center,
-- 		Padding             = UDim.new(0, 5),
-- 	}, wrap)
-- 	local icon = make("TextButton", {
-- 		Text             = emoji,
-- 		TextSize         = 26,
-- 		BackgroundColor3 = color,
-- 		Size             = UDim2.new(0, 58, 0, 58),
-- 		Font             = Enum.Font.GothamBold,
-- 		TextColor3       = Color3.new(1,1,1),
-- 		AutoButtonColor  = false,
-- 		ZIndex           = 5,
-- 	}, wrap)
-- 	corner(14, icon)
-- 	make("TextLabel", {
-- 		Text           = label_text,
-- 		TextSize       = 11,
-- 		TextColor3     = Color3.fromRGB(190, 198, 220),
-- 		Font           = Enum.Font.Gotham,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, 0, 0, 16),
-- 		TextXAlignment = Enum.TextXAlignment.Center,
-- 		ZIndex         = 5,
-- 	}, wrap)
-- 	return icon
-- end

-- local iconBrowsah  = appIcon("🌐", "Browsah",   Color3.fromRGB(45, 105, 205), dock)
-- local iconShutdown = appIcon("⏻",  "Shut Down", Color3.fromRGB(160, 38, 38),  dock)

-- iconShutdown.Activated:Connect(function() gui.Enabled = false end)

-- -- ── PAGE: Browsah Home ────────────────────────────────────────────────────

-- local homePage = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3 = C.surface,
-- 	BorderSizePixel  = 0,
-- }, content)
-- reg("BrowsahHome", homePage)

-- make("TextLabel", {
-- 	Text           = "Where do you want to go?",
-- 	TextSize       = 20,
-- 	TextColor3     = C.text,
-- 	Font           = Enum.Font.GothamBold,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, -28, 0, 36),
-- 	Position       = UDim2.new(0, 16, 0, 16),
-- 	TextXAlignment = Enum.TextXAlignment.Left,
-- }, homePage)

-- local bookmarks = make("Frame", {
-- 	Size     = UDim2.new(1, -28, 0, 130),
-- 	Position = UDim2.new(0, 14, 0, 62),
-- 	BackgroundTransparency = 1,
-- }, homePage)

-- make("UIGridLayout", {
-- 	CellSize    = UDim2.new(0, 180, 0, 110),
-- 	CellPadding = UDim2.new(0, 12, 0, 12),
-- 	SortOrder   = Enum.SortOrder.LayoutOrder,
-- }, bookmarks)

-- local function bookmark(title, sub_text, emoji, accentCol, order)
-- 	local card = make("TextButton", {
-- 		Size             = UDim2.new(0, 180, 0, 110),
-- 		BackgroundColor3 = C.card,
-- 		Text             = "",
-- 		AutoButtonColor  = false,
-- 		LayoutOrder      = order,
-- 	}, bookmarks)
-- 	corner(10, card)
-- 	-- Top accent strip
-- 	local strip = make("Frame", {
-- 		Size             = UDim2.new(1, 0, 0, 5),
-- 		BackgroundColor3 = accentCol,
-- 		BorderSizePixel  = 0,
-- 	}, card)
-- 	make("UICorner", { CornerRadius = UDim.new(0, 10) }, strip)
-- 	-- Square off the bottom corners of the strip
-- 	make("Frame", {
-- 		Size             = UDim2.new(1, 0, 0.5, 0),
-- 		Position         = UDim2.new(0, 0, 0.5, 0),
-- 		BackgroundColor3 = accentCol,
-- 		BorderSizePixel  = 0,
-- 	}, strip)
-- 	make("TextLabel", {
-- 		Text           = emoji,
-- 		TextSize       = 28,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(0, 38, 0, 38),
-- 		Position       = UDim2.new(0, 12, 0, 16),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, card)
-- 	make("TextLabel", {
-- 		Text           = title,
-- 		TextSize       = 14,
-- 		TextColor3     = C.text,
-- 		Font           = Enum.Font.GothamBold,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, -16, 0, 20),
-- 		Position       = UDim2.new(0, 12, 0, 64),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, card)
-- 	make("TextLabel", {
-- 		Text           = sub_text,
-- 		TextSize       = 11,
-- 		TextColor3     = C.sub,
-- 		Font           = Enum.Font.Gotham,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, -16, 0, 16),
-- 		Position       = UDim2.new(0, 12, 0, 84),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, card)
-- 	return card
-- end

-- local bmTalkogram  = bookmark("Talkogram",  "Social feed",  "📸", Color3.fromRGB(220, 70, 100),  1)
-- local bmMoneyMaker = bookmark("MoneyMaker", "Find jobs",    "💼", Color3.fromRGB(55,  180, 100), 2)
-- local bmShop       = bookmark("The Shop",   "Buy tools",    "🛒", Color3.fromRGB(80,  130, 215), 3)

-- -- ── PAGE: Talkogram Feed ──────────────────────────────────────────────────

-- local feedPage = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3 = C.surface,
-- 	BorderSizePixel  = 0,
-- }, content)
-- reg("TalkogramFeed", feedPage)

-- local filterBar = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 0, 46),
-- 	BackgroundColor3 = C.card,
-- 	BorderSizePixel  = 0,
-- }, feedPage)
-- listH(8, Enum.VerticalAlignment.Center, filterBar)
-- pad(10, filterBar)

-- make("TextLabel", {
-- 	Text           = "Talkogram",
-- 	TextSize       = 16,
-- 	TextColor3     = C.text,
-- 	Font           = Enum.Font.GothamBold,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, -230, 0, 28),
-- 	TextXAlignment = Enum.TextXAlignment.Left,
-- }, filterBar)

-- local btnGlobal = tbtn("🌐  Global", C.accent, 13, filterBar)
-- btnGlobal.Size = UDim2.new(0, 100, 0, 30)

-- local btnServer = tbtn("🖥  Server", C.card,   13, filterBar)
-- btnServer.Size = UDim2.new(0, 100, 0, 30)

-- local feedScroll = scrollFrame(feedPage, UDim2.new(1, 0, 1, -46), UDim2.new(0, 0, 0, 46))
-- pad(12, feedScroll)
-- listV(10, feedScroll)

-- -- ── PAGE: Talkogram Post ──────────────────────────────────────────────────

-- local postPage = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3 = C.surface,
-- 	BorderSizePixel  = 0,
-- }, content)
-- reg("TalkogramPost", postPage)

-- local postTitleLbl = make("TextLabel", {
-- 	Text           = "",
-- 	TextSize       = 18,
-- 	TextColor3     = C.text,
-- 	Font           = Enum.Font.GothamBold,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, -24, 0, 28),
-- 	Position       = UDim2.new(0, 12, 0, 12),
-- 	TextXAlignment = Enum.TextXAlignment.Left,
-- 	TextWrapped    = true,
-- }, postPage)

-- local postAuthorLbl = make("TextLabel", {
-- 	Text           = "",
-- 	TextSize       = 13,
-- 	TextColor3     = C.sub,
-- 	Font           = Enum.Font.Gotham,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, -24, 0, 20),
-- 	Position       = UDim2.new(0, 12, 0, 42),
-- 	TextXAlignment = Enum.TextXAlignment.Left,
-- }, postPage)

-- make("Frame", {
-- 	Size             = UDim2.new(1, -24, 0, 1),
-- 	Position         = UDim2.new(0, 12, 0, 68),
-- 	BackgroundColor3 = C.border,
-- 	BorderSizePixel  = 0,
-- }, postPage)

-- local commentsScroll = scrollFrame(postPage, UDim2.new(1, 0, 1, -120), UDim2.new(0, 0, 0, 72))
-- pad(12, commentsScroll)
-- listV(8, commentsScroll)

-- local commentInput = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 0, 48),
-- 	Position         = UDim2.new(0, 0, 1, -48),
-- 	BackgroundColor3 = C.card,
-- 	BorderSizePixel  = 0,
-- }, postPage)
-- listH(8, Enum.VerticalAlignment.Center, commentInput)
-- pad(8, commentInput)

-- local commentBox = make("TextBox", {
-- 	Size              = UDim2.new(1, -96, 0, 32),
-- 	BackgroundColor3  = C.surface,
-- 	PlaceholderText   = "Add a comment...",
-- 	Text              = "",
-- 	TextSize          = 13,
-- 	TextColor3        = C.text,
-- 	Font              = Enum.Font.Gotham,
-- 	PlaceholderColor3 = C.sub,
-- 	ClearTextOnFocus  = false,
-- }, commentInput)
-- corner(6, commentBox)
-- pad(8, commentBox)

-- local sendBtn = tbtn("Send", C.accent, 13, commentInput)
-- sendBtn.Size = UDim2.new(0, 80, 0, 32)

-- -- ── PAGE: MoneyMaker (Job Board) ──────────────────────────────────────────

-- local jobPage = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3 = C.surface,
-- 	BorderSizePixel  = 0,
-- }, content)
-- reg("MoneyMakerPage", jobPage)

-- local jobHeader = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 0, 50),
-- 	BackgroundColor3 = C.card,
-- 	BorderSizePixel  = 0,
-- }, jobPage)
-- listH(10, Enum.VerticalAlignment.Center, jobHeader)
-- pad(12, jobHeader)

-- make("TextLabel", {
-- 	Text           = "MoneyMaker — Job Board",
-- 	TextSize       = 16,
-- 	TextColor3     = C.text,
-- 	Font           = Enum.Font.GothamBold,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, -130, 0, 28),
-- 	TextXAlignment = Enum.TextXAlignment.Left,
-- }, jobHeader)

-- local jobRefreshBtn = tbtn("↺  Refresh", C.dim, 13, jobHeader)
-- jobRefreshBtn.Size = UDim2.new(0, 110, 0, 30)

-- local jobScroll = scrollFrame(jobPage, UDim2.new(1, 0, 1, -50), UDim2.new(0, 0, 0, 50))
-- pad(12, jobScroll)
-- listV(10, jobScroll)

-- -- ── PAGE: Shop ────────────────────────────────────────────────────────────

-- local shopPage = make("Frame", {
-- 	Size             = UDim2.new(1, 0, 1, 0),
-- 	BackgroundColor3 = C.surface,
-- 	BorderSizePixel  = 0,
-- }, content)
-- reg("ShopPage", shopPage)

-- local shopScroll = scrollFrame(shopPage)
-- pad(14, shopScroll)
-- listV(12, shopScroll)

-- make("TextLabel", {
-- 	Text           = "The Shop",
-- 	TextSize       = 20,
-- 	TextColor3     = C.text,
-- 	Font           = Enum.Font.GothamBold,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, 0, 0, 30),
-- }, shopScroll)
-- make("TextLabel", {
-- 	Text           = "Tools that sharpen your craft.",
-- 	TextSize       = 13,
-- 	TextColor3     = C.sub,
-- 	Font           = Enum.Font.Gotham,
-- 	BackgroundTransparency = 1,
-- 	Size           = UDim2.new(1, 0, 0, 20),
-- }, shopScroll)

-- -- ── Data: Job board ───────────────────────────────────────────────────────

-- local _jobsLoaded = false

-- local function buildJobCard(job, acceptRE)
-- 	local tierCol = TIER_COLOR[job.tier]
-- 	local STRIPE  = 5

-- 	local card = make("Frame", {
-- 		Size             = UDim2.new(1, 0, 0, 92),
-- 		BackgroundColor3 = C.card,
-- 		BorderSizePixel  = 0,
-- 	}, jobScroll)
-- 	corner(10, card)

-- 	if tierCol then
-- 		local stripe = make("Frame", {
-- 			Size             = UDim2.new(0, STRIPE, 1, 0),
-- 			BackgroundColor3 = tierCol,
-- 			BorderSizePixel  = 0,
-- 		}, card)
-- 		corner(4, stripe)
-- 		-- square off right corners of stripe
-- 		make("Frame", {
-- 			Size             = UDim2.new(0.5, 0, 1, 0),
-- 			Position         = UDim2.new(0.5, 0, 0, 0),
-- 			BackgroundColor3 = tierCol,
-- 			BorderSizePixel  = 0,
-- 		}, stripe)
-- 	end

-- 	local ix = 14 + (tierCol and STRIPE + 2 or 0)

-- 	-- Tier badge
-- 	if tierCol then
-- 		local badge = make("TextLabel", {
-- 			Text           = job.tier and job.tier:upper() or "",
-- 			TextSize       = 10,
-- 			TextColor3     = tierCol,
-- 			Font           = Enum.Font.GothamBold,
-- 			BackgroundColor3 = C.surface,
-- 			BackgroundTransparency = 0,
-- 			Size           = UDim2.new(0, 72, 0, 18),
-- 			Position       = UDim2.new(1, -82, 0, 9),
-- 			TextXAlignment = Enum.TextXAlignment.Center,
-- 		}, card)
-- 		corner(4, badge)
-- 	end

-- 	-- Name
-- 	make("TextLabel", {
-- 		Text           = job.name or "Unknown",
-- 		TextSize       = 15,
-- 		TextColor3     = C.text,
-- 		Font           = Enum.Font.GothamBold,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(0.68, -ix, 0, 22),
-- 		Position       = UDim2.new(0, ix, 0, 10),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 		TextTruncate   = Enum.TextTruncate.AtEnd,
-- 	}, card)

-- 	-- Details
-- 	make("TextLabel", {
-- 		Text           = job.details or "",
-- 		TextSize       = 12,
-- 		TextColor3     = C.sub,
-- 		Font           = Enum.Font.Gotham,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(0.76, -ix, 0, 18),
-- 		Position       = UDim2.new(0, ix, 0, 34),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 		TextTruncate   = Enum.TextTruncate.AtEnd,
-- 	}, card)

-- 	-- Pay
-- 	make("TextLabel", {
-- 		Text           = "$" .. tostring(job.pay or 0),
-- 		TextSize       = 14,
-- 		TextColor3     = C.green,
-- 		Font           = Enum.Font.GothamBold,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(0, 80, 0, 20),
-- 		Position       = UDim2.new(0, ix, 0, 60),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, card)

-- 	-- Followers
-- 	make("TextLabel", {
-- 		Text           = tostring(job.followers or 0) .. " followers",
-- 		TextSize       = 12,
-- 		TextColor3     = C.accent,
-- 		Font           = Enum.Font.Gotham,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(0, 120, 0, 20),
-- 		Position       = UDim2.new(0, ix + 88, 0, 62),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, card)

-- 	-- Accept button
-- 	local acceptBtn = make("TextButton", {
-- 		Text             = "Accept",
-- 		TextSize         = 14,
-- 		TextColor3       = Color3.new(1,1,1),
-- 		Font             = Enum.Font.GothamBold,
-- 		BackgroundColor3 = C.green,
-- 		Size             = UDim2.new(0, 88, 0, 34),
-- 		Position         = UDim2.new(1, -100, 0.5, -17),
-- 		AutoButtonColor  = false,
-- 	}, card)
-- 	corner(8, acceptBtn)

-- 	if acceptRE then
-- 		local jobId = job.id
-- 		acceptBtn.Activated:Connect(function()
-- 			acceptRE:FireServer(jobId)
-- 			gui.Enabled = false
-- 		end)
-- 	end

-- 	return card
-- end

-- local function populateJobs()
-- 	if _jobsLoaded then return end
-- 	_jobsLoaded = true
-- 	clearKids(jobScroll)

-- 	local rf = R("RequestJobs")
-- 	if not rf then return end
-- 	local jobs = rf:InvokeServer()
-- 	if type(jobs) ~= "table" then return end

-- 	local acceptRE = R("AcceptJob")
-- 	for _, job in ipairs(jobs) do
-- 		buildJobCard(job, acceptRE)
-- 	end
-- end

-- jobRefreshBtn.Activated:Connect(function()
-- 	_jobsLoaded = false
-- 	populateJobs()
-- end)

-- -- ── Data: Talkogram feed ──────────────────────────────────────────────────

-- local _feedLoaded = false
-- local _feedMode   = "global"
-- local loadPost    -- forward decl

-- local function buildPostCard(post)
-- 	local card = make("TextButton", {
-- 		Size             = UDim2.new(1, 0, 0, 74),
-- 		BackgroundColor3 = C.card,
-- 		Text             = "",
-- 		AutoButtonColor  = false,
-- 	}, feedScroll)
-- 	corner(8, card)

-- 	make("TextLabel", {
-- 		Text           = post.title or "",
-- 		TextSize       = 14,
-- 		TextColor3     = C.text,
-- 		Font           = Enum.Font.GothamBold,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, -20, 0, 22),
-- 		Position       = UDim2.new(0, 14, 0, 12),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 		TextTruncate   = Enum.TextTruncate.AtEnd,
-- 	}, card)
-- 	make("TextLabel", {
-- 		Text           = "by " .. (post.author or "?"),
-- 		TextSize       = 12,
-- 		TextColor3     = C.sub,
-- 		Font           = Enum.Font.Gotham,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, -20, 0, 18),
-- 		Position       = UDim2.new(0, 14, 0, 34),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, card)
-- 	make("TextLabel", {
-- 		Text           = "♥ " .. tostring(post.likes or 0)
-- 			.. "   💬 " .. tostring(#(post.comments or {})),
-- 		TextSize       = 11,
-- 		TextColor3     = C.sub,
-- 		Font           = Enum.Font.Gotham,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, -20, 0, 16),
-- 		Position       = UDim2.new(0, 14, 0, 53),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, card)

-- 	return card
-- end

-- local function populateFeed()
-- 	if _feedLoaded then return end
-- 	_feedLoaded = true

-- 	btnGlobal.BackgroundColor3 = (_feedMode == "global") and C.accent or C.card
-- 	btnServer.BackgroundColor3 = (_feedMode == "server") and C.accent or C.card

-- 	clearKids(feedScroll)

-- 	local rf = R("RequestFeed")
-- 	if not rf then return end
-- 	local posts = rf:InvokeServer(_feedMode)
-- 	if type(posts) ~= "table" then return end

-- 	for _, post in ipairs(posts) do
-- 		local card = buildPostCard(post)
-- 		local postId = post.id
-- 		card.Activated:Connect(function() loadPost(postId) end)
-- 	end
-- end

-- local function buildCommentRow(author, text, parent)
-- 	local row = make("Frame", {
-- 		Size             = UDim2.new(1, 0, 0, 50),
-- 		BackgroundColor3 = C.card,
-- 		BorderSizePixel  = 0,
-- 	}, parent)
-- 	corner(6, row)
-- 	make("TextLabel", {
-- 		Text           = author or "",
-- 		TextSize       = 12,
-- 		TextColor3     = C.accent,
-- 		Font           = Enum.Font.GothamBold,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, -18, 0, 18),
-- 		Position       = UDim2.new(0, 10, 0, 6),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 	}, row)
-- 	make("TextLabel", {
-- 		Text           = text or "",
-- 		TextSize       = 12,
-- 		TextColor3     = C.text,
-- 		Font           = Enum.Font.Gotham,
-- 		BackgroundTransparency = 1,
-- 		Size           = UDim2.new(1, -18, 0, 18),
-- 		Position       = UDim2.new(0, 10, 0, 26),
-- 		TextXAlignment = Enum.TextXAlignment.Left,
-- 		TextWrapped    = true,
-- 	}, row)
-- 	return row
-- end

-- loadPost = function(postId)
-- 	local rf = R("RequestPost")
-- 	if not rf then return end
-- 	local post = rf:InvokeServer(postId)
-- 	if not post then return end

-- 	postTitleLbl.Text  = post.title or ""
-- 	postAuthorLbl.Text = "by " .. (post.author or "?")
-- 	addrBar.Text       = "talkogram://post"

-- 	clearKids(commentsScroll)
-- 	for _, c in ipairs(post.comments or {}) do
-- 		buildCommentRow(c.author, c.text, commentsScroll)
-- 	end

-- 	if sendBtn:GetAttribute("wired") ~= tostring(postId) then
-- 		sendBtn:SetAttribute("wired", tostring(postId))
-- 		sendBtn.Activated:Connect(function()
-- 			local text = commentBox.Text
-- 			if text == "" or text == commentBox.PlaceholderText then return end
-- 			local postRE = R("PostComment")
-- 			if postRE then
-- 				postRE:FireServer(postId, text)
-- 				commentBox.Text = ""
-- 				buildCommentRow(player.Name, text, commentsScroll)
-- 			end
-- 		end)
-- 	end

-- 	show("TalkogramPost")
-- end

-- -- ── Data: Shop ────────────────────────────────────────────────────────────

-- local SHOP_ITEMS = {
-- 	{ name = "CurvedNeedle", displayName = "Curved Needle",   price = 500, description = "+20% stitch tolerance" },
-- 	{ name = "FoamPressKit", displayName = "Foam Press Kit",  price = 750, description = "+20% foam snap range"  },
-- 	{ name = "PowerStapler", displayName = "Power Stapler",   price = 400, description = "Wider staple zone"     },
-- 	{ name = "TackPuller",   displayName = "Pro Tack Puller", price = 350, description = "More approach time"    },
-- }

-- local _shopBuilt = false

-- local function populateShop()
-- 	if _shopBuilt then return end
-- 	_shopBuilt = true

-- 	local rf    = R("RequestInventory")
-- 	local owned = rf and rf:InvokeServer() or {}
-- 	local ownedSet = {}
-- 	for _, n in ipairs(owned) do ownedSet[n] = true end

-- 	local purchaseRE = R("PurchaseTool")

-- 	for _, item in ipairs(SHOP_ITEMS) do
-- 		local row = make("Frame", {
-- 			Size             = UDim2.new(1, 0, 0, 72),
-- 			BackgroundColor3 = C.card,
-- 			BorderSizePixel  = 0,
-- 		}, shopScroll)
-- 		corner(10, row)

-- 		make("TextLabel", {
-- 			Text           = item.displayName,
-- 			TextSize       = 15,
-- 			TextColor3     = C.text,
-- 			Font           = Enum.Font.GothamBold,
-- 			BackgroundTransparency = 1,
-- 			Size           = UDim2.new(0.62, -14, 0, 22),
-- 			Position       = UDim2.new(0, 14, 0, 12),
-- 			TextXAlignment = Enum.TextXAlignment.Left,
-- 		}, row)
-- 		make("TextLabel", {
-- 			Text           = item.description,
-- 			TextSize       = 12,
-- 			TextColor3     = C.sub,
-- 			Font           = Enum.Font.Gotham,
-- 			BackgroundTransparency = 1,
-- 			Size           = UDim2.new(0.62, -14, 0, 18),
-- 			Position       = UDim2.new(0, 14, 0, 36),
-- 			TextXAlignment = Enum.TextXAlignment.Left,
-- 		}, row)

-- 		if ownedSet[item.name] then
-- 			make("TextLabel", {
-- 				Text           = "✓ Owned",
-- 				TextSize       = 13,
-- 				TextColor3     = C.green,
-- 				Font           = Enum.Font.GothamBold,
-- 				BackgroundTransparency = 1,
-- 				Size           = UDim2.new(0, 90, 0, 36),
-- 				Position       = UDim2.new(1, -104, 0.5, -18),
-- 				TextXAlignment = Enum.TextXAlignment.Center,
-- 			}, row)
-- 		else
-- 			local buyBtn = make("TextButton", {
-- 				Text             = "$" .. tostring(item.price),
-- 				TextSize         = 14,
-- 				TextColor3       = Color3.new(1, 1, 1),
-- 				Font             = Enum.Font.GothamBold,
-- 				BackgroundColor3 = C.accent,
-- 				Size             = UDim2.new(0, 90, 0, 36),
-- 				Position         = UDim2.new(1, -104, 0.5, -18),
-- 				AutoButtonColor  = false,
-- 			}, row)
-- 			corner(8, buyBtn)
-- 			if purchaseRE then
-- 				local toolName = item.name
-- 				buyBtn.Activated:Connect(function()
-- 					purchaseRE:FireServer(toolName)
-- 					buyBtn.Text             = "✓ Bought!"
-- 					buyBtn.BackgroundColor3 = C.green
-- 				end)
-- 			end
-- 		end
-- 	end
-- end

-- -- ── Navigation ────────────────────────────────────────────────────────────

-- local _history = {}

-- local function navigate(name, addr)
-- 	table.insert(_history, name)
-- 	addrBar.Text = addr or ("browsah://" .. name:lower())
-- 	show(name)
-- 	if name == "TalkogramFeed"  then populateFeed() end
-- 	if name == "MoneyMakerPage" then populateJobs() end
-- 	if name == "ShopPage"       then populateShop() end
-- end

-- navBack.Activated:Connect(function()
-- 	if #_history > 1 then
-- 		table.remove(_history)
-- 		local prev = _history[#_history]
-- 		show(prev)
-- 		addrBar.Text = "browsah://" .. prev:lower()
-- 	else
-- 		navBar.Visible = false
-- 		show("OSScreen")
-- 	end
-- end)

-- navHome.Activated:Connect(function()
-- 	_history = {"BrowsahHome"}
-- 	addrBar.Text = "browsah://home"
-- 	show("BrowsahHome")
-- end)

-- -- OS screen
-- iconBrowsah.Activated:Connect(function()
-- 	navBar.Visible = true
-- 	_history = {"BrowsahHome"}
-- 	addrBar.Text = "browsah://home"
-- 	show("BrowsahHome")
-- end)

-- -- Bookmarks
-- bmTalkogram.Activated:Connect(function()
-- 	_feedLoaded = false
-- 	navigate("TalkogramFeed", "talkogram://feed")
-- end)
-- bmMoneyMaker.Activated:Connect(function()
-- 	_jobsLoaded = false
-- 	navigate("MoneyMakerPage", "moneymaker://jobs")
-- end)
-- bmShop.Activated:Connect(function()
-- 	navigate("ShopPage", "browsah://shop")
-- end)

-- -- Feed filters
-- btnGlobal.Activated:Connect(function()
-- 	_feedMode = "global"; _feedLoaded = false; populateFeed()
-- end)
-- btnServer.Activated:Connect(function()
-- 	_feedMode = "server"; _feedLoaded = false; populateFeed()
-- end)

-- -- Auto-refresh job board when server regenerates the pool
-- local jobBoardRefreshRE = R("JobBoardRefresh")
-- if jobBoardRefreshRE then
-- 	jobBoardRefreshRE.OnClientEvent:Connect(function()
-- 		_jobsLoaded = false
-- 		if jobPage.Visible then populateJobs() end
-- 	end)
-- end

-- -- ── Boot sequence ─────────────────────────────────────────────────────────

-- local function playBoot()
-- 	navBar.Visible = false
-- 	show("LoadingScreen")

-- 	loadSub.Text = '"' .. QUOTES[math.random(#QUOTES)] .. '"'
-- 	barFill.Size = UDim2.fromScale(0, 1)
-- 	TweenService:Create(
-- 		barFill,
-- 		TweenInfo.new(2.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
-- 		{ Size = UDim2.fromScale(1, 1) }
-- 	):Play()

-- 	task.wait(2.2)
-- 	if not gui.Enabled then return end

-- 	osQuote.Text = '"' .. QUOTES[math.random(#QUOTES)] .. '"'
-- 	show("OSScreen")
-- end

-- -- ── Entry point ───────────────────────────────────────────────────────────

-- backdrop.Activated:Connect(function() gui.Enabled = false end)

-- local openedEvent = PlayerGui:WaitForChild("LaptopOpened", 10)
-- if openedEvent then
-- 	openedEvent.Event:Connect(function()
-- 		_jobsLoaded = false
-- 		_feedLoaded = false
-- 		_shopBuilt  = false
-- 		_feedMode   = "global"
-- 		_history    = {}

-- 		gui.Enabled = true
-- 		playBoot()
-- 	end)
-- end
