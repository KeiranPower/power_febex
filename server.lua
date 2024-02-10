-- Replace the webhook URL with your own if you want to use the discord logging feature.
local discordWebookURL = "https://discord.com/api/webhooks/REPLACE/ME"

if SaleAutoAnnouncer then
 Citizen.CreateThread(function()
  while true do 
   if activeSale then 
    -- You can change this event to use your own chat / notification system.
    local message = string.format(Language["SaleAnnouncement"], storeCommand, activeSaleData.discount)
    TriggerClientEvent("chatMessage", -1, message)
   end 
   Citizen.Wait(SaleAutoAnnouncerInterval * 60000)
  end 
 end)
end

--------------------------------------------------------------------
-- DO NOT EDIT THE BELOW CODE UNLESS YOU KNOW WHAT YOU ARE DOING! --
--------------------------------------------------------------------
local secretKey = GetConvar("sv_tebexSecret", nil)

local activeSale = false
local activeSaleData = {}

GlobalState.storeURL = "https://store.example.com"
GlobalState.storePackages = {}
GlobalState.storeCurrencySymbol = "$"

AddEventHandler("onResourceStart", function(resource)
 if resource == GetCurrentResourceName() then 
  if secretKey == nil then
   print("sv_tebexSecret is not set in server.cfg, This is required for the Tebex Integration to work.")
  else 
   print("^3Tebex Integration Started^0")
   
   PerformHttpRequest("https://plugin.tebex.io/information", function(err, data, headers)
    if err == 200 then 
     local myData = json.decode(data)
     GlobalState.storeURL = myData.account.domain
     GlobalState.storeCurrencySymbol = myData.account.currency.symbol

     Citizen.Wait(500)
     
     PerformHttpRequest("https://plugin.tebex.io/packages", function(err, packages, headers)
      if err == 200 then 
       local myData = json.decode(packages)
       local storePackages = {}

       for id,v in pairs(myData) do 
        if not v.disabled then 
         table.insert(storePackages, {id = v.id, name = v.name, price = v.price, image = v.image})        
        end 
       end 

       GlobalState.storePackages = storePackages
      else 
       print("API Error:", err)
      end 
     end, "GET", "", {["X-Tebex-Secret"] = secretKey})
 
     if myData.account.game_type ~= "FiveM" then 
      print("^1WARNING: This server is not using FiveM as the game type, You are required to use the FiveM game type on your Tebex Store to use this integration.^0")
      StopResource(GetCurrentResourceName())
     end
    end 
   end, "GET", "", {["X-Tebex-Secret"] = secretKey})

   if SaleAutoAnnouncer then 
    PerformHttpRequest("https://plugin.tebex.io/sales", function(err, data, headers)
     local myData = json.decode(data)
     
     if myData.data[1] == nil then 
      print("^1WARNING: There are no active sales, Disabling Sale Auto Announcer.^0")
      SaleAutoAnnouncer = false
      return 
     end

     if myData.data[2] ~= nil then 
      print("^1WARNING: There are more than 1 active sales, Only the first sale will be announced.^0")
     end

     local saleName = myData.data[1].name
     local saleDiscount = myData.data[1].discount.type
     
     if saleDiscount == "percentage" then 
      saleDiscount = myData.data[1].discount.percentage.."%"
     else 
      saleDiscount = storeCurrencySymbol..""..myData.data[1].discount.value
     end 

     activeSale = true
     activeSaleData = {name = saleName, discount = saleDiscount}
    end, "GET", "", {["X-Tebex-Secret"] = secretKey})
   end 
  end
 end
end)

RegisterCommand("tebex", function(source, args)
 local source = tonumber(source)
 
 if not enableGiftcards and not enableCoupons then 
  TriggerClientEvent("tebex:openManagementMenu", source, storeCurrencySymbol, {}, {})
 elseif enableGiftcards and not enableCoupons then 
  PerformHttpRequest("https://plugin.tebex.io/gift-cards", function(err, giftcards, headers)
    print("https://plugin.tebex.io/gift-cards")
   if err == 200 then
    print("https://plugin.tebex.io/gift-cards. load menu")
    TriggerClientEvent("tebex:openManagementMenu", source, storeCurrencySymbol, {}, json.decode(giftcards).data)
   else
    print("API Error:", err, data)
   end
  end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
 elseif enableCoupons and not enableGiftcards then 
  PerformHttpRequest("https://plugin.tebex.io/coupons", function(err, coupons, headers)
   if err == 200 then
    TriggerClientEvent("tebex:openManagementMenu", source, storeCurrencySymbol, json.decode(coupons).data, {})
   else
    print("API Error:", err, data)
   end
  end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
 elseif enableGiftcards and enableCoupons then 
  PerformHttpRequest("https://plugin.tebex.io/coupons", function(err, coupons, headers)
   if err == 200 then
    PerformHttpRequest("https://plugin.tebex.io/gift-cards", function(err, giftcards, headers)
     if err == 200 then
      TriggerClientEvent("tebex:openManagementMenu", source, storeCurrencySymbol, json.decode(coupons).data, json.decode(giftcards).data)
     else
      print("API Error:", err, data)
     end
    end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
   else
    print("API Error:", err, data)
   end
  end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
  return
 end
end, true)


if enableGiftcards then 
 RegisterNetEvent("tebex:createGiftCard")
 AddEventHandler("tebex:createGiftCard", function(data)
  local source = tonumber(source)

  if not IsPlayerAceAllowed(source, "command.tebex") then 
   TriggerClientEvent("chatMessage", source, "^8You do not have permission to use this event^0")
   return
  end
 
  PerformHttpRequest("https://plugin.tebex.io/gift-cards", function(err, data, headers)
   if err == 200 then
    Citizen.Wait(500)
    PerformHttpRequest("https://plugin.tebex.io/gift-cards", function(err, giftcards, headers)
     if err == 200 then
      TriggerClientEvent("tebex:updateManagementGiftcards", source, json.decode(giftcards).data)
     else
      print("Error 2:", err, data)
     end
    end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
   else
    print("Error:", err, data)
   end
  end, "POST", json.encode({amount = data.amount, expires = data.expires, note = "Created By In-Game Command"}), {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
 end)

 RegisterNetEvent("tebex:deleteGiftCard")
 AddEventHandler("tebex:deleteGiftCard", function(id)
  local source = tonumber(source)

  if not IsPlayerAceAllowed(source, "command.tebex") then 
   TriggerClientEvent("chatMessage", source, "^8You do not have permission to use this event^0")
   return
  end

  PerformHttpRequest("https://plugin.tebex.io/gift-cards/"..id, function(err, data, headers)
   if err == 200 then
    TriggerClientEvent("chatMessage", source, "^2Giftcard Successfully Deleted^0")
    Citizen.Wait(500)
    PerformHttpRequest("https://plugin.tebex.io/gift-cards", function(err, giftcards, headers)
     if err == 200 then
      TriggerClientEvent("tebex:updateManagementGiftcards", source, json.decode(giftcards).data)
     else
      print("Error 2:", err, data)
     end
    end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
   else
    print("Error:", err, data)
   end
  end, "DELETE", "", {["X-Tebex-Secret"] = secretKey})
 end)
end


if enableCoupons then 
 RegisterNetEvent("tebex:createCoupon")
 AddEventHandler("tebex:createCoupon", function(data)
  local source = tonumber(source)

  if not IsPlayerAceAllowed(source, "command.tebex") then  
   TriggerClientEvent("chatMessage", source, "^8You do not have permission to use this event^0")
   return
  end

  local postData = {
   code = data.code,
   effective_on = "cart",
   discount_application_method = "1",
   packages = "{}",
   discount_type = data.type,
   discount_amount = data.amount,
   discount_percentage = data.amount,
   redeem_unlimited = "false",
   expire_never = "true",
   minimum = "0",
   expire_limit = data.limit,
   note = "Generated By In-Game Command",
   basket_type = "both",
   start_date = os.date("%Y-%m-%d"),
  }

  PerformHttpRequest("https://plugin.tebex.io/coupons", function(err, data, headers)
   if err == 200 then
    Citizen.Wait(500)
    PerformHttpRequest("https://plugin.tebex.io/coupons", function(err, giftcards, headers)
     if err == 200 then
      TriggerClientEvent("tebex:updateManagementCoupons", source, json.decode(coupons).data)
     else
      print("Error 2:", err, data)
     end
    end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
   else
    print("Error:", err, data)
   end
  end, "POST", json.encode(postData), {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
 end)

 RegisterNetEvent("tebex:deleteCoupon")
 AddEventHandler("tebex:deleteCoupon", function(id)
  local source = tonumber(source) 

  if not IsPlayerAceAllowed(source, "command.tebex") then  
   TriggerClientEvent("chatMessage", source, "^8You do not have permission to use this event^0")
   return
  end 

  PerformHttpRequest("https://plugin.tebex.io/coupons/"..id, function(err, data, headers)
   if err == 204 then
    TriggerClientEvent("chatMessage", source, "^2Coupon Successfully Deleted^0")
    Citizen.Wait(500)
    PerformHttpRequest("https://plugin.tebex.io/coupons", function(err, coupons, headers)
     if err == 200 then
      TriggerClientEvent("tebex:updateManagementCoupons", source, json.decode(coupons).data)
     else
      print("Error 1:", err, data)
     end
    end, "GET", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
   else
    print("Error:", err, data)
   end
  end, "DELETE", "", {["X-Tebex-Secret"] = secretKey, ["Content-Type"] = "application/json"})
 end)
end 



-- Purchase Command Handler
local pendingCommands = {}

RegisterCommand("tebex_purchase", function(source, args)
 if source ~= 0 then 
  return 
 end 

 local commandData = json.decode(args[1])
 local serverId = tonumber(commandData.serverId)
 local packageName = tostring(commandData.package)

 if hasPlayerLoaded(serverId) then 
  TriggerEvent("tebex:purchaseCommand", serverId, packageName)
 else 
  table.insert(pendingCommands, {serverId = serverId, packageName = packageName})
 end 
end)

-- Pending Command Handler
Citizen.CreateThread(function()
 while true do 
  Citizen.Wait(5000)

  for id,v in pairs(pendingCommands) do 
   if hasPlayerLoaded(v.serverId) then 
    TriggerEvent("tebex:purchaseCommand", v.serverId, v.packageName)
    table.remove(pendingCommands, id)
   end
  end 
 end 
end)

-- Purchase Command Event
AddEventHandler("tebex:purchaseCommand", function(serverId, packageName)
 local source = tonumber(serverId)
 local packageName = tostring(packageName)
 local packageData = allPackages[packageName]

 if packageData == nil then 
  print("Tebex: Package "..packageName.." does not exist, Please check your config.lua")
  return
 end

 for id,v in pairs(packageData) do 
  if v.type == "cash" then 
   addCash(source, v.amount)
   print("Tebex: "..v.amount.." Cash has been added to "..GetPlayerName(source))
  elseif v.type == "bank" then
   print("Tebex: "..v.amount.." Bank has been added to "..GetPlayerName(source))
   addBank(source, v.amount)
  elseif v.type == "item" then 
   print("Tebex: "..v.amount.." "..v.name.." has been added to "..GetPlayerName(source))
   addItem(source, v.name, v.amount)
  elseif v.type == "custom" then 
   TriggerEvent(v.event, source, v.args)
  end 
 end
end) 

AddEventHandler("test:event", function(playerId, args)
 print("Tebex: Test Event Triggered")
 print("Tebex: Player ID: "..playerId)
 print("Tebex: Args: "..json.encode(args))
end) 