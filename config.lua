-- This is the config file for the Tebex Integration.

-- This is the command that will can be used to open the store.
storeCommand = 'buy'

-- This will enable an auto announcer for when you have an active sale.
SaleAutoAnnouncer = false -- true or false
SaleAutoAnnouncerInterval = 5 -- Time in minutes between each announcement.

-- This will enable the ability to manage giftcards in-game, This feature requires an Active Tebex Plus plan.
enableGiftcards = true 

-- This will enable the ability to manage coupons in-game, This feature requires an Active Tebex Plus plan.
enableCoupons = true -- This will enable the ability to manage coupons in-game, This feature requires an Active Tebex Ultimate plan.

-- Available Packages
-- This will allow you to set what items are given to the player when they purchase the package. 
allPackages = {
 -- This is an example package, You can add as many as you want.
 ['Test Package.'] = { -- This must match your package name on your webstore.
  -- This is an example of cash being given to the player.
  {
   type = 'cash', -- This can be cash, bank, item, or custom. 
   amount = 1000 -- This is the amount of money that will be given to the player.
  }, 

  -- This an example of an item being given to the player.
  {
   type = 'item', 
   name = 'bread', -- This must match the item name in your database.
   amount = 5 -- This is the amount of the item that will be given to the player.
  },

  -- This is an example of a custom event being triggered when the player purchases the package.
  {
   -- Events are sent as events from server in the following format: TriggerEvent(eventName, playerId, args)
   type = 'custom', 
   event = 'test:event', -- This is the event that will be triggered when the player purchases the package.
   args = {random = 1} -- this allows you to send arguments to the event 
  }
 }
}


-- This will allow you to edit the language of the notfications,
Language = {
 ['SaleAnnouncement'] = '^8Ongoing Sale! ^0Use /%s to checkout our store and save ^2%s^0 on selected items'
} 