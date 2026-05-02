local players = game:GetService("Players")

players.PlayerAdded:Connect(function(player)
	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"
	playerData.Parent = player
	
	local cash = Instance.new("IntValue")
	cash.Name = "usd"
	cash.Value = 0
	cash.Parent = playerData
end)