if GetResourceState('qb-core') ~= 'started' then
 return 
end

print('Tebex: QBCore Framework detected, QBCore Support Loaded')
local QBCore = exports['qb-core']:getSharedObject()

function hasPlayerLoaded(xPlayer)
 local player = QBCore.Functions.GetPlayer(xPlayer)
 if player ~= nil then
  return true
 else 
  return false
 end
end

function addCash(xPlayer, amount)
 local player = QBCore.Functions.GetPlayer(xPlayer)
 player.Functions.AddMoney('cash', amount)
end

function addBank(xPlayer, amount)
 local player = QBCore.Functions.GetPlayer(xPlayer)
 player.Functions.AddMoney('bank', amount)
end

function addItem(xPlayer, item, amount)
 local player = QBCore.Functions.GetPlayer(xPlayer)
 player.Functions.AddItem(item, amount)
end


