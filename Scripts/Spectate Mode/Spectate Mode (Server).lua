--[[This script performs APIs in Spectate Mode]]

--Replaces player's Humanoid Scripts with Spectator ones
function ReplaceWithSpectatorScripts(character)
	
	print("ReplaceWithSpectatorScripts Called!")
	
	--Finds player's Animate and Humanoid scripts, and removes them from the player's character
	for _, obj in pairs(character:GetChildren()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") then
			if obj.Name == "Animate" or obj.Name == "Health" then
				obj:Remove()
			end
		end
	end
	
	--PlayerSpectatorScripts Folder
	local SpectatorFolder = game.ReplicatedStorage:FindFirstChild("PlayerSpectatorScripts")
	
	--Adds in Spectator scripts from PlayerSpectatorScripts folder to the player's character
	for _, obj in pairs(SpectatorFolder:GetChildren()) do obj:Clone().Parent = character end 
end

--Removes all player's weapons from the inventory
function RemoveWeaponsFromInventory(player)
	
	--Checks if the object is a food
	local function isFood(obj)
		
		--List of foods
		local foods = {"Bloxiade","Cheeseburger","Pizza","Sandwich","Bloxy Soda","Chicken Leg","Hot Dog","Mountain Dew","Starblox Latte","Taco"}
		
		--Returns true if the object's name matches the food's name
		for _, food in pairs(foods) do
			if obj == food then
				return true
			end
		end
		
		return false
	end
	
	--Gets player's weapon holder
	local WeaponHolder = player:FindFirstChild("Weapon Holder")
	
	--If the player goes on Spectate Mode for the 1st time in the server
	if not WeaponHolder then
		WeaponHolder = Instance.new("Folder", player)
		WeaponHolder.Name = "Weapon Holder"
	end
	
	--Wooden Sword from the player's backpack or character
	local WoodenSword = player.Backpack:FindFirstChild("Wooden Sword") or player.Character:FindFirstChild("Wooden Sword")
	
	--Movs player's wooden sword from the backpack to the Weapon Holder
	if not WeaponHolder:FindFirstChild("Wooden Sword") then 
		WoodenSword.Parent = WeaponHolder
		print("Wooden Sword is moved from your inventory to Weapon Holder!")
	else
		--Only occurs if the Spectator resets the character
		WoodenSword:Remove()
		print("Wooden Sword is removed from your inventory after you respawned!")
	end
		
	--Goes through player's items from StarterGear and removes weapons in it.
	for _, obj in pairs(player.StarterGear:GetChildren()) do
		if not isFood(obj.Name) then
			
			--Moves weapon to the Weapon Holder
			obj.Parent = WeaponHolder
			
			--Player's weapon from the backpack
			local objBP = player.Backpack:FindFirstChild(obj.Name)
			
			--Removes weapon from the player's backpack or character
			if objBP then
				objBP:Remove() 
			else
				player.Character:FindFirstChild(obj.Name):Remove() 
			end
			
			print(obj.Name.." is moved from your inventory to Weapon Holder!")		
		end
	end
end

--Adds all player's weapons to the inventory
function AddWeaponsToInventory(player)
	
	--Goes through all player's weapons in Weapon Holder
	for _, weapon in pairs(player:FindFirstChild("Weapon Holder"):GetChildren()) do
		
		--Clones player's weapon to add in StarterGear and Backpack
		weapon:Clone().Parent = player.Backpack
		
		--The wooden sword should not be also placed in the StarterGear, because it is already in the StarterPack
		if weapon.Name ~= "Wooden Sword" then weapon:Clone().Parent = player.StarterGear end
		
		--Removes weapon from Weapon Holder
		weapon:Remove()
	end
end


--[[Player enters Spectate Mode. This function does the following:
1. Creates a team called Spectators (if it doesn't exist)
2. Assigns player to "Spectators" Team
3. Changes Humanoid's name to "Spectator"
4. Changes character's walkspeed to 50.
5. Changes the animation scripts to make them compatible with Spectator Humanoid
6. Calls in the client to change the Player GUI background color to brown]]
function EnterSpectateMode(player)
	
	--Spectators Team
	local SpectatorTeam

	--If "Spectators" Team doesn't exist
	if not SpectatorTeam then
		SpectatorTeam = Instance.new("Team", game.Teams)
		SpectatorTeam.Name = "Spectators"
		SpectatorTeam.AutoAssignable = false
		SpectatorTeam.TeamColor = BrickColor.new("Brown")
		print("Spectators Team is added!")
	else
		SpectatorTeam = game.Teams:FindFirstChild("Spectators")
	end
	
	--Assigns player to Spectators Team
	if not player.Team then player.Team = SpectatorTeam end
	
	--Gets player's Humanoid
	local humanoid = player.Character:FindFirstChild("Humanoid")

	--Modifies humanoid's name and walkspeed
	humanoid.Name = "Spectator"
	humanoid.WalkSpeed = 50

	--Needs to replace old animation scripts to make them compatible with Spectator Humanoid
	ReplaceWithSpectatorScripts(player.Character)

	--Communicates local script to change the Player GUI's background color to brown
	game.ReplicatedStorage:FindFirstChild("ChangePlayerGUIBackgroundColor_BROWN"):FireClient(player)
	
	--Communicates with SpawnTeamPlayer script to change the Player Overhead GUI's stroke color to brown
	game.ServerStorage:FindFirstChild("Change Player Overhead GUI"):Fire(player)
	
	--Removes all weapons from the player's backpack and startergear
	RemoveWeaponsFromInventory(player)
end

--Handles request after the player presses "Yes" to enter Spectate Mode (Remote Event)
game.ReplicatedStorage:FindFirstChild("OnSpectateMode").OnServerEvent:Connect(EnterSpectateMode)

--Handles request after the "Spectator" player respawns (Bindable Event)
game.ServerStorage:FindFirstChild("Enter Spectate Mode").Event:Connect(EnterSpectateMode)

--Handles request after the match is complete for players to exit spectate mode
game.ServerStorage:FindFirstChild("Exit Spectate Mode").Event:Connect(function(players)
	
	for _, player in pairs(players:GetChildren()) do
		if player.Team and player.Team.Name == "Spectators" then
						
			--Returns player the weapons
			AddWeaponsToInventory(player)
			
			--Player's walkspeed is reduced to normal
			player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
		end
	end
end)