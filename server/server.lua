local RSGCore = exports['rsg-core']:GetCoreObject()
data = {}
OwnedHouses = {}

-- check house
RegisterServerEvent('rsg-properties:server:checkhouses')
AddEventHandler('rsg-properties:server:checkhouses', function()
	local src = source
    MySQL.Async.fetchAll('SELECT * FROM houses;', {}, function(result)
        if result ~= nil then
            for k,v in pairs(result) do
                table.insert(OwnedHouses, v.id)
            end
		end
		TriggerClientEvent('rsg-properties:client:setblips', src, OwnedHouses)
    end)
end)

local function GetAmmoutOwned(pcitizenid, pcid)
    local HasRented = MySQL.Sync.fetchAll( "SELECT * FROM houses WHERE citizenid = @citizenid AND cid = @cid ", { ['citizenid'] = pcitizenid, ['cid'] = pcid} )
    if #HasRented > 0 then return true end
    return false
end

-- buy house
RegisterServerEvent('rsg-properties:server:buyhouse')
AddEventHandler('rsg-properties:server:buyhouse', function(price, id)
	local src = source
	local Player = RSGCore.Functions.GetPlayer(src)
	local citizenid = Player.PlayerData.citizenid
	local cid = Player.PlayerData.cid
	local currentBank = Player.Functions.GetMoney('bank')
	local checkowned = GetAmmoutOwned(citizenid, cid)
	if checkowned == false then
		if currentBank > price then
			-- buy house and add to database
			Player.Functions.RemoveMoney('bank', tonumber(price), 'buy-house')
			TriggerClientEvent('rsg-properties:client:buyhouse', src, price, id)
			TriggerEvent("rsg-properties:server:addhousetodb", id, citizenid, cid, price)
			Player.Functions.SetMetaData("house", id)
			-- notify player
			TriggerClientEvent('RSGCore:Notify', src, 'house purchased, you now own this house', 'success')
			Wait(5000)
			TriggerClientEvent('RSGCore:Notify', src, 'you should now have the keys', 'primary')
		else
			TriggerClientEvent('RSGCore:Notify', src, 'you don\'t have enough money in your bank!', 'error')
		end
	else
		TriggerClientEvent('RSGCore:Notify', src, 'you already own a property!', 'error')
	end
end)

-- add owner to database
AddEventHandler("rsg-properties:server:addhousetodb", function(id , citizenid, cid, price)
    MySQL.Async.execute('INSERT INTO houses (`citizenid`, `cid`, `id`, `time`, `price`) VALUES (@citizenid, @cid, @id, @time, @price);',
	{	citizenid = citizenid,
	    cid = cid,
		id = id,
		time = os.time(),
		price = price
	}, function(rowsChanged)
	end)
end)

-----------------------------------DOORS--------------------------------------------

local DoorInfo	= {}

RegisterServerEvent('rsg-properties:updatedoorsv')
AddEventHandler('rsg-properties:updatedoorsv', function(doorID, state, cb)
    local src = source
	local Player = RSGCore.Functions.GetPlayer(src)
	local phouse = Player.PlayerData.metadata['house']
	if not IsAuthorized(Player.PlayerData.metadata['house'], Config.DoorList[doorID]) then
	TriggerClientEvent('RSGCore:Notify', src, 'You do not have a key!', 'error')
		return
	else
		TriggerClientEvent('rsg-properties:changedoor', src, doorID, state)
	end
end)

RegisterServerEvent('rsg-properties:updateState')
AddEventHandler('rsg-properties:updateState', function(doorID, state, cb)
    local src = source
	local Player = RSGCore.Functions.GetPlayer(src)
	if type(doorID) ~= 'number' then
		return
	end
	if not IsAuthorized(Player.PlayerData.metadata['house'], Config.DoorList[doorID]) then
		return
	end
	DoorInfo[doorID] = {}
	TriggerClientEvent('rsg-properties:setState', -1, doorID, state)
end)

function IsAuthorized(playerHouse, doorID)
	for _,house in pairs(doorID.houseid) do
		if house == playerHouse then
			return true
		end
	end
	return false
end

-----------------------------------END DOORS----------------------------------------
