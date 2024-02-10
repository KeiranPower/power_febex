if GetResourceState('es_extended') ~= 'started' then
 return 
end

print('Tebex: ESX Framework detected, ESX Support Loaded')
local ESX = exports['es_extended']:getSharedObject()

function hasPlayerLoaded(xPlayer)
 local player = ESX.GetPlayerFromId(xPlayer)
 if player ~= nil then
  return true
 else 
  return false
 end
end

function addCash(xPlayer, amount)
 local player = ESX.GetPlayerFromId(xPlayer)
 player.addAccountMoney('cash', amount)
end

function addBank(xPlayer, amount)
 local player = ESX.GetPlayerFromId(xPlayer)
 player.addAccountMoney('bank', amount)
end

function addItem(xPlayer, item, amount)
 local player = ESX.GetPlayerFromId(xPlayer)
 player.addInventoryItem(item, amount)
end


