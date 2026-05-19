--[[
    MoneyMaker_Tab.client.luau
    Fetches the shared job pool and renders each job as a cloned JobCard.

    Expected GUI tree — rename your Studio instances to match:
      LaptopGui → LaptopScreen → Apps → MoneyMaker_Tab
        └── JobCard  (Frame, Visible = false — template, never shown directly)
                ├── UIListLayout
                ├── NameLabel      (TextLabel)  ← job.name
                ├── DetailsLabel   (TextLabel)  ← job.details
                ├── TierLabel      (TextLabel)  ← job.tier
                ├── PayLabel       (TextLabel)  ← job.pay
                └── FollowersLabel (TextLabel)  ← job.followers

    If MoneyMaker_Tab also has a UIListLayout, cloned cards will stack
    automatically. Otherwise add one manually in Studio.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MoneyMaker_Tab  = playerGui
    :WaitForChild("LaptopGui")
    :WaitForChild("LaptopScreen")
    :WaitForChild("Apps")
    :WaitForChild("MoneyMaker_Tab")

local scrollFrame     = MoneyMaker_Tab:WaitForChild("JobListScroll")
local jobCardTemplate = scrollFrame:WaitForChild("JobCardTemplate")

local LaptopRemotes   = ReplicatedStorage:WaitForChild("LaptopRemotes")
local RequestJobs     = LaptopRemotes:WaitForChild("RequestJobs")
local AcceptJob       = LaptopRemotes:WaitForChild("AcceptJob")
local JobBoardRefresh = LaptopRemotes:WaitForChild("JobBoardRefresh")

local TIER_COLOR = {
    Starter   = Color3.fromRGB(180, 180, 180),
    Mid       = Color3.fromRGB(100, 200, 100),
    Premium   = Color3.fromRGB(80,  160, 220),
    Prestige  = Color3.fromRGB(160, 80,  220),
    Exclusive = Color3.fromRGB(220, 160, 40),
    Elite     = Color3.fromRGB(220, 60,  60),
    Special   = Color3.fromRGB(220, 120, 220),
}

local function clearCards()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") and child ~= jobCardTemplate then
            child:Destroy()
        end
    end
end

local function populateBoard(jobs)
    clearCards()
    for _, job in ipairs(jobs) do
        local card = jobCardTemplate:Clone()
        card.Name    = "JobCard_" .. job.id
        card.Visible = true

        card:WaitForChild("JobName").Text      = job.name
        card:WaitForChild("JobDetails").Text   = job.details
        -- card:WaitForChild("TierLabel").Text      = job.tier
        card:WaitForChild("PayLabel").Text       = "$" .. tostring(job.pay)
        card:WaitForChild("FollowersLabel").Text = "+" .. tostring(job.followers) .. " followers"

        -- local color = TIER_COLOR[job.tier]
        -- if color then
        --     card:WaitForChild("PrestigeHighlight").TextColor3 = color
        -- end

        -- If JobCard is a TextButton / ImageButton, clicking it accepts the job
        if card:IsA("GuiButton") then
            card.MouseButton1Click:Connect(function()
                AcceptJob:FireServer(job.id)
            end)
        end

        card.Parent = scrollFrame
    end
end

local function refreshBoard()
    local jobs = RequestJobs:InvokeServer()
    if jobs then
        populateBoard(jobs)
    end
end

-- Re-render whenever a job is accepted or the pool replenishes
JobBoardRefresh.OnClientEvent:Connect(refreshBoard)

refreshBoard()
