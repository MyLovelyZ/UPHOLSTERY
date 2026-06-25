--[[
	TalkogramData
	Procedural text generation for the Talkogram social feed.
	All username, caption, and comment content lives here.
	Uses {name} / {item} placeholders instead of string.format to avoid
	issues with special characters in player names.
]]

local TalkogramData = {}

local function pickRandom(t)
	return t[math.random(#t)]
end

local function fill(text, playerName, itemName)
	return (text:gsub("{name}", playerName or "them"):gsub("{item}", itemName or "it"))
end

-- ── Username generation ────────────────────────────────────────────────────

local ADJ = {
	"fluffy", "cozy", "velvet", "crafty", "silky", "snug", "plush",
	"retro", "boho", "chic", "vintage", "rustic", "sleek", "comfy",
	"dainty", "fancy", "glam", "homey", "dreamy", "indie", "artsy",
	"bumble", "fuzzy", "dusty", "crunchy", "cottagecore", "aesthetic",
	"sewing", "stitch", "thread", "fabric", "needle", "tacky", "foamy",
}

local NOUN = {
	"couch", "sofa", "cushion", "chair", "stool", "loveseat", "ottoman",
	"fabric", "needle", "tack", "queen", "king", "lord", "lady", "mom",
	"dad", "nan", "girlie", "baddie", "icon", "legend", "goddess",
	"stan", "fan", "lover", "addict", "enjoyer", "haver", "bestie",
}

local SEP = { "_", ".", "" }

local TYPO_SUBS = {
	e = { "3", "ee" },
	a = { "@", "4", "aa" },
	o = { "0", "oo" },
	i = { "1", "ii" },
	s = { "$", "ss" },
	t = { "7" },
}

local function applyTypo(str)
	local roll = math.random(4)
	if roll == 1 then
		for char, subs in pairs(TYPO_SUBS) do
			local pos = str:find(char)
			if pos then
				return str:sub(1, pos - 1) .. pickRandom(subs) .. str:sub(pos + 1)
			end
		end
	elseif roll == 2 then
		for _, v in ipairs({ "a", "e", "i", "o", "u" }) do
			local pos = str:find(v, 2)
			if pos then return str:sub(1, pos - 1) .. str:sub(pos + 1) end
		end
	elseif roll == 3 and #str >= 4 then
		local pos = math.random(2, #str - 1)
		local c = str:sub(pos, pos)
		if not c:match("[aeiou]") then
			return str:sub(1, pos) .. c .. str:sub(pos + 1)
		end
	end
	return str
end

function TalkogramData.GenerateUsername()
	local name = pickRandom(ADJ) .. pickRandom(SEP) .. pickRandom(NOUN)
	if math.random() < 0.55 then name = name .. tostring(math.random(1, 999)) end
	if math.random() < 0.28 then name = applyTypo(name) end
	return name
end

-- ── Furniture display names ────────────────────────────────────────────────

local FURNITURE_NAMES = {
	TwoSofa     = "sofa",
	ThreeSofa   = "three-seater",
	DinerSofa   = "diner sofa",
	DinerStool  = "diner stool",
	Ottoman     = "ottoman",
	DiningChair = "dining chair",
}

function TalkogramData.GetFurnitureName(key)
	if not key then return "furniture" end
	return FURNITURE_NAMES[key] or key:lower():gsub("(%u)", " %1"):gsub("^%s+", "")
end

-- ── Captions ──────────────────────────────────────────────────────────────

local CAPS_SUCCESS = {
	Perfect = {
		"absolutely nailed this {item} 🔥",
		"client cried happy tears over this {item} 😭",
		"not to brag but this {item} is immaculate",
		"ok i'm genuinely proud of this {item}",
		"this {item} came out better than i imagined",
		"peak craftsmanship right here. the {item} is DONE",
		"another day another perfect {item}",
	},
	Good = {
		"pretty happy with how this {item} turned out",
		"another {item} done and i'm pleased 💪",
		"this {item} took some work but we got there",
		"solid result on the {item}. client was happy",
		"the {item} is looking good if i say so myself",
	},
	Pass = {
		"got the job done on this {item}",
		"the {item} is finished... it's a pass from me",
		"this {item} isn't perfect but it's done",
		"client got their {item} back. job's a job",
		"done is done. the {item} is fixed",
	},
}

local CAPS_FAIL = {
	"hired {name} to fix my {item} and THIS is what i got 💀",
	"DO NOT hire {name}. completely ruined my {item}",
	"so {name} came over to fix my {item} and i'm actually upset",
	"update: {name} destroyed my {item} and i want a refund",
	"warning ⚠️ {name} just botched my {item}",
	"posting this so nobody makes the mistake of hiring {name} for their {item}",
	"{name} literally left my {item} worse than before",
	"idk how {name} stays in business after what they did to my {item}",
}

local CAPS_ABANDON = {
	"{name} just LEFT my {item} half done and walked out 😭",
	"can someone explain why {name} abandoned my {item} mid-job",
	"{name} took one look at my {item} and DIPPED",
	"so {name} just... left?? my {item} is still broken 💀",
	"{name} ghosted my {item} mid-repair and i'm not ok",
}

function TalkogramData.GenerateCaption(postType, result, furniKey, playerName)
	local fname = TalkogramData.GetFurnitureName(furniKey)
	if postType == "success" then
		local pool = CAPS_SUCCESS[result] or CAPS_SUCCESS.Pass
		return fill(pickRandom(pool), playerName, fname)
	elseif postType == "fail" then
		return fill(pickRandom(CAPS_FAIL), playerName, fname)
	elseif postType == "abandon" then
		return fill(pickRandom(CAPS_ABANDON), playerName, fname)
	end
	return fname
end

-- ── Comment pools ──────────────────────────────────────────────────────────

local TIER_TO_GROUP = {
	Starter   = "Casual",
	Mid       = "Casual",
	Premium   = "Upscale",
	Prestige  = "Upscale",
	Exclusive = "Elite",
	Elite     = "Elite",
	Special   = "Elite",
}

local SUCCESS_GENERIC = {
	Casual = {
		Perfect = {
			"omg the fabric choice 😍",
			"this is so satisfying",
			"my living room needs this rn",
			"the color matching is insane",
			"ok i need your number",
			"this gave me chills ngl",
			"how are you so talented",
			"im obsessed",
			"stunning 😭",
			"the transformation!!",
			"i would never leave the house if my couch looked like this",
			"interior design goals right here",
			"the fit is PERFECT",
			"ok i'm crying this is so good",
			"genuinely impressive work",
			"the colors 😭😭",
			"i didn't know i needed this",
			"ok WHAT",
		},
		Good = {
			"solid work honestly",
			"yeah that came out really nice",
			"respectable result tbh",
			"not bad at all ngl",
			"pretty decent outcome",
			"looks good to me",
			"clean result for real",
			"can't complain with this",
			"the work speaks for itself",
			"good enough to post",
			"genuinely pleased with this",
			"well done actually",
			"love to see it",
			"that turned out well",
		},
		Pass = {
			"well… it's done i guess",
			"could be worse honestly",
			"i mean it works",
			"it's fine i think",
			"done is done i suppose",
			"at least it's finished",
			"not the best but ok",
			"it'll do for now",
			"i've seen worse tbh",
			"gets the job done",
			"it's giving… effort",
			"acceptable i suppose 😬",
			"they finished it at least",
		},
	},
	Upscale = {
		Perfect = {
			"this is genuinely impressive craftsmanship",
			"the attention to detail is remarkable",
			"my interior designer would approve of this",
			"exceeds the brief honestly",
			"you can feel the quality in this work",
			"this belongs in a showroom",
			"restoration at its finest",
			"the client is going to be delighted",
			"the finish is impeccable",
			"this is what proper upholstery looks like",
			"the transformation is extraordinary",
			"beautifully executed from start to finish",
		},
		Good = {
			"a very competent result",
			"solid professional work",
			"well executed overall",
			"exactly what was asked for",
			"professionally done",
			"meets expectations fully",
			"a reliable result",
			"the finish is clean and precise",
			"well handled",
			"a commendable outcome",
			"the standard is solid",
		},
		Pass = {
			"it's acceptable",
			"functional if not exceptional",
			"serves its purpose adequately",
			"the standard was met",
			"passable result",
			"adequate workmanship",
			"it suffices for the space",
			"it's fine for what it is",
		},
	},
	Elite = {
		Perfect = {
			"extraordinary. this is museum-quality work",
			"simply impeccable. the craftsmanship is beyond reproach",
			"quite exceptional — my compliments to the craftsperson",
			"one rarely encounters this level of precision",
			"this is what restoring heritage looks like",
			"the provenance of this piece is honoured by such work",
			"a masterclass in the craft. truly",
			"remarkable. simply remarkable",
		},
		Good = {
			"commendably executed",
			"a refined result",
			"quite satisfactory",
			"the craftsperson has met the standard",
			"appropriate for the piece",
			"professional work of the expected calibre",
			"the work has been done with care",
			"a competent restoration",
		},
		Pass = {
			"adequate, though one expected more",
			"the work is passable",
			"acceptable, if unremarkable",
			"it suffices",
			"functional. nothing more",
			"the standard falls somewhat short of the commission",
		},
	},
}

local SUCCESS_TRADES = {
	"that corner work is CLEAN",
	"the seam is so straight 😭",
	"what fabric is that??",
	"the tack work omg",
	"how long did this take",
	"the foam density looks perfect",
	"you can tell the tension is just right",
	"that piping 👏",
	"the grain direction is spot on",
	"ok the stitching detail 😭",
	"professional work right there",
	"the staple pattern is perfect",
	"the welt is immaculate",
	"the depth of the cushion fill is exactly right",
}

local SUCCESS_NAMEREF = {
	Casual = {
		"can {name} take on more clients?",
		"{name} is genuinely so talented",
		"hiring {name} was the best decision",
		"followed {name} after this masterpiece",
		"{name} never misses fr",
		"we don't deserve {name}",
		"obsessed with {name}'s work",
		"{name} should charge more honestly",
	},
	Upscale = {
		"{name} comes highly recommended",
		"I've passed {name}'s details to my interior designer",
		"following {name} immediately — exceptional work",
		"{name}'s portfolio is impressive",
		"do you know if {name} takes private commissions?",
		"{name} clearly knows their craft well",
		"{name}'s workmanship is above the usual standard",
		"I shall be recommending {name} to my decorator",
	},
	Elite = {
		"one must enquire whether {name} accepts private commissions",
		"{name}'s work reflects considerable expertise",
		"I shall be passing {name}'s details to my decorator",
		"quite the accomplished craftsperson, {name}",
		"{name} demonstrates a rare mastery of the trade",
		"I would not hesitate to commission {name} again",
		"the calibre of {name}'s work is most impressive",
		"{name} would be at home in any fine restoration atelier",
	},
}

local SUCCESS_FURNIREF = {
	Casual = {
		"that {item} looks brand new",
		"never seen a {item} look this good",
		"my {item} looks nothing like this 💀",
		"this {item} could be in a magazine",
		"what a {item} glow up",
		"that {item} is so fresh",
	},
	Upscale = {
		"the {item} looks catalogue-worthy",
		"this {item} belongs in a styled shoot",
		"the {item} has been elevated considerably",
		"a {item} of this quality deserves such care",
		"the {item} looks freshly delivered from the showroom",
		"the {item} is in better condition than when it was new",
	},
	Elite = {
		"a {item} of this provenance deserved such treatment",
		"the {item} has been beautifully restored to its former distinction",
		"this {item} could grace the finest estates",
		"the {item} is once again worthy of its heritage",
		"one would not guess the {item} had ever needed restoration",
		"the {item} has been treated with appropriate reverence",
	},
}

local COMMENT_POOLS = {
	fail = {
		generic = {
			"oh no 💀",
			"they really did that",
			"i would be so upset",
			"this is literally criminal",
			"the audacity",
			"😭😭😭",
			"ok but why",
			"what happened here",
			"i am speechless",
			"no actually what is that",
			"who let them near your sofa",
			"they said they were a professional???",
			"you should sue",
			"i can't look away",
			"this is devastating",
			"the disrespect",
		},
		nameref = {
			"stay AWAY from {name}",
			"{name} owes you a refund",
			"report {name} immediately",
			"how does {name} still have clients",
			"{name} is COOKED",
			"{name} blocked me after i left a review too",
			"i warned someone about {name} last week",
		},
		furniref = {
			"rip to the {item} 💀",
			"your {item} deserved better",
			"that poor {item} 😭",
			"the {item} said goodbye",
		},
	},
	abandon = {
		generic = {
			"they just walked out???",
			"i would never recover",
			"the unserious behavior",
			"you couldn't pay me to do that",
			"ran and didn't look back",
			"ghosted the furniture",
			"disappeared like they were never there",
			"the NERVE",
		},
		nameref = {
			"block {name} immediately",
			"{name} does not deserve work",
			"{name} would never get near my furniture",
			"{name} is genuinely unserious",
		},
		furniref = {
			"your {item} deserved better than this",
			"that {item} is still waiting 😭",
		},
	},
}

local COUNT_BY_TIER = {
	Starter   = { 2, 4  },
	Mid       = { 4, 6  },
	Premium   = { 5, 8  },
	Prestige  = { 6, 10 },
	Exclusive = { 8, 12 },
	Elite     = { 9, 14 },
	Special   = { 10, 16 },
}

local function applyCommentTypo(str)
	if math.random() > 0.2 or #str < 5 then return str end
	local pos = math.random(2, #str - 1)
	if math.random(2) == 1 then
		return str:sub(1, pos - 1) .. str:sub(pos + 1)
	else
		return str:sub(1, pos) .. str:sub(pos, pos) .. str:sub(pos + 1)
	end
end

function TalkogramData.GenerateComments(postType, playerName, furniKey, tier, result)
	local fname    = TalkogramData.GetFurnitureName(furniKey)
	local counts   = COUNT_BY_TIER[tier] or { 3, 5 }
	local count    = math.random(counts[1], counts[2])
	local pool     = COMMENT_POOLS[postType]
	local used     = {}
	local comments = {}

	local group     = TIER_TO_GROUP[tier] or "Casual"
	local allowTypo = (group ~= "Elite")
	local resKey    = (result == "Perfect" or result == "Good" or result == "Pass")
	                  and result or "Pass"

	for _ = 1, count do
		local roll = math.random(100)
		local candidates

		if postType == "success" then
			if roll <= 18 then
				candidates = SUCCESS_NAMEREF[group] or SUCCESS_NAMEREF.Casual
			elseif roll <= 32 then
				candidates = SUCCESS_FURNIREF[group] or SUCCESS_FURNIREF.Casual
			elseif roll <= 58 then
				candidates = SUCCESS_TRADES
			else
				local genByResult = SUCCESS_GENERIC[group] or SUCCESS_GENERIC.Casual
				candidates = genByResult[resKey] or genByResult.Pass
			end
		else
			if roll <= 18 and pool and pool.nameref then
				candidates = pool.nameref
			elseif roll <= 32 and pool and pool.furniref then
				candidates = pool.furniref
			else
				candidates = pool and pool.generic or COMMENT_POOLS.fail.generic
			end
		end

		local text, attempts = nil, 0
		repeat
			text     = pickRandom(candidates)
			attempts = attempts + 1
		until not used[text] or attempts > 8
		used[text] = true

		text = fill(text, playerName, fname)
		if allowTypo then
			text = applyCommentTypo(text)
		end

		table.insert(comments, {
			username = TalkogramData.GenerateUsername(),
			text     = text,
		})
	end

	return comments
end

return TalkogramData
