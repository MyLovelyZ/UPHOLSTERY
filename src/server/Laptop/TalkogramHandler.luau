--[[
	TalkogramHandler
	Session-scoped Talkogram feed — no DataStore, posts reset each server
	session. Posts are generated on job completion (success, fail, abandon)
	and broadcast to all clients in real-time via TalkogramPost.
	SavePost is called by JobPool with raw job/player facts; this module
	generates captions, NPC comments, and author names.
]]

local TalkogramData = require(script.Parent:WaitForChild("TalkogramData"))

local _sessionPosts  = {}   -- all posts this session, newest-first
local _TalkogramPost = nil  -- RemoteEvent set in Init
local _postCounter   = 0

-- ── SavePost ──────────────────────────────────────────────────────────────
-- data = {
--   playerName   : string
--   postType     : "success" | "fail" | "abandon"
--   result       : "Perfect" | "Good" | "Pass" | "Fail" | "Abandon"
--   furnitureKey : string | nil
--   tier         : string
-- }

local function savePost(data)
	_postCounter = _postCounter + 1

	local postType   = data.postType   or "success"
	local playerName = data.playerName or "unknown"
	local furniKey   = data.furnitureKey
	local tier       = data.tier or "Starter"

	local authorName
	if postType == "success" then
		authorName = playerName
	else
		authorName = TalkogramData.GenerateUsername()
	end

	local caption  = TalkogramData.GenerateCaption(postType, data.result, furniKey, playerName)
	local comments = TalkogramData.GenerateComments(postType, playerName, furniKey, tier, data.result)

	local post = {
		id           = _postCounter,
		authorName   = authorName,
		playerName   = playerName,
		postType     = postType,
		caption      = caption,
		furnitureKey = furniKey,
		tier         = tier,
		result       = data.result,
		comments     = comments,
		timestamp    = os.time(),
	}

	table.insert(_sessionPosts, 1, post)

	if _TalkogramPost then
		_TalkogramPost:FireAllClients(post)
	end

	print(("[Talkogram] New post by %s (%s) — %s"):format(authorName, postType, caption:sub(1, 60)))
end

-- ── Init ──────────────────────────────────────────────────────────────────

local function init(remotes)
	_TalkogramPost = remotes:WaitForChild("TalkogramPost")

	local RequestFeed = remotes:WaitForChild("RequestFeed")
	RequestFeed.OnServerInvoke = function()
		return _sessionPosts
	end

	-- Stub old remotes to suppress handler-not-set warnings
	local RequestPost = remotes:WaitForChild("RequestPost")
	local PostComment = remotes:WaitForChild("PostComment")
	local LikePost    = remotes:WaitForChild("LikePost")

	RequestPost.OnServerInvoke = function() return nil end
	PostComment.OnServerEvent:Connect(function() end)
	LikePost.OnServerEvent:Connect(function() end)
end

return {
	Init     = init,
	SavePost = savePost,
}
