--[[
	Talkogram_Tab.client.luau
	Populates the Talkogram feed inside the laptop.
	All GUI instances are pre-built in Studio — this script only wires them up.

	Expected tree:
	  LaptopGui → LaptopScreen → Apps → Talkogram_Tab
	    ├── Frame "Header"
	    ├── ScrollingFrame "FeedScroll"
	    │     ├── TextLabel "EmptyLabel"
	    │     └── TextButton "PostCardTemplate"  (Visible = false)
	    │           ├── Frame "AuthorRow"
	    │           │     ├── Frame "Dot" → TextLabel "Initial"
	    │           │     └── TextLabel "AuthorName"
	    │           ├── TextLabel "Caption"
	    │           ├── Frame "VpWrap" → ViewportFrame "Vp"
	    │           └── TextLabel "CommentHint"
	    └── TextButton "Modal"  (Visible = false)
	          └── TextButton "ModalCard"
	                ├── ViewportFrame "VpDamaged"
	                ├── ViewportFrame "VpFixed"
	                ├── TextButton "PrevBtn"
	                ├── TextButton "NextBtn"
	                ├── TextLabel "SlideLabel"
	                ├── Frame "VpDivider"
	                └── Frame "RightPanel"
	                      ├── TextButton "ModalClose"
	                      ├── TextLabel "Caption"
	                      ├── TextLabel "AuthorLabel"
	                      ├── Frame "Divider"
	                      ├── TextLabel "CommentsHeading"
	                      └── ScrollingFrame "CommentScroll"
	                            └── Frame "CommentTemplate"  (Visible = false)
	                                  ├── Frame "Dot" → TextLabel "Initial"
	                                  └── Frame "TextBlock"
	                                        ├── TextLabel "Username"
	                                        └── TextLabel "CommentText"
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── Pre-built GUI references ───────────────────────────────────────────────

local tab = playerGui
	:WaitForChild("LaptopGui")
	:WaitForChild("LaptopScreen")
	:WaitForChild("Apps")
	:WaitForChild("Talkogram_Tab")

local feedScroll      = tab:WaitForChild("FeedScroll")
local cardTemplate    = feedScroll:WaitForChild("PostCardTemplate")
local emptyLabel      = feedScroll:WaitForChild("EmptyLabel")

feedScroll.CanvasSize          = UDim2.fromOffset(0, 0)
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local modal           = tab:WaitForChild("Modal")
local modalCard       = modal:WaitForChild("ModalCard")
local modalVpA        = modalCard:WaitForChild("VpDamaged")
local modalVpB        = modalCard:WaitForChild("VpFixed")
local prevBtn         = modalCard:WaitForChild("PrevBtn")
local nextBtn         = modalCard:WaitForChild("NextBtn")
local slideLabel      = modalCard:WaitForChild("SlideLabel")

local rightPanel      = modalCard:WaitForChild("RightPanel")
local modalClose      = rightPanel:WaitForChild("ModalClose")
local modalCaption    = rightPanel:WaitForChild("Caption")
local modalAuthor     = rightPanel:WaitForChild("AuthorLabel")
local commentScroll   = rightPanel:WaitForChild("CommentScroll")
local commentTemplate = commentScroll:WaitForChild("CommentTemplate")

-- ── Remotes ────────────────────────────────────────────────────────────────

local Remotes          = ReplicatedStorage:WaitForChild("LaptopRemotes")
local RequestFeed      = Remotes:WaitForChild("RequestFeed")
local TalkogramPost    = Remotes:WaitForChild("TalkogramPost")
local FurnitureDisplay = ReplicatedStorage:FindFirstChild("FurnitureDisplay")

-- ── Post type accent colours ───────────────────────────────────────────────

local TYPE_COLOR = {
	success = Color3.fromRGB(70,  200, 130),
	fail    = Color3.fromRGB(225, 70,  70),
	abandon = Color3.fromRGB(225, 145, 45),
}

-- ── Viewport helpers ────────────────────────────────────────────────────────

local _modalCleanups = {}

local function makeViewport(vp, furniKey, phaseName, allowDrag)
	if not FurnitureDisplay then return nil end
	local typeFolder = FurnitureDisplay:FindFirstChild(furniKey)
	if not typeFolder then return nil end

	local modelName
	if phaseName == "fixed" then
		modelName = "Default"
	else
		for _, n in ipairs({ "Damaged_A", "Damaged_B", "Damaged_C" }) do
			if typeFolder:FindFirstChild(n) then modelName = n; break end
		end
	end
	if not modelName then return nil end
	local src = typeFolder:FindFirstChild(modelName)
	if not src then return nil end

	local wm    = Instance.new("WorldModel")
	wm.Parent   = vp
	local clone = src:Clone()
	clone.Parent = wm

	local cf, sz = clone:GetBoundingBox()
	local pivot  = cf.Position
	local dist   = math.max(sz.X, sz.Y, sz.Z) * 1.9

	local cam        = Instance.new("Camera")
	cam.FieldOfView  = 52
	cam.Parent       = vp
	vp.CurrentCamera = cam

	local yaw     = -35
	local pitch   = 22
	local spinning = true

	local function updateCam()
		local yr  = math.rad(yaw)
		local pr  = math.rad(pitch)
		local off = Vector3.new(
			math.cos(pr) * math.sin(yr),
			math.sin(pr),
			math.cos(pr) * math.cos(yr)
		) * dist
		cam.CFrame = CFrame.lookAt(pivot + off, pivot)
	end
	updateCam()

	local spinConn = RunService.RenderStepped:Connect(function(dt)
		if spinning then yaw = yaw + dt * 28; updateCam() end
	end)

	local c1, c2, c3
	if allowDrag then
		local lastPos = Vector2.zero
		c1 = vp.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
				spinning = false
				lastPos  = Vector2.new(inp.Position.X, inp.Position.Y)
			end
		end)
		c2 = vp.InputChanged:Connect(function(inp)
			if not spinning
			and (inp.UserInputType == Enum.UserInputType.MouseMovement
			  or inp.UserInputType == Enum.UserInputType.Touch) then
				local pos = Vector2.new(inp.Position.X, inp.Position.Y)
				yaw     = yaw + (pos.X - lastPos.X) * 0.55
				lastPos = pos
				updateCam()
			end
		end)
		c3 = vp.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
				spinning = true
			end
		end)
	end

	return function()
		spinConn:Disconnect()
		if c1 then c1:Disconnect() end
		if c2 then c2:Disconnect() end
		if c3 then c3:Disconnect() end
		if wm and wm.Parent then wm:Destroy() end
	end
end

-- ── Modal helpers ───────────────────────────────────────────────────────────

local function clearModal()
	for _, fn in ipairs(_modalCleanups) do pcall(fn) end
	_modalCleanups = {}
	modalVpA:ClearAllChildren()
	modalVpB:ClearAllChildren()
	for _, c in ipairs(commentScroll:GetChildren()) do
		if c ~= commentTemplate
		and not c:IsA("UIListLayout")
		and not c:IsA("UIPadding") then
			c:Destroy()
		end
	end
end

local function setSlide(n)
	local onA        = (n == 1)
	modalVpA.Visible = onA
	modalVpB.Visible = not onA
	slideLabel.Text  = onA and "● ○" or "○ ●"
	prevBtn.Visible  = not onA
	nextBtn.Visible  = onA
end

-- ── Comment row builder ─────────────────────────────────────────────────────

local function addCommentRow(comment, order, typeColor)
	local row       = commentTemplate:Clone()
	row.Visible     = true
	row.LayoutOrder = order
	row.Parent      = commentScroll

	local dot = row:WaitForChild("Dot")
	dot.BackgroundColor3 = typeColor or Color3.fromRGB(155, 110, 235)
	dot:WaitForChild("Initial").Text = (comment.username or "?"):sub(1, 1):upper()

	local tb = row:WaitForChild("TextBlock")
	tb:WaitForChild("Username").Text    = comment.username or "?"
	tb:WaitForChild("CommentText").Text = comment.text     or ""
end

-- ── Open / close modal ──────────────────────────────────────────────────────

local function openPostModal(post)
	clearModal()
	local typeColor = TYPE_COLOR[post.postType] or TYPE_COLOR.success

	modalCaption.Text = post.caption   or ""
	modalAuthor.Text  = "by " .. (post.authorName or "?")

	for i, comment in ipairs(post.comments or {}) do
		addCommentRow(comment, i, typeColor)
	end

	if post.furnitureKey and FurnitureDisplay then
		local cleanA = makeViewport(modalVpA, post.furnitureKey, "damaged", true)
		local cleanB = makeViewport(modalVpB, post.furnitureKey, "fixed",   true)
		_modalCleanups = { cleanA, cleanB }
		nextBtn.Visible = (cleanB ~= nil)
	else
		nextBtn.Visible = false
	end
	prevBtn.Visible = false
	setSlide(1)

	modal.Visible = true
end

local function closeModal()
	modal.Visible = false
	clearModal()
end

modalClose.Activated:Connect(closeModal)
modal.Activated:Connect(closeModal)
prevBtn.Activated:Connect(function() setSlide(1) end)
nextBtn.Activated:Connect(function() setSlide(2) end)

-- ── Card builder (clones PostCardTemplate) ──────────────────────────────────

local _liveOrder   = 0
local _cardCleanup = {}

local function buildCard(post, layoutOrder)
	local typeColor = TYPE_COLOR[post.postType] or TYPE_COLOR.success

	local card       = cardTemplate:Clone()
	card.Visible     = true
	card.LayoutOrder = layoutOrder
	card.Name        = "PostCard_" .. tostring(post.id)
	card.Parent      = feedScroll

	local authorRow = card:WaitForChild("AuthorRow")
	local dot       = authorRow:WaitForChild("Dot")
	dot.BackgroundColor3              = typeColor
	dot:WaitForChild("Initial").Text  = (post.authorName or "?"):sub(1, 1):upper()
	authorRow:WaitForChild("AuthorName").Text = post.authorName or "?"

	card:WaitForChild("Caption").Text = post.caption or ""

	local vpWrap  = card:WaitForChild("VpWrap")
	local vpClean = nil
	if post.furnitureKey and FurnitureDisplay then
		vpWrap.Visible = true
		vpClean = makeViewport(vpWrap:WaitForChild("Vp"), post.furnitureKey, "damaged", false)
	else
		vpWrap.Visible = false
	end

	local commentHint  = card:WaitForChild("CommentHint")
	local commentCount = #(post.comments or {})
	if commentCount > 0 then
		commentHint.Visible = true
		commentHint.Text    = "💬 " .. commentCount .. " comment" .. (commentCount == 1 and "" or "s")
	else
		commentHint.Visible = false
	end

	card.Activated:Connect(function() openPostModal(post) end)

	if vpClean then _cardCleanup[card] = vpClean end
	emptyLabel.Visible = false
end

-- ── Feed management ─────────────────────────────────────────────────────────

local function clearFeed()
	for card, fn in pairs(_cardCleanup) do
		pcall(fn)
		if card and card.Parent then card:Destroy() end
	end
	_cardCleanup = {}
	for _, child in ipairs(feedScroll:GetChildren()) do
		if child ~= cardTemplate
		and child ~= emptyLabel
		and not child:IsA("UIListLayout")
		and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
	emptyLabel.Visible = true
	_liveOrder = 0
end

local function loadFeed()
	clearFeed()
	local ok, posts = pcall(function() return RequestFeed:InvokeServer() end)
	if not ok or not posts then return end
	for i, post in ipairs(posts) do
		buildCard(post, i)
	end
end

-- ── Refresh when the tab becomes visible ────────────────────────────────────

tab:GetPropertyChangedSignal("Visible"):Connect(function()
	if tab.Visible then loadFeed() end
end)

if tab.Visible then loadFeed() end

-- ── Live post stream ────────────────────────────────────────────────────────

TalkogramPost.OnClientEvent:Connect(function(post)
	if tab.Visible then
		_liveOrder = _liveOrder - 1
		buildCard(post, _liveOrder)
		feedScroll.CanvasPosition = Vector2.zero
	end
end)
