ESX = nil
local playersHealing = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetEntry(plate)
	MySQL.Async.fetchScalar('SELECT plate FROM blackbox WHERE plate = @plate', {
		['@plate'] = plate
	}, function(value)
		if value then
			return value
		else
			return false
		end
	end)
end

function UpdateEntry(data, plate)
	local entry = GetEntry()

	if entry then
		MySQL.Sync.execute('UPDATE blackbox SET data = @data WHERE plate = @plate', {
			['@data'] = data,
			['@plate'] = plate
		})
	end
end

ESX.RegisterServerCallback('esx_blackbox:getEntry', function(source, cb, type, data)
	if type == "identifier" then
		MySQL.Async.fetchAll('SELECT * FROM blackbox WHERE identifier = @data', {
			['@data'] = data
		}, function(v)
			cb(v)
		end)
	elseif type == "plate" then
		MySQL.Async.fetchAll('SELECT * FROM blackbox WHERE plate = @data', {
			['@data'] = data
		}, function(v)
			cb(v)
		end)
	end
end)

RegisterServerEvent('esx_blackbox:deleteEntry')
AddEventHandler('esx_blackbox:deleteEntry', function(type, data)
	if type == "entry" then
		MySQL.Sync.execute('DELETE FROM blackbox WHERE data = @data', {
			['@data'] = data.data
		})
	elseif type == "plate" then
		MySQL.Sync.execute('DELETE FROM blackbox WHERE plate = @data', {
			['@data'] = data
		})
	end
end)

RegisterServerEvent('esx_blackbox:addEntry')
AddEventHandler('esx_blackbox:addEntry', function(data, plate, model)
	local identifier = GetPlayerIdentifiers(source)[1]
	
	if not GetEntry() then
		MySQL.Sync.execute('INSERT INTO blackbox (`identifier`, `data`, `plate`, `model`) VALUES (@identifier, @data, @plate, @model)', {
			['@identifier'] = identifier,
			['@data'] = json.encode(data),
			['@plate'] = plate,
			['@model'] = model
		})
	else
		UpdateEntry(data, plate)
	end
end)

RegisterServerEvent('esx_config:updateEntry')
AddEventHandler('esx_config:updateEntry', function(data, plate)
	UpdateEntry(data, plate)
end)
