RDX = nil

TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)

function getIdentity(source, callback)
	local xPlayer = RDX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT identifier, firstname, lastname, dateofbirth, sex, height FROM `users` WHERE `identifier` = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		if result[1].firstname ~= nil then
			local data = {
				identifier	= result[1].identifier,
				firstname	= result[1].firstname,
				lastname	= result[1].lastname,
				dateofbirth	= result[1].dateofbirth,
				sex			= result[1].sex,
				height		= result[1].height
			}

			callback(data)
		else
			local data = {
				identifier	= '',
				firstname	= '',
				lastname	= '',
				dateofbirth	= '',
				sex			= '',
				height		= ''
			}

			callback(data)
		end
	end)
end

function setIdentity(identifier, data, callback)
	MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height WHERE identifier = @identifier', {
		['@identifier']		= identifier,
		['@firstname']		= data.firstname,
		['@lastname']		= data.lastname,
		['@dateofbirth']	= data.dateofbirth,
		['@sex']			= data.sex,
		['@height']			= data.height
	}, function(rowsChanged)
		if callback then
			callback(true)
		end
	end)
end

function updateIdentity(playerId, data, callback)
	local xPlayer = RDX.GetPlayerFromId(playerId)

	MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height WHERE identifier = @identifier', {
		['@identifier']		= xPlayer.identifier,
		['@firstname']		= data.firstname,
		['@lastname']		= data.lastname,
		['@dateofbirth']	= data.dateofbirth,
		['@sex']			= data.sex,
		['@height']			= data.height
	}, function(rowsChanged)
		if callback then
			TriggerEvent('rdx_identity:characterUpdated', playerId, data)
			callback(true)
		end
	end)
end

function deleteIdentity(source)
	local xPlayer = RDX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height WHERE identifier = @identifier', {
		['@identifier']		= xPlayer.identifier,
		['@firstname']		= '',
		['@lastname']		= '',
		['@dateofbirth']	= '',
		['@sex']			= '',
		['@height']			= '',
	})
end

RegisterServerEvent('rdx_identity:setIdentity')
AddEventHandler('rdx_identity:setIdentity', function(data, myIdentifiers)
	local xPlayer = RDX.GetPlayerFromId(source)
	setIdentity(myIdentifiers.steamid, data, function(callback)
		if callback then
			TriggerClientEvent('rdx_identity:identityCheck', myIdentifiers.playerid, true)
			TriggerEvent('rdx_identity:characterUpdated', myIdentifiers.playerid, data)
		else
			xPlayer.showNotification(_U('failed_identity'))
		end
	end)
end)

AddEventHandler('rdx:playerLoaded', function(playerId, xPlayer)
	local myID = {
		steamid = xPlayer.identifier,
		playerid = playerId
	}

	TriggerClientEvent('rdx_identity:saveID', playerId, myID)

	getIdentity(playerId, function(data)
		if data.firstname == '' then
			TriggerClientEvent('rdx_identity:identityCheck', playerId, false)
			TriggerClientEvent('rdx_identity:showRegisterIdentity', playerId)
		else
			TriggerClientEvent('rdx_identity:identityCheck', playerId, true)
			TriggerEvent('rdx_identity:characterUpdated', playerId, data)
		end
	end)
end)

AddEventHandler('rdx_identity:characterUpdated', function(playerId, data)
	local xPlayer = RDX.GetPlayerFromId(playerId)

	if xPlayer then
		xPlayer.setName(('%s %s'):format(data.firstname, data.lastname))
		xPlayer.set('firstName', data.firstname)
		xPlayer.set('lastName', data.lastname)
		xPlayer.set('dateofbirth', data.dateofbirth)
		xPlayer.set('sex', data.sex)
		xPlayer.set('height', data.height)
	end
end)

-- Set all the client side variables for connected users one new time
AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(3000)
		local xPlayers = RDX.GetPlayers()

		for i=1, #xPlayers, 1 do
			local xPlayer = RDX.GetPlayerFromId(xPlayers[i])

			if xPlayer then
				local myID = {
					steamid  = xPlayer.identifier,
					playerid = xPlayer.source
				}
	
				TriggerClientEvent('rdx_identity:saveID', xPlayer.source, myID)
	
				getIdentity(xPlayer.source, function(data)
					if data.firstname == '' then
						TriggerClientEvent('rdx_identity:identityCheck', xPlayer.source, false)
						TriggerClientEvent('rdx_identity:showRegisterIdentity', xPlayer.source)
					else
						TriggerClientEvent('rdx_identity:identityCheck', xPlayer.source, true)
						TriggerEvent('rdx_identity:characterUpdated', xPlayer.source, data)
					end
				end)
			end
		end
	end
end)

RDX.RegisterCommand('register', 'user', function(xPlayer, args, showError)
	getIdentity(xPlayer.source, function(data)
		if data.firstname ~= '' then
			xPlayer.showNotification(_U('already_registered'))
		else
			TriggerClientEvent('rdx_identity:showRegisterIdentity', xPlayer.source)
		end
	end)
end, false, {help = _U('show_registration')})

RDX.RegisterCommand('char', 'user', function(xPlayer, args, showError)
	getIdentity(xPlayer.source, function(data)
		if data.firstname == '' then
			xPlayer.showNotification(_U('not_registered'))
		else
			xPlayer.showNotification(_U('active_character', data.firstname, data.lastname))
		end
	end)
end, false, {help = _U('show_active_character')})

RDX.RegisterCommand('chardel', 'user', function(xPlayer, args, showError)
	getIdentity(xPlayer.source, function(data)
		if data.firstname == '' then
			xPlayer.showNotification(_U('not_registered'))
		else
			deleteIdentity(xPlayer.source)
			xPlayer.showNotification(_U('deleted_character'))
			TriggerClientEvent('rdx_identity:showRegisterIdentity', xPlayer.source)
		end
	end)
end, false, {help = _U('delete_character')})