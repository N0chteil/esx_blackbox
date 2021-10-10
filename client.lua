ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

local data = {}
local dataPlate = false
local dataModel = false
local vehData = {}

Citizen.CreateThread(function()
	while true do
		local player = GetPlayerPed(-1)

		if IsPedInAnyPlane(player) or IsPedInAnyHeli(player) then
			local veh = GetVehiclePedIsIn(player, false)

			if GetVehicleNumberPlateText(veh) == dataPlate then
				table.insert(data, {
					engine = GetIsVehicleEngineRunning(veh),
					engineOnFire = IsVehicleEngineOnFire(veh),
					engineHealth = GetVehicleEngineHealth(veh),
					speed = GetEntitySpeed(veh),
					speedMPH = GetEntitySpeed(veh) * 2.236936,
					speedKMH = GetEntitySpeed(veh) * 3.6,
					landingGearIntact = IsPlaneLandingGearIntact(veh),
					propellersIntact = ArePlanePropellersIntact(veh),
					wingsIntact = ArePlaneWingsIntact(veh),
					heightMeters = GetEntityHeightAboveGround(veh),
					heading = GetEntityPhysicsHeading(veh),
					coords = GetEntityCoords(veh)
				})

				Citizen.Wait(1000)
			elseif dataPlate ~= false then
				TriggerServerEvent("esx_blackbox:addEntry", data, dataPlate, dataModel)
				dataPlate = GetVehicleNumberPlateText(veh)
				dataModel = GetEntityModel(veh)
				data = {}
			elseif dataPlate == false or dataModel == false then
				dataPlate = GetVehicleNumberPlateText(veh)
				dataModel = GetEntityModel(veh)
			end
		elseif table.empty(data) == false and dataPlate ~= false then
			TriggerServerEvent("esx_blackbox:addEntry", data, dataPlate, dataModel)
			data = {}
			dataPlate = false
			dataModel = false
			Citizen.Wait(5)
		end

		Citizen.Wait(0)
	end
end)
RegisterNetEvent("esx_blackbox:viewRecord")
AddEventHandler("esx_blackbox:viewRecord", function(data)
	if data ~= nil then
		ESX.ShowNotification("Loading...")
		RequestModel(tonumber(data.model))

		Citizen.CreateThread(function() 
			local waiting = 0
			while not HasModelLoaded(tonumber(data.model)) do
				waiting = waiting + 100
				Citizen.Wait(100)

				if waiting > 5000 then
					ESX.ShowNotification("~r~Could not load the vehicle model in time.")
					break
				end
			end

			for k, v in pairs(json.decode(data.data)) do
				local veh = CreateVehicle(tonumber(data.model), v.coords.x, v.coords.y, v.coords.z, v.heading, false, false)
	
				FreezeEntityPosition(veh, true)
				DisableVehicleWorldCollision(veh)
				SetDisableVehicleEngineFires(veh, v.engineOnFire)
				SetPlaneEngineHealth(veh, v.engineHealth)
				SetVehicleEngineOn(veh, v.engine, true, false)
				SetEntityInvincible(veh, true)
				table.insert(vehData, veh)
			end
		end)
	end
end)

AddEventHandler('onResourceStop', function()
	for i=1, #vehData, 1 do
		DeleteEntity(vehData[i])
	end
end)

RegisterCommand("removeBlackboxVeh", function() 
    for i=1, #vehData, 1 do
		DeleteEntity(vehData[i])
	end
end)

function table.empty(s)
    for _, _ in pairs(s) do
        return false
    end
    return true
end