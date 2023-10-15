local QBCore = exports['qb-core']:GetCoreObject()
Citizen.CreateThread(function()
	while QBCore == nil do
		QBCore = exports['qb-core']:GetCoreObject()
		Citizen.Wait(500)
	end
end)

RegisterNetEvent("restaurants-sv:ringBell")
AddEventHandler("restaurants-sv:ringBell", function(restaurant)
	local _source = source
	local players = QBCore.Functions.GetPlayers()
	local count = 0
	for _, playerSource in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerSource)
		local job = Player.PlayerData.job.name
		if job == restaurant or job == "off"..restaurant then
            TriggerClientEvent('QBCore:Notify', playerSource, "Someone is at your restaurant!", 'primary', 10000)
  			TriggerClientEvent("InteractSound_CL:PlayOnOne", playerSource, "notif",0.3)
			count = count + 1
		end
		Citizen.Wait(0)
	end
	if count > 0 then
		TriggerClientEvent('QBCore:Notify', _source, "Bell has been rung! Employee(s) notified.", 'primary', 10000)
	else
		TriggerClientEvent('QBCore:Notify', _source, "Bell has been rung! No on or off duty employees appear to be awake at this time.", 'primary', 10000)
	end
end)