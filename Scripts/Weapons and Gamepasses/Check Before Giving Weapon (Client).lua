--Player
local player = game.Players.LocalPlayer
--Player's leaderstats
local leaderstats = player:WaitForChild("leaderstats")
--Weapon's Name
local weapon = script.Parent:FindFirstChild("Weapon Name").Text
--Level Label --> returns the level value rather than the whole label
local required_level = string.sub(script.Parent:FindFirstChild("Level Label").Text, 7)

--Fires when player pressed the weapon button
script.Parent.MouseButton1Click:Connect(function()
	
	if leaderstats.Level.Value >= tonumber(required_level) and not player.Backpack:FindFirstChild(weapon) and not player.Character:FindFirstChild(weapon) then
		--Plays when the player clicks a button
		game.Workspace:FindFirstChild("Button Clicked!"):Play()
		--Tells the server to give the weapon to the player
		game.ReplicatedStorage:FindFirstChild("Give Weapon"):FireServer(weapon)
	elseif player.Backpack:FindFirstChild(weapon) or player.Character:FindFirstChild(weapon) then
		print("Player already has "..weapon)
	else
		print("Player has not reach Level "..required_level.." yet to obtain "..weapon)
	end
end)

wait(1)

while wait(.1) do
	--Player has reached the requirement level but doesn't have the weapon
	if leaderstats.Level.Value >= tonumber(required_level) and not player.StarterGear:FindFirstChild(weapon) then
		script.Parent:FindFirstChild("Required Label").Text = "Equip It"
	--Player has reached the requirement level and has the weapon
	elseif leaderstats.Level.Value >= tonumber(required_level) and player.StarterGear:FindFirstChild(weapon) then
		script.Parent:FindFirstChild("Required Label").Text = "Equipped"
	end
end