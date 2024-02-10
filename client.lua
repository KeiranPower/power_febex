RegisterCommand(storeCommand, function(source, args, rawCommand)
 SendNUIMessage({ type = "packageView", storeURL = GlobalState.storeURL, currency = GlobalState.storeCurrencySymbol, coupons = {}, giftcards = {}, enableCoupons = false, enableGiftCards = false, packages = GlobalState.storePackages })
 SetNuiFocus(true, true)
 TriggerEvent("chatMessage", "^2This URL has been opened in your browser. ^0^7^*(^1" .. GlobalState.storeURL .. "^7)")
end, false)

RegisterNetEvent("tebex:openManagementMenu")
AddEventHandler("tebex:openManagementMenu", function(currency, coupons, giftcards)
 SendNUIMessage({ type = "openView", storeURL = GlobalState.storeURL, currency = GlobalState.storeCurrencySymbol, coupons = coupons, giftcards = giftcards, enableCoupons = enableCoupons, enableGiftCards = enableGiftcards, packages = GlobalState.storePackages })
 SetNuiFocus(true, true)
end)

if enableGiftcards then 
 RegisterNUICallback("createGiftCard", function(data, cb)
  TriggerServerEvent("tebex:createGiftCard", data)
  cb("ok")
 end)

 RegisterNUICallback("deleteGiftCard", function(data, cb)
  TriggerServerEvent("tebex:deleteGiftCard", data.id)
  cb("ok")
 end)

 RegisterNetEvent("tebex:updateManagementGiftcards")
 AddEventHandler("tebex:updateManagementGiftcards", function(giftcards)
  SendNUIMessage({ type = "updateView", giftcards = giftcards })
  SetNuiFocus(true, true)
 end)
end 

if enableCoupons then 
 RegisterNUICallback("deleteCoupon", function(data, cb)
  TriggerServerEvent("tebex:deleteCoupon", data.id)
  cb("ok")
 end)

 RegisterNUICallback("createCoupon", function(data, cb)
  TriggerServerEvent("tebex:createCoupon", data)
  cb("ok")
 end)

 RegisterNetEvent("tebex:updateManagementCoupons")
 AddEventHandler("tebex:updateManagementCoupons", function(coupons)
  SendNUIMessage({ type = "updateView", coupons = coupons })
  SetNuiFocus(true, true)
 end)
end

RegisterNUICallback("close", function(data, cb)
 SetNuiFocus(false, false)
 cb("ok")
end)