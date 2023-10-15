local QBCore = exports['qb-core']:GetCoreObject()
local cookLocation = -1
local foodBeingCooked = ""
local cookingFood = false
local hasCollectedFood = true
local foodTemperature = 0.0
local startCookTime = 0
local endCookTime = 0
local overCookTime = 0
local overCooking = false
local underCookTime = 0
local underCooking = false
local cookProblemTimer = 0
local elapsedCookTime = 0
local displayText = false
local canChangeTemp = false
local lastTempChange = 0
local skillErrors = 0
local heatErrors = 0
local timerError = 0
local pounds = 0
local totalErrors = 0
local cookAmount = 1
local tempSet = false
local reset = true
local loadedBlips = {}
local startedFoodProcess = false
local handlingSkillBar = false
local skillChecksHit = 0
local skillsAttempted = 0
local maxSkillChecks = 0
local shakeErrors = 0
local zoneType = "cook"
local PlayerProps = {}
local PlayerHasProp = false

local registeredCommands = false

function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
	local Player = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(Player))
  
	if not HasModelLoaded(prop1) then
	  LoadPropDict(prop1)
	end
  
	prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
	table.insert(PlayerProps, prop)
	PlayerHasProp = true
	SetModelAsNoLongerNeeded(prop1)
end

function DestroyAllProps()
	for _,v in pairs(PlayerProps) do
		DeleteEntity(v)
	end
	PlayerHasProp = false
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict( dict )
        Citizen.Wait(5)
    end
end

Citizen.CreateThread(function()
	while not QBCore do
		QBCore = exports['qb-core']:GetCoreObject()
		Citizen.Wait(0)
	end
	while QBCore.Functions.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	foodCookCommand()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	foodCookCommand()
end)

--Commands
--
function foodCookCommand()
	if not registeredCommands then
		registeredCommands = true
		RegisterCommand('mixdrink', function(source, args, rawCommand)
			if not startedFoodProcess then
				if #args == 1 then
					local ped = GetPlayerPed(-1)
					local coords = GetEntityCoords(ped, true)
					local currentCookLocation = -1
					for i = 1, #Config.CookLocations, 1 do
						if #(coords - Config.CookLocations[i][2]) <= 3.0 then
							foodBeingCooked = string.lower(args[1])
							if Config.LocationFoods[i][foodBeingCooked] ~= nil then
								currentCookLocation = i
								zoneType = Config.CookLocations[i][3]
								break
							end
						end
					end
					if currentCookLocation ~= -1 then
						cookLocation = currentCookLocation
						if QBCore.Functions.GetPlayerData().job.name == Config.LocationJob[cookLocation] then
							reset = false
							print(zoneType)
							if zoneType == "drinkmix" then
								makeCocktail()
								cookAmount = 1
							end
						else
							QBCore.Functions.Notify("You must be employeed here to do that", "error", 2000)
						end
					else
						QBCore.Functions.Notify("You are either not in the correct location to cook that food or you cannot cook here", "error", 2000)
					end
				else
					QBCore.Functions.Notify("USAGE: /mixdrink drinktomix", "error", 2000)
				end
			else
				QBCore.Functions.Notify("You are already cooking food", "error", 2000)
			end
		end)
		RegisterCommand('cookfood', function(source, args, rawCommand)
			if not startedFoodProcess then
				if #args == 1 then
					local ped = GetPlayerPed(-1)
					local coords = GetEntityCoords(ped, true)
					local currentCookLocation = -1
					for i = 1, #Config.CookLocations, 1 do
						if #(coords - Config.CookLocations[i][2]) <= 3.0 then
							foodBeingCooked = string.lower(args[1])
							if Config.LocationFoods[i][foodBeingCooked] ~= nil then
								currentCookLocation = i
								zoneType = Config.CookLocations[i][3]
								break
							end
						end
					end
					if currentCookLocation ~= -1 then
						cookLocation = currentCookLocation
						if QBCore.Functions.GetPlayerData().job.name == Config.LocationJob[cookLocation] then
							reset = false
							if zoneType == "cook" then
								startPreCookLoop()
							end
						else
							--TriggerEvent("DoLongHudText", "You must be employeed here to do that")
						QBCore.Functions.Notify("You must be employeed here to do that", "error", 2000)
						end
					else
						--TriggerEvent("DoLongHudText", "You are either not in the correct location to cook that food or you cannot cook here")
						QBCore.Functions.Notify("You are either not in the correct location to cook that food or you cannot cook here", "error", 2000)
					end
				else
					--TriggerEvent("DoLongHudText", "USAGE: /cookfood foodtocook")
						QBCore.Functions.Notify("USAGE: /cookfood foodtocook", "error", 2000)
				end
			else
				QBCore.Functions.Notify("You are already cooking food", "error", 2000)
			end
		end)
		RegisterCommand('recipebook', function(source, args, rawCommand)
			local job = QBCore.Functions.GetPlayerData().job.name
			local pageInfo = {}
			local recipeList = " \n "
			local count = 0
			local position = 1
			for i = 1, #Config.LocationJob, 1 do
				if job == Config.LocationJob[i] then
					for food, info in pairs (Config.LocationFoods[i]) do
						if info[3] ~= nil then
							recipeList = recipeList .. "- " .. food .. " - Time: " .. info[2] .. "s Temp: (" .. info[3][1] .. "-" .. info[3][2] .. "f) Ingredients: "
						else
							recipeList = recipeList .. "- " .. food .. " - Time: " .. info[2] .. "s Ingredients: "
						end
						for j = 1, #info[1], 1 do
							local swapable = "("
							for k = 1, #info[1][j][1], 1 do
								swapable = swapable .. info[1][j][1][k]
								if j ~= #info[1] then
									swapable = swapable .. ", "
								end
							end
							swapable = swapable .. " (" .. info[1][j][2] .. "))"
							recipeList = recipeList .. swapable
							if j ~= #info[1] then
								recipeList = recipeList .. ", "
							end
						end
						recipeList = recipeList .. " \n "
						if position % 3 == 0 then
							table.insert(pageInfo, recipeList)
							recipeList = " \n "
						end
						position = position + 1
					end
				end
			end
			position = position - 1
			if position % 15 ~= 0 then
				table.insert(pageInfo, recipeList)
			end
			local pages = math.ceil(position / 3)
			local page = 1
			if args[1] ~= nil then
				if tonumber(args[1]) then
					page = tonumber(args[1])
				end
			end
			local pageData = pageInfo[page] .. " \nPage " .. page .. "/" .. pages
			--TriggerEvent("customNotificationpd", " \n [1] 18 Charger - [2] Vic \n [3] Taurus - [4] 14 Charger \n [5] Tahoe -  [6] Ram \n [7] Impala -  [8] 10 Charger \n [9] Camero - [10] Mustang \n [12] F150 - [13] Harley \n [14] F250 - [15] Silverado \n [16] Prison Bus")
			TriggerEvent("chatMessage","RECIPES",2,pageData)
		end)
	end
end

function hasRequiredIngredients()
	local hasAllIngrediets = true
	for i = 1, #Config.LocationFoods[cookLocation][foodBeingCooked][1], 1 do
		local foodInfo = Config.LocationFoods[cookLocation][foodBeingCooked][1][i]
		local itemCount = 0
		local hasOneOf = false
		for j = 1, #foodInfo[1], 1 do

			if QBCore.Functions.HasItem(foodInfo[1][j], (foodInfo[2] * cookAmount)) then
				hasOneOf = true
			end
		end
		if not hasOneOf then
			hasAllIngrediets = false
		end
	end
	return hasAllIngrediets
end

function removeRequiredIngredients()
	for i = 1, #Config.LocationFoods[cookLocation][foodBeingCooked][1], 1 do
		local foodInfo = Config.LocationFoods[cookLocation][foodBeingCooked][1][i]
		local amountToRemove = cookAmount * foodInfo[2]
		for j = 1, #foodInfo[1], 1 do
			print("Removing", foodInfo[1][j], amountToRemove)
			TriggerServerEvent("qb-inventory-sv:RemoveItem", foodInfo[1][j], amountToRemove, nil, true)
			Citizen.Wait(350)
		end
	end
end

function placeIngredients()
	local placingIngredients = true
	local dict = 'anim@amb@business@coc@coc_unpack_cut_left@'
	loadAnimDict(dict)
	TaskPlayAnim(GetPlayerPed(-1), dict, "coke_cut_v1_coccutter", 3.0, -8, -1, 17, 0, 0, 0, 0 )
	QBCore.Functions.Progressbar("ingredient_preparation", "Preparing to add ingredients", 2000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done
		for i = 1, #Config.LocationFoods[cookLocation][foodBeingCooked][1], 1 do
			if placingIngredients then
			local placingIngredient = true
			local foodInfo = Config.LocationFoods[cookLocation][foodBeingCooked][1][i]
			Citizen.Wait(175)
			QBCore.Functions.Progressbar("ingredient_preparation", "Adding " .. (cookAmount * foodInfo[2]) .. " " .. foodInfo[3] .. "(s)", 1550, false, true, {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done
				local Skillbar = exports['qb-skillbar']:GetSkillbarObject()

				Skillbar.Start({
					duration = 3000,
					pos = exports['qb-core']:qbRandomNumber(10, 30),
					width = exports['qb-core']:qbRandomNumber(7, 14),
				}, function()
					placingIngredient = false
				end, function()
					skillErrors = skillErrors + 1
					placingIngredient = false
				end)
			end, function() -- Cancel
				placingIngredient = false
				resetCook()
				return
			end)
			while placingIngredient do
				Citizen.Wait(1)
			end
			if reset then
				StopAnimTask(GetPlayerPed(-1), dict, "coke_cut_v1_coccutter", 8.0)
				placingIngredients = false
				return
			end
			if i == #Config.LocationFoods[cookLocation][foodBeingCooked][1] then
				StopAnimTask(GetPlayerPed(-1), dict, "coke_cut_v1_coccutter", 8.0)
				placingIngredients = false
			end
		end
		end
	end, function() -- Cancel
		placingIngredients = false
		StopAnimTask(GetPlayerPed(-1), dict, "coke_cut_v1_coccutter", 8.0)
		resetCook()
		return
	end)
	while placingIngredients do
		Citizen.Wait(1)
	end
	ClearPedTasksImmediately(GetPlayerPed(-1))
	Citizen.Wait(1000)
end

function receiveFood()
	local extraFood = math.floor((pounds / 5) + 0.5)
	if ((skillChecksHit / skillsAttempted) * 100) >= 70 then
		extraFood += math.floor((((skillChecksHit / skillsAttempted) * skillChecksHit) / 2) * extraFood)
	end
	print(totalErrors, skillsAttempted, skillChecksHit, maxSkillChecks, extraFood)
	if totalErrors == 0 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, (pounds + extraFood), false, {Grade = "A"}, true)
	elseif totalErrors == 1 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, (pounds + extraFood), false, {Grade = "B"}, true)
	elseif totalErrors == 2 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, (pounds + extraFood), false, {Grade = "C"}, true)
	elseif totalErrors == 3 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, (pounds + extraFood), false, {Grade = "D"}, true)
	else
		TriggerServerEvent("qb-inventory-sv:AddItem", "burntfood", pounds, nil, nil, true)
	end
end

function receiveCocktail()
	if totalErrors == 0 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, 3, false, {Grade = "A"}, true)
	elseif totalErrors == 1 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, 3, false, {Grade = "B"}, true)
	elseif totalErrors == 2 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, 3, false, {Grade = "C"}, true)
	elseif totalErrors == 3 then
		TriggerServerEvent("qb-inventory-sv:AddItem", foodBeingCooked, 3, false, {Grade = "D"}, true)
	else
		TriggerServerEvent("qb-inventory-sv:AddItem", "swampwater", 3, nil, nil, true)
	end
end

function cookFood()
	local ped = GetPlayerPed(-1)
	local coords = GetEntityCoords(ped, true)
	if hasCollectedFood then
		if cookAmount > 0 then
			if #(coords - Config.CookLocations[cookLocation][2]) <= 1.5 then
				--Check to make sure player has all the ingredients
				if hasRequiredIngredients() then 
					removeRequiredIngredients()
					--Wait for player to set temperature
					pounds = math.ceil(cookAmount)
					while not tempSet do
						Citizen.Wait(100)
					end
					cookingFood = true
					hasCollectedFood = false
					displayText = true
					displayControlPanel()
					placeIngredients()
					TriggerEvent("DoLongHudText","Go to the cook location to put the food into the cooking apparatus and being cooking",1, 15000)
					while cookingFood do
						local coords = GetEntityCoords(GetPlayerPed(-1), false)
						if #(Config.CookLocations[cookLocation][1] - coords) <= 2.5 then
							DrawText3Ds(Config.CookLocations[cookLocation][1].x, Config.CookLocations[cookLocation][1].y,(Config.CookLocations[cookLocation][1].z - 0.5), "Press ~g~F~s~ to start cooking")
						end
						if IsControlJustPressed(0, 49) and #(Config.CookLocations[cookLocation][1] - coords) <= 2.0 then
							break
						end
						Citizen.Wait(1)
					end
					startCookLoop()
				else
					QBCore.Functions.Notify("You do not have enough of each ingredient", "error", 7500)
				end
			else
				QBCore.Functions.Notify("You are not in the correct spot to cook " .. Config.LocationFoods[cookLocation][foodBeingCooked][4], "error", 7500)
			end
		else
			QBCore.Functions.Notify("Not a valid amount", "error", 7500)
		end
	else
		QBCore.Functions.Notify("You need to collect your other " .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. " first", "error", 7500)
	end
end

function makeCocktail()
	local ped = GetPlayerPed(-1)
	local coords = GetEntityCoords(ped, true)
	if cookAmount > 0 then
		if #(coords - Config.CookLocations[cookLocation][2]) <= 1.5 then
			--Check to make sure player has all the ingredients
			if hasRequiredIngredients() then 
				removeRequiredIngredients()
				--Wait for player to set temperature
				pounds = math.ceil(cookAmount)
				cookingFood = true
				placeIngredients()
				while cookingFood do
					local coords = GetEntityCoords(GetPlayerPed(-1), false)
					if #(Config.CookLocations[cookLocation][1] - coords) <= 2.5 then
						DrawText3Ds(Config.CookLocations[cookLocation][1].x, Config.CookLocations[cookLocation][1].y,(Config.CookLocations[cookLocation][1].z - 0.5), "Press ~g~F~s~ to start shaking cocktail")
					end
					if IsControlJustPressed(0, 49) and #(Config.CookLocations[cookLocation][1] - coords) <= 2.0 then
						startCocktailShake()
						break
					end
					Citizen.Wait(1)
				end
			else
				QBCore.Functions.Notify("You do not have enough of each ingredient", "error", 7500)
			end
		else
			QBCore.Functions.Notify("You are not in the correct spot to mix " .. Config.LocationFoods[cookLocation][foodBeingCooked][3], "error", 7500)
		end
	else
		QBCore.Functions.Notify("Not a valid amount", "error", 7500)
	end
end

function startCocktailShake()
	local placingIngredients = true
	loadAnimDict("mp_player_int_upperwank")
	PropName = "prop_bar_cockshaker"
	PropBone = 18905
	PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack({0.12, 0.008, -0.03, 240.0, -60.0})
	AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
    TaskPlayAnim(GetPlayerPed(-1), "mp_player_int_upperwank", "mp_player_int_wank_02", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	QBCore.Functions.Progressbar("ingredient_preparation", "Shaking Beverage..", ((cookAmount * 3) * 1500), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done
		StopAnimTask(GetPlayerPed(-1), "mp_player_int_upperwank", "mp_player_int_wank_02", 8.0)
	end, function() -- Cancel
		placingIngredients = false
		StopAnimTask(GetPlayerPed(-1), "mp_player_int_upperwank", "mp_player_int_wank_02", 8.0)
		resetCook()
		return
	end)
	for i = 1, cookAmount * 3, 1 do
		if placingIngredients then
			local placingIngredient = true
			local foodInfo = Config.LocationFoods[cookLocation][foodBeingCooked][1][i]
			local Skillbar = exports['qb-skillbar']:GetSkillbarObject()

			Skillbar.Start({
				duration = 1350,
				pos = exports['qb-core']:qbRandomNumber(10, 70),
				width = exports['qb-core']:qbRandomNumber(7, 14),
			}, function()
				placingIngredient = false
			end, function()
				shakeErrors = shakeErrors + 1
				placingIngredient = false
			end)
			while placingIngredient do
				Citizen.Wait(1)
			end
			if i == cookAmount * 3 then
				placingIngredients = false
			else
				Citizen.Wait(150)
			end
		end
	end
	while placingIngredients do
		Citizen.Wait(1)
	end
	if reset then
		ClearPedTasksImmediately(GetPlayerPed(-1))
		DestroyAllProps()
		return
	end
	ClearPedTasksImmediately(GetPlayerPed(-1))
	DestroyAllProps()
	Citizen.Wait(1000)
	local ped = GetPlayerPed(-1)
	local coords = GetEntityCoords(ped, true)
	totalErrors = shakeErrors + skillErrors
	receiveCocktail(totalErrors)
	if totalErrors > 0 then
		local errorString = ""
		if skillErrors > 0 then
			if errorString ~= "" then	
				errorString = errorString .. 'and for messing up while preparing the ' .. Config.LocationFoods[cookLocation][foodBeingCooked][3] .. '.'
			else
				errorString = 'You received lower quality ' .. Config.LocationFoods[cookLocation][foodBeingCooked][3] .. ' due to messing up while preparing the ' .. Config.LocationFoods[cookLocation][foodBeingCooked][3] .. '.'
			end
		end
		if shakeErrors > 0 then
			if errorString ~= "" then	
				errorString = errorString .. ' and for messing up the shaking'
			else
				errorString = 'You received lower quality ' .. Config.LocationFoods[cookLocation][foodBeingCooked][3] .. ' due to messing up the shaking of the cocktail'
			end
		end
		QBCore.Functions.Notify(errorString, "error", 20000)

	end
	resetCook()
end

function getFood()
	local ped = GetPlayerPed(-1)
	local coords = GetEntityCoords(ped, true)
	if #(coords - Config.CookLocations[cookLocation][1]) <= 1.25 then
		receiveFood(totalErrors)
		if totalErrors > 0 then
			local errorString = ""
			if timeError > 0 then
				errorString = 'You received lower quality ' .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. ' due to cooking improper time'
			end
			if heatErrors > 0 then
				if errorString ~= "" then	
					errorString = errorString .. ', cooking at wrong temperature for extened time'
				else
					errorString = 'You received lower quality ' .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. ' due to cooking at wrong temperature for extened time'
				end
			end
			if skillErrors > 0 then
				if errorString ~= "" then	
					errorString = errorString .. 'and for messing up while preparing the ' .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. '.'
				else
					errorString = 'You received lower quality ' .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. ' due to messing up while preparing the ' .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. '.'
				end
			end
			QBCore.Functions.Notify(errorString, "error", 20000)

		end
		resetCook()
	else
		QBCore.Functions.Notify("You are not in the correct spot to collect your " .. Config.LocationFoods[cookLocation][foodBeingCooked][4], "error", 7500)
	end
end

function resetCook()
	cookingFood = false
	hasCollectedFood = true
	foodTemperature = 0.0
	startCookTime = 0
	endCookTime = 0
	overCookTime = 0
	overCooking = false
	underCookTime = 0
	underCooking = false
	cookProblemTimer = 0
	elapsedCookTime = 0
	displayText = false
	canChangeTemp = false
	lastTempChange = 0
	skillErrors = 0
	heatErrors = 0
	timerError = 0
	pounds = 0
	totalErrors = 0
	cookAmount = 1
	tempSet = false
	placedIngredients = false
	reset = true
	startedFoodProcess = false
	handlingSkillBar = false
	skillChecksHit = 0
	skillsAttempted = 0
	maxSkillChecks = 0
	shakeErrors = 0
	zoneType = "cook"
end

function startPreCookLoop()
	startedFoodProcess = true
	Citizen.CreateThread(function()
		local startTime = GetGameTimer()
		local placedIngredients = false
		while not placedIngredients and (GetGameTimer() - startTime) <= 60000 and not reset do
			Citizen.Wait(1)
			local ped = GetPlayerPed(-1)
			local coords = GetEntityCoords(ped, true)
			if #(Config.CookLocations[cookLocation][2] - coords) <= 2.5 then
				DrawText3Ds(Config.CookLocations[cookLocation][2].x, Config.CookLocations[cookLocation][2].y, (Config.CookLocations[cookLocation][2].z + 1), "Cook amount is currently ~y~" .. cookAmount .. " " .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. "(s)")
				DrawText3Ds(Config.CookLocations[cookLocation][2].x, Config.CookLocations[cookLocation][2].y, (Config.CookLocations[cookLocation][2].z), "Press ~b~G~s~ to LOWER ~o~H~s~ to RAISE the amount to cook")
				DrawText3Ds(Config.CookLocations[cookLocation][2].x, Config.CookLocations[cookLocation][2].y, (Config.CookLocations[cookLocation][2].z - 0.09), "Press ~g~F~s~ to confirm amount ~r~C~s~ to cancel")
			end
			if IsControlJustPressed(0, 58) and #(Config.CookLocations[cookLocation][2] - coords) <= 0.5 then
				if cookAmount > 1 then
					cookAmount = cookAmount - 1
				end
			end
			if IsControlJustPressed(0, 74) and #(Config.CookLocations[cookLocation][2] - coords) <= 0.5 then
				cookAmount = cookAmount + 1
			end
			if IsControlJustPressed(0, 49) and #(Config.CookLocations[cookLocation][2] - coords) <= 0.5 then
				if hasRequiredIngredients() then
					
					local reductionAmount = 11 - ((1 - ((cookAmount - 1) / 250)) * 5)
					local minCookTime = math.floor((Config.LocationFoods[cookLocation][foodBeingCooked][2] + ((Config.LocationFoods[cookLocation][foodBeingCooked][2] / reductionAmount) * (cookAmount - 1))) + 0.5)
					maxSkillChecks = math.floor(minCookTime / 6.3)
					TriggerEvent('chatMessage', 'RESTAURANTS: ', 3, "Minimum cook time for " .. cookAmount .. " " .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. "(s) is " .. minCookTime .. " seconds")
					placedIngredients = true
				else
					QBCore.Functions.Notify("You do not have enough of each ingredient", "error", 7500)
					resetCook()
					break
				end
			end
			if IsControlJustPressed(0, 79) and #(Config.CookLocations[cookLocation][2] - coords) <= 0.5 then
				resetCook()
				break
			end
		end
		if placedIngredients then
			QBCore.Functions.Notify("Go to the cook location to set the temperature before combining the ingredients", "primary", 7500)
		else
			resetCook()
		end
		local ped = GetPlayerPed(-1)
		Citizen.CreateThread(function()
			while not cookingFood and placedIngredients and not reset do
				local coords = GetEntityCoords(ped, true)
				Citizen.Wait(125)
				if IsControlPressed(0, 58) and #(Config.CookLocations[cookLocation][1] - coords) <= 2.0 then
					if foodTemperature > 5 then
						foodTemperature = foodTemperature - 5
					end
				end
				if IsControlPressed(0, 74) and #(Config.CookLocations[cookLocation][1] - coords) <= 2.0 then
					foodTemperature = foodTemperature + 5
				end
			end
		end)
		while not cookingFood and placedIngredients and not reset do
			Citizen.Wait(1)
			local coords = GetEntityCoords(ped, true)
			if #(Config.CookLocations[cookLocation][1] - coords) <= 2.5 then
				DrawText3Ds(Config.CookLocations[cookLocation][1].x, Config.CookLocations[cookLocation][1].y, Config.CookLocations[cookLocation][1].z, "~o~"..cookAmount.." " .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. "(s)~s~".." / ~g~"..foodTemperature.."° Fahrenheit~s~ / ~y~"..elapsedCookTime.."(s)~s~")
			end
			if #(Config.CookLocations[cookLocation][1] - coords) <= 2.5  then
				DrawText3Ds(Config.CookLocations[cookLocation][1].x, Config.CookLocations[cookLocation][1].y, (Config.CookLocations[cookLocation][1].z - 1), "Press ~b~G~s~ to LOWER ~o~H~s~ to RAISE the temperature by 5° Fahrenheit")
			end
			if #(Config.CookLocations[cookLocation][2] - coords) <= 2.5 then
				DrawText3Ds(Config.CookLocations[cookLocation][2].x, Config.CookLocations[cookLocation][2].y,Config.CookLocations[cookLocation][2].z, "Press ~g~F~s~ to combine ingredients ~r~C~s~ to cancel")
			end
			if IsControlJustPressed(0, 49) and #(Config.CookLocations[cookLocation][2] - coords) <= 2.0 then
				tempSet = true
				cookFood()
			end
			if IsControlJustPressed(0, 79) and #(Config.CookLocations[cookLocation][2] - coords) <= 2.0 then
				resetCook()
				break
			end
		end
	end)
end

function displayControlPanel()
	Citizen.CreateThread(function()
		while cookingFood or not hasCollectedFood and not reset do
			Citizen.Wait(125)
			if IsControlPressed(0, 58) and canChangeTemp and cookingFood then
				foodTemperature = foodTemperature - 0.5
			end
			if IsControlPressed(0, 74) and canChangeTemp and cookingFood then
				foodTemperature = foodTemperature + 0.5
			end
		end
	end)
	Citizen.CreateThread(function()
		while cookingFood or not hasCollectedFood and not reset do
			Citizen.Wait(1)
			if displayText and cookingFood then
				DrawText3Ds(Config.CookLocations[cookLocation][1].x, Config.CookLocations[cookLocation][1].y, Config.CookLocations[cookLocation][1].z, "~o~"..pounds.." " .. Config.LocationFoods[cookLocation][foodBeingCooked][4] .. "(s)~s~".." / ~g~"..foodTemperature.."° Fahrenheit~s~ / ~y~"..elapsedCookTime.."(s)~s~")
			end
			if canChangeTemp and cookingFood then
				DrawText3Ds(Config.CookLocations[cookLocation][1].x, Config.CookLocations[cookLocation][1].y, (Config.CookLocations[cookLocation][1].z - 1), "Press ~b~G~s~ to LOWER ~o~H~s~ to RAISE the temperature by 0.5° Fahrenheit")
				DrawText3Ds(Config.CookLocations[cookLocation][1].x, Config.CookLocations[cookLocation][1].y, (Config.CookLocations[cookLocation][1].z - 1.05), "Press ~r~F~s~ to stop the cook")
			end
			if IsControlJustPressed(0, 49) and canChangeTemp and cookingFood then
				cookingFood = false
				getFood()
			end
		end
	end)
end

function startCookLoop()
	startCookTime = GetGameTimer()
	--Do the logic
	Citizen.CreateThread(function()
		local reductionAmount = 11 - ((1 - ((pounds - 1) / 250)) * 5)
		local minCookTime = (Config.LocationFoods[cookLocation][foodBeingCooked][2] + ((Config.LocationFoods[cookLocation][foodBeingCooked][2] / reductionAmount) * (pounds - 1))) * 1000
		print(minCookTime, pounds)
		local maxCookTime = minCookTime + (60 * 1000)
		while cookingFood and not reset do
			local ped = GetPlayerPed(-1)
			local coords = GetEntityCoords(ped, true)
			if #(coords-Config.CookLocations[cookLocation][1]) <= 5 then
				displayText = true
			else
				displayText = false
			end
			if #(coords-Config.CookLocations[cookLocation][1]) <= 1.5 then
				canChangeTemp = true
			else
				canChangeTemp = false
			end
			elapsedCookTime = ((GetGameTimer() - startCookTime) / 1000)
			if (foodTemperature > Config.LocationFoods[cookLocation][foodBeingCooked][3][2] or foodTemperature < Config.LocationFoods[cookLocation][foodBeingCooked][3][1]) and cookProblemTimer == 0 then
				cookProblemTimer = GetGameTimer()
				if foodTemperature < Config.LocationFoods[cookLocation][foodBeingCooked][3][1] then
					underCooking = true
					underCookTime = underCookTime + (GetGameTimer()-cookProblemTimer)
				elseif foodTemperature > Config.LocationFoods[cookLocation][foodBeingCooked][3][2] then
					overCooking = true
					overCookTime = overCookTime + (GetGameTimer()-cookProblemTimer)
				end
			elseif (foodTemperature <= Config.LocationFoods[cookLocation][foodBeingCooked][3][2] and foodTemperature >= Config.LocationFoods[cookLocation][foodBeingCooked][3][1]) and cookProblemTimer ~= 0 then
				if underCooking then
					underCookTime = underCookTime + (GetGameTimer()-cookProblemTimer)
				else
					overCookTime = overCookTime + (GetGameTimer()-cookProblemTimer)
				end
				underCooking = false
				overCooking = false
				cookProblemTimer = 0
			end
			if (GetGameTimer() - lastTempChange) >= 6300 and not handlingSkillBar and elapsedCookTime > 5 then
				lastTempChange = GetGameTimer()
				print(handlingSkillBar, lastTempChange)
				local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
				handlingSkillBar = true
				skillsAttempted += 1
				Skillbar.Start({
					duration = 1250,
					pos = exports['qb-core']:qbRandomNumber(35, 75),
					width = exports['qb-core']:qbRandomNumber(10, 15),
				}, function()
					skillChecksHit += 1
					handlingSkillBar = false
				end, function()
					handlingSkillBar = false
					local num = exports['qb-core']:qbRandomNumber(1,1000)
					if num <= 500 then
						num = exports['qb-core']:qbRandomNumber(1,100)
						local tempChange = 0
						if num <= 50 then
							tempChange = exports['qb-core']:qbRandomNumber(10,15)
						else
							tempChange = exports['qb-core']:qbRandomNumber(1,3)
						end
						foodTemperature = foodTemperature + tempChange
					elseif num >= 501 then
						num = exports['qb-core']:qbRandomNumber(1,100)
						local tempChange = 0
						if num <= 10 then
							tempChange = exports['qb-core']:qbRandomNumber(10,15)
						else
							tempChange = exports['qb-core']:qbRandomNumber(1,3)
						end
						foodTemperature = foodTemperature - tempChange
					end
				end)
			end
			Citizen.Wait(100)
		end
		--Finish the cook process
		if cookProblemTimer ~= 0 then
			if underCooking then
				underCookTime = underCookTime + (GetGameTimer()-cookProblemTimer)
			else
				overCookTime = overCookTime + (GetGameTimer()-cookProblemTimer)
			end
		end
		foodTemperature = 0.0
		heatErrors = math.floor(((overCookTime+underCookTime) / 1000 / 10) + 0.45)
		timeError = 0
		if elapsedCookTime > math.floor((maxCookTime / 1000) + 0.5) then
			timeError = 1 + math.floor(((elapsedCookTime - math.floor((maxCookTime / 1000) + 0.5)) / 30) + 0.45)
		end
		if elapsedCookTime < math.floor((minCookTime / 1000) + 0.5) then
			timeError = timeError + 1 + math.floor(((math.floor((minCookTime / 1000) + 0.5) - elapsedCookTime) / 15) + 0.45)
		end
		totalErrors = timeError + heatErrors + skillErrors
		print(timeError, heatErrors, skillErrors, elapsedCookTime, math.floor((maxCookTime / 1000) + 0.5), math.floor((minCookTime / 1000) + 0.5))
	end)
end

RegisterNetEvent("restaurants-cl:preparePizzaIngredients")
AddEventHandler("restaurants-cl:preparePizzaIngredients", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "pizza" then
		QBCore.Functions.Progressbar("ingredient_preparation", "Preparing Ingredients", 2000, false, true, {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {}, nil, nil, function() -- Done
			TriggerEvent('inventory:client:craftTarget', {args = {craftType = "pizza_ingredients"}})
			Wait(1000)
		end, function()end)
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)
	end	
end)

RegisterNetEvent("restaurants-cl:pizzaStorage")
AddEventHandler("restaurants-cl:pizzaStorage", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "pizza" then
        TriggerEvent("inventory:client:SetCurrentStash", "pizza_storage")
		TriggerServerEvent("inventory:server:OpenInventory", "stash", "pizza_storage", 
		{
			maxweight = 10000000,
			slots = 500,
		})
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)	
	end	
end)

RegisterNetEvent("restaurants-cl:pizzaDrinks")
AddEventHandler("restaurants-cl:pizzaDrinks", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "pizza" then
		QBCore.Functions.Progressbar("ingredient_preparation", "Pouring Drink(s)", 2000, false, true, {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {}, nil, nil, function() -- Done
			TriggerEvent('inventory:client:craftTarget', {args = {craftType = "pizza_drinks"}})
			Wait(1000)
		end, function()end)
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)	
	end	
end)

RegisterNetEvent("restaurants-cl:prepareBurgerShotIngredients")
AddEventHandler("restaurants-cl:prepareBurgerShotIngredients", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "burgershot" then
		QBCore.Functions.Progressbar("ingredient_preparation", "Preparing Ingredients", 2000, false, true, {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {}, nil, nil, function() -- Done
			TriggerEvent('inventory:client:craftTarget', {args = {craftType = "burgershot_ingredients"}})
			Wait(1000)
		end, function()end)
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)
	end	
end)

RegisterNetEvent("restaurants-cl:prepareUWUIngredients")
AddEventHandler("restaurants-cl:prepareUWUIngredients", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "uwu" then
		QBCore.Functions.Progressbar("ingredient_preparation", "Preparing Ingredients", 2000, false, true, {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {}, nil, nil, function() -- Done
			TriggerEvent('inventory:client:craftTarget', {args = {craftType = "uwu_ingredients"}})
			Wait(1000)
		end, function()end)
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)
	end	
end)

RegisterNetEvent("restaurants-cl:burgerShotDrinks")
AddEventHandler("restaurants-cl:burgerShotDrinks", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "burgershot" then
		QBCore.Functions.Progressbar("ingredient_preparation", "Preparing Ingredients", 2000, false, true, {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {}, nil, nil, function() -- Done
			TriggerEvent('inventory:client:craftTarget', {args = {craftType = "burgershot_drinks"}})
			Wait(1000)
		end, function()end)
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)
	end	
end)

AddEventHandler("restaurants-cl:countertopstorage", function()
	TriggerEvent("inventory:client:SetCurrentStash", "pizza_counter")
	TriggerServerEvent("inventory:server:OpenInventory", "stash", "pizza_counter", 
	{
		maxweight = 100000,
		slots = 20,
	})
end)

AddEventHandler("restaurants-cl:burgershotfoodwarmer", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "burgershot" then
		TriggerEvent("inventory:client:SetCurrentStash", "Food_Warmer")
		TriggerServerEvent("inventory:server:OpenInventory", "stash", "Food_Warmer", 
		{
			maxweight = 1000000,
			slots = 40,
		})
	end
end)

AddEventHandler("restaurants-cl:countertopstorageBurger", function()
	TriggerEvent("inventory:client:SetCurrentStash", "Burger_Shot_Countertop")
	TriggerServerEvent("inventory:server:OpenInventory", "stash", "Burger_Shot_Countertop", 
	{
		maxweight = 100000,
		slots = 20,
	})
end)

AddEventHandler("restaurants-cl:countertopstorageUWU", function()
	TriggerEvent("inventory:client:SetCurrentStash", "UwU_Countertop")
	TriggerServerEvent("inventory:server:OpenInventory", "stash", "UwU_Countertop", 
	{
		maxweight = 100000,
		slots = 20,
	})
end)

RegisterNetEvent("restaurants-cl:burgetshotStorage")
AddEventHandler("restaurants-cl:burgetshotStorage", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "burgershot" then
		TriggerEvent("inventory:client:SetCurrentStash", "Burger_Shot_Storage")
		TriggerServerEvent("inventory:server:OpenInventory", "stash", "Burger_Shot_Storage", 
		{
			maxweight = 10000000,
			slots = 500,
		})
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)
	end	
end)

RegisterNetEvent("restaurants-cl:uWUStorage")
AddEventHandler("restaurants-cl:uWUStorage", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "uwu" then
		TriggerEvent("inventory:client:SetCurrentStash", "UwU_Storage")
		TriggerServerEvent("inventory:server:OpenInventory", "stash", "UwU_Storage", 
		{
			maxweight = 10000000,
			slots = 500,
		})
	else
		TriggerEvent('DoLongHudText', "There is nothing for you to see here.", 2)		
	end	
end)

RegisterNetEvent("restaurants-cl:uwuDrinks")
AddEventHandler("restaurants-cl:uwuDrinks", function()
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "uwu" then
		QBCore.Functions.Progressbar("ingredient_preparation", "Preparing Ingredients", 2000, false, true, {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {}, nil, nil, function() -- Done
			TriggerEvent('inventory:client:craftTarget', {args = {craftType = "uwu_drinks"}})
			Wait(1000)
		end, function()end)
	else
		QBCore.Functions.Notify("There is nothing for you to see here.", "error", 7500)
	end	
end)

local lastBellRing = 0

AddEventHandler("restaurants-cl:ringBellUWU", function()
	if GetGameTimer() -lastBellRing >= 10000 then
		lastBellRing = GetGameTimer()
		TriggerServerEvent("restaurants-sv:ringBell", "uwu")
	end
end)

AddEventHandler("restaurants-cl:ringBellBurger", function()
	if GetGameTimer() -lastBellRing >= 10000 then
		lastBellRing = GetGameTimer()
		TriggerServerEvent("restaurants-sv:ringBell", "burgershot")
	end
end)

RegisterCommand("packagemeal", function(source, args)
	Citizen.Wait(250)
	local rows = {}
	local foods = {}
	local job = QBCore.Functions.GetPlayerData().job.name
	if job == "pizza" or job == "uwu" or job == "burgershot" then
		for i = 1, #Config.LocationJob, 1 do
			if job == Config.LocationJob[i] then
				for food, info in pairs (Config.LocationFoods[i]) do
					local amount = exports["qb-inventory"]:GetQuantity(food)
					if amount > 0 then
						table.insert(foods, {food, amount})
					end
				end
			end
		end
		for i = 1, #Config.Drinks[job], 1 do
			local amount = exports["qb-inventory"]:GetQuantity(Config.Drinks[job][i])
			if amount > 0 then
				table.insert(foods, {Config.Drinks[job][i], amount})
			end
		end
		--Get count of food
		for i = 1, #foods, 1 do
			if foods[i][2] > 0 then
				table.insert(rows, foods[i][1] .. " x" .. foods[i][2])
			end
		end
		if #rows > 0 then
			local values = {exports["erp-keyboard"]:Keyboard({
				header = "Create Packaged Meal",
				rows = rows
			})}
			if values[1] then
				if (#values - 1) == #foods then
					local meta = {}
					local allInputsValid = true
					for i = 2, #values, 1 do
						if values ~= nil then
							if not tonumber(values[i]) then
								allInputsValid = false
								break
							end
						end
					end
					if allInputsValid then
						local maxWeight = 0
						for i = 2, #values, 1 do
							if values ~= nil then
								if tonumber(values[i]) > 0 then
									maxWeight = maxWeight + tonumber(values[i])
								end
							end
						end
						if maxWeight <= 20 then
							QBCore.Functions.Progressbar("ingredient_preparation", "Packaging Meal", 5000, false, true, {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							}, {}, {}, {}, function() -- Done
								for i = 2, #values, 1 do
									if values ~= nil then
										if tonumber(values[i]) > 0 then
											meta[foods[i-1][1]] = values[i]
											TriggerServerEvent("qb-inventory-sv:RemoveItem", foods[i-1][1], tonumber(values[i]), nil, true)
											Citizen.Wait(50)
										end
									end
								end
								TriggerServerEvent("qb-inventory-sv:AddItem", "packagedmeal", 1, nil, meta, true)
							end, function()end)
						else
							QBCore.Functions.Notify("Packaged meals can only weigh up to 20 pounds", "error", 7500)
						end
					else
						QBCore.Functions.Notify("All inputs must have a number", "error", 7500)
					end
				else
					QBCore.Functions.Notify("You need to put 0 for foods you don't want to include", "error", 7500)
				end
			end
		else
			QBCore.Functions.Notify("You do not have any food that can be packaged", "error", 7500)
		end
	end
end)

RegisterNetEvent("restaurants-cl:usePackagedMeal", function(item)
    QBCore.Functions.Progressbar("ingredient_preparation", "Opening Packaged Meal", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
		local slot = item.slot
		local items = item.info
		TriggerServerEvent("qb-inventory-sv:RemoveItem", "packagedmeal", slot, true)
		for name, amount in pairs(items) do
			TriggerServerEvent("qb-inventory-sv:AddItem", name, amount, nil, {}, true)
			Citizen.Wait(150)
		end
    end, function()end)
end)

AddEventHandler("restaurants-cl:ringBellPizza", function()
	if GetGameTimer() -lastBellRing >= 10000 then
		lastBellRing = GetGameTimer()
		TriggerServerEvent("restaurants-sv:ringBell", "pizza")
	end
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end