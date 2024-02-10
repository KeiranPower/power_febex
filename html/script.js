var app = new Vue({
 el: '#app',
 data: {
  webstoreURL: 'https://tebex.io',
  activeView: 'coupons',
  viewData: [],
  coupons: [],
  giftcards: [],
  packages: [],
  currency: '$',

  enableGiftCards: false,
  enableCoupons: false,

  createGiftCard: false,
  createCoupon: false,
 },
 
 methods: {
  viewWebstore: function() {
   window.invokeNative('openUrl', this.webstoreURL);
  },

  viewCoupons: function() {
   this.activeView = 'coupons';
  },

  viewGiftCards: function() {
   this.activeView = 'giftcards';
  },

  viewPendingPlayers: function() {
   this.activeView = 'pending';
  },

  viewPackages: function() {
   this.activeView = 'packages';
  },

  deleteGiftCard: function(id) {
   $.post('https://' + GetParentResourceName() + '/deleteGiftCard', JSON.stringify({ id: id }));
  }, 

  deleteCoupon: function(id) {
   $.post('https://' + GetParentResourceName() + '/deleteCoupon', JSON.stringify({ id: id }));
  },

  openPackage: function(id) {
   window.invokeNative('openUrl', this.webstoreURL + '/package/' + id);
  },

  createGiftCardFunc: function() {
   var amount = $("#giftcardAmount").val();
   var expire = $("#giftcardExpires").val();

   if (amount == "" || expire == "") {
    return;
   }

   $.post('https://' + GetParentResourceName() + '/createGiftCard', JSON.stringify({ amount: amount, expires: expire }));
  },

  createCouponFunc: function() {
   var code = $("#couponCode").val();
   var type = $("#couponType").val();
   var amount = $("#couponAmount").val();
   var limit = $("#couponLimit").val();
  
   if (code == "" || type == "" || amount == "" || limit == "") {
    return;
   }

   $.post('https://' + GetParentResourceName() + '/createCoupon', JSON.stringify({ code: code, type: type, amount: amount, limit: limit }));
  },

 }
});

$(function() {
 window.addEventListener('message', function(event) {
  var data = event.data;
  if (data.type == "openStore") {
   window.invokeNative('openUrl', data.storeURL);
  } else if (data.type == "updateView") {
   if (data.coupons != undefined) {
    app.coupons = data.coupons;
   }

   if (data.giftcards != undefined) {
    app.giftcards = data.giftcards;
   }
  } else if (data.type == "openView") {
   app.webstoreURL = data.storeURL;
   app.coupons = data.coupons;
   app.giftcards = data.giftcards;
   app.currency = data.currency;
   app.packages = data.packages;
   console.log(data.packages)
   app.enableGiftCards = data.enableGiftCards;
   app.enableCoupons = data.enableCoupons;
   $(".appView").fadeIn(0);
  } else if (data.type == "packageView") {
   app.webstoreURL = data.storeURL;
   app.coupons = [];
   app.giftcards = [];
   console.log(data.packages)
   app.packages = data.packages;
   app.currency = data.currency;
   app.enableGiftCards = false;
   app.enableCoupons = false;
   app.activeView = 'packages';
   $(".appView").fadeIn(0);
  }
 });


 document.onkeyup = function (data) {
  if (data.which == 27 ) {
   if (app.createGiftCard || app.createCoupon) {
    app.createGiftCard = false;
    app.createCoupon = false;
    return;
   }
   $("body").fadeOut(0);
   $.post('https://' + GetParentResourceName() + '/close');
  }
 }
});
