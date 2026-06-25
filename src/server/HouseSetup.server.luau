-- Ensures PlayerHouseManager is required at game start, independently of the
-- LaptopData → LocationManager → PlayerHouseManager chain.  Without this,
-- PlayerAdded can fire before the chain resolves in Studio solo play, leaving
-- _assignment[player] nil and sending players to (0, 5, 0).
require(script.Parent:WaitForChild("PlayerHouseManager"))
