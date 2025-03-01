import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcons {
  static const Map<String, String> iconMap = {
    // Banking & Money
    'axis': 'assets/icons/Axisbank.svg',
    'icici': 'assets/icons/ICICI.svg',
    'sbi': 'assets/icons/SBI.svg',
    'anz': 'assets/icons/ANZ.svg',
    'au': 'assets/icons/AU.svg',
    'bob': 'assets/icons/BOB.svg',
    'citibank': 'assets/icons/CitiBank.svg',
    'deutsche': 'assets/icons/DeutscheBank.svg',
    'hdfc': 'assets/icons/HDFC.svg',
    'idbi': 'assets/icons/IDBI.svg',
    'kotak': 'assets/icons/Kotak.svg',
    'union': 'assets/icons/Union.svg',
    'boi': 'assets/icons/BOI.svg',
    'pay': 'assets/icons/pay.svg',
    'hsbc': 'assets/icons/HSBC.svg',
    'idfc': 'assets/icons/IDFC.svg',
    'induslnd': 'assets/icons/Induslnd.svg',
    'paytm': 'assets/icons/PAYTM.svg',
    'pnb': 'assets/icons/PNB.svg',
    'yesbank': 'assets/icons/YesBank.svg',

    // Shopping & Payments
    'airticket': 'assets/icons/airticket.svg',
    'amazon': 'assets/icons/amazon.svg',
    'amazonpay': 'assets/icons/amazonpay.svg',
    'applepay': 'assets/icons/applepay.svg',
    'creditcard': 'assets/icons/credit-card.svg',
    'flipkart': 'assets/icons/flipkart.svg',
    'googlepay': 'assets/icons/googlepay.svg',
    'mastercard': 'assets/icons/mastercard.svg',
    'shopping': 'assets/icons/shopping.svg',
    'shoppingbag': 'assets/icons/shoppingbag.svg',
    'transactions': 'assets/icons/transactions.svg',

    //New Icons
    'ac': 'assets/icons/ac.svg',
    'accomidation': 'assets/icons/accomidation.svg',
    'applaince': 'assets/icons/applaince.svg',
    'charity': 'assets/icons/charity.svg',
    'close': 'assets/icons/close.svg',
    'closed': 'assets/icons/closed.svg',
    'debt': 'assets/icons/debt.svg',
    'deposit': 'assets/icons/deposit.svg',
    'fine': 'assets/icons/fine.svg',
    'flight': 'assets/icons/flight.svg',
    'fridge': 'assets/icons/fridge.svg',
    'furniture': 'assets/icons/furniture.svg',
    'help': 'assets/icons/help.svg',
    'idea': 'assets/icons/idea.svg',
    'installment': 'assets/icons/installment.svg',
    'insurance': 'assets/icons/insurance.svg',
    'lent': 'assets/icons/lent.svg',
    'loan': 'assets/icons/loan.svg',
    'loanopen': 'assets/icons/loanopen.svg',
    'oiler': 'assets/icons/oiler.svg',
    'parking': 'assets/icons/parking.svg',
    'pin': 'assets/icons/pin.svg',
    'silver': 'assets/icons/silver.svg',
    'spares': 'assets/icons/spares.svg',
    'sports': 'assets/icons/sports.svg',
    'sprout': 'assets/icons/sprout.svg',
    'stocks': 'assets/icons/stocks.svg',
    'unknown': 'assets/icons/unknown.svg',
    'utilities': 'assets/icons/utilities.svg',

    'cggb': 'assets/icons/CGGB.svg',
    'chef': 'assets/icons/chef.svg',
    'farmer': 'assets/icons/farmer.svg',
    'gas': 'assets/icons/gas.svg',
    'knife': 'assets/icons/knife.svg',
    'man': 'assets/icons/man.svg',
    'man2': 'assets/icons/man2.svg',
    'man3': 'assets/icons/man3.svg',
    'map': 'assets/icons/map.svg',
    'nodata': 'assets/icons/nodata.svg',
    'photographer': 'assets/icons/photographer.svg',
    'pot': 'assets/icons/pot.svg',
    'user': 'assets/icons/user.svg',
    'woman': 'assets/icons/woman.svg',


    // Transportation
    'atc': 'assets/icons/atc.svg',
    'atm': 'assets/icons/atm.svg',
    'auto': 'assets/icons/auto.svg',
    'banktransfer': 'assets/icons/BankTransfer.svg',
    'bike': 'assets/icons/bike.svg',
    'bus': 'assets/icons/bus.svg',
    'cab': 'assets/icons/cab.svg',
    'car': 'assets/icons/car.svg',
    'honda': 'assets/icons/honda.svg',
    'mitsubishi': 'assets/icons/mitsubishi.svg',
    'petrol': 'assets/icons/petrol.svg',
    'train': 'assets/icons/train.svg',
    'transport': 'assets/icons/transport.svg',

    // Bills & Utilities
    'bill': 'assets/icons/bill.svg',
    'electricitybill': 'assets/icons/electricitybill.svg',
    'receipt': 'assets/icons/receipt.svg',
    'tax': 'assets/icons/tax.svg',

    // Home & Essentials
    'cash': 'assets/icons/cash.svg',
    'chemicals': 'assets/icons/chemicals.svg',
    'clothing': 'assets/icons/clothing.svg',
    'computer': 'assets/icons/computer.svg',
    'construction': 'assets/icons/construction.svg',
    'curryrice': 'assets/icons/curryrice.svg',
    'cutting': 'assets/icons/cutting.svg',
    'edit': 'assets/icons/edit.svg',
    'electronics': 'assets/icons/electronics.svg',
    'essentials': 'assets/icons/essentials.svg',
    'fertilizer': 'assets/icons/fertilizer.svg',
    'film': 'assets/icons/film.svg',
    'fire': 'assets/icons/fire.svg',
    'fuel': 'assets/icons/fuel.svg',
    'glassbottle': 'assets/icons/glassbottle.svg',
    'gold': 'assets/icons/gold.svg',
    'google': 'assets/icons/google.svg',
    'hf': 'assets/icons/HF.svg',
    'hindu': 'assets/icons/hindu.svg',
    'home': 'assets/icons/home.svg',
    'hotel': 'assets/icons/hotel.svg',
    'iron': 'assets/icons/iron.svg',
    'key': 'assets/icons/key.svg',
    'land': 'assets/icons/land.svg',
    'leaves': 'assets/icons/leaves.svg',
    'lightbulb': 'assets/icons/lightbulb.svg',
    'login': 'assets/icons/login.svg',
    'menuhorizontal': 'assets/icons/menu-horizontal.svg',
    'mouse': 'assets/icons/mouse.svg',
    'palmtree': 'assets/icons/palmtree.svg',
    'rent': 'assets/icons/rent.svg',
    'sale': 'assets/icons/sale.svg',
    'settings': 'assets/icons/settings.svg',
    'shoes': 'assets/icons/shoes.svg',
    'tablets': 'assets/icons/tablets.svg',
    'tag': 'assets/icons/tag.svg',
    'tobbaco': 'assets/icons/tobbaco.svg',
    'tools': 'assets/icons/tools.svg',
    'tractor': 'assets/icons/tractor.svg',
    'trash': 'assets/icons/trash.svg',
    'tree': 'assets/icons/tree.svg',
    'unlock': 'assets/icons/unlock.svg',
    'watch': 'assets/icons/watch.svg',
    'waterbottele': 'assets/icons/waterbottele.svg',
    'wifi': 'assets/icons/wifi.svg',
    'wood': 'assets/icons/wood.svg',
    'worker': 'assets/icons/worker.svg',
    'workers': 'assets/icons/workers.svg',
    'youtube': 'assets/icons/youtube.svg',
    'coke': 'assets/icons/cocacola.svg',

    // Food & Beverages
    'apple': 'assets/icons/apple.svg',
    'banana': 'assets/icons/banana.svg',
    'beans': 'assets/icons/beans.svg',
    'beer': 'assets/icons/beer.svg',
    'beverage': 'assets/icons/beverage.svg',
    'biscuit': 'assets/icons/biscuit.svg',
    'bread': 'assets/icons/bread.svg',
    'brinjal': 'assets/icons/brinjal.svg',
    'broccoli': 'assets/icons/broccoli.svg',
    'cabbage': 'assets/icons/cabbage.svg',
    'carrot': 'assets/icons/carrot.svg',
    'chicken': 'assets/icons/chicken.svg',
    'chili': 'assets/icons/chili.svg',
    'chocolate': 'assets/icons/chocolate.svg',
    'corn': 'assets/icons/corn.svg',
    'crab': 'assets/icons/crab.svg',
    'cutlery': 'assets/icons/cutlery.svg',
    'cylinder': 'assets/icons/cylinder.svg',
    'dinning': 'assets/icons/Dinning.svg',
    'drinks': 'assets/icons/drinks.svg',
    'egg': 'assets/icons/egg.svg',
    'fish': 'assets/icons/fish.svg',
    'flour': 'assets/icons/flour.svg',
    'fries': 'assets/icons/fries.svg',
    'garlic': 'assets/icons/garlic.svg',
    'grape': 'assets/icons/grape.svg',
    'greens': 'assets/icons/greens.svg',
    'groceries': 'assets/icons/groceries.svg',
    'hamburger': 'assets/icons/hamburger.svg',
    'honey': 'assets/icons/honey.svg',
    'icecream': 'assets/icons/icecream.svg',
    'instantfood': 'assets/icons/instantfood.svg',
    'juice': 'assets/icons/juice.svg',
    'knifes': 'assets/icons/knifes.svg',
    'lemon': 'assets/icons/lemon.svg',
    'milk': 'assets/icons/milk.svg',
    'mocktail': 'assets/icons/mocktail.svg',
    'mushroom': 'assets/icons/mushroom.svg',
    'noodles': 'assets/icons/noodles.svg',
    'oils': 'assets/icons/oils.svg',
    'onion': 'assets/icons/onion.svg',
    'orange': 'assets/icons/orange.svg',
    'peas': 'assets/icons/peas.svg',
    'pineapple': 'assets/icons/pineapple.svg',
    'pizza': 'assets/icons/pizza.svg',
    'potatoes': 'assets/icons/potatoes.svg',
    'sandwich': 'assets/icons/sandwich.svg',
    'shrimp': 'assets/icons/shrimp.svg',
    'steak': 'assets/icons/steak.svg',
    'strawberry': 'assets/icons/strawberry.svg',
    'streetf': 'assets/icons/streetf.svg',
    'tomato': 'assets/icons/tomato.svg',
    'vegetables': 'assets/icons/vegetables.svg',
    'watermelon': 'assets/icons/watermelon.svg',
    'wheat': 'assets/icons/wheat.svg',
    'zomato': 'assets/icons/zomato.svg',
  };


  // Get icons by category
 static Map<String, List<String>> getCategoryIcons() {
   return {
     'Banking & Money': [
       'axis', 'icici', 'sbi', 'anz', 'au', 'bob', 'citibank', 'deutsche', 'hdfc', 'idbi', 'kotak', 'union', 'boi', 'pay', 'hsbc', 'idfc', 'googlepay', 'induslnd', 'paytm', 'pnb', 'yesbank', 'cggb', 'amazonpay', 'applepay'
     ],
     'Shopping & Payments': [
       'airticket', 'amazon', 'creditcard', 'flipkart', 'mastercard', 'shopping', 'shoppingbag', 'transactions',  'atm', 'charity', 'close', 'closed', 'debt', 'deposit', 'fine', 'installment', 'insurance', 'lent', 'loan', 'loanopen'
     ],
     'Transportation': [
       'atc', 'auto', 'banktransfer', 'bike', 'bus', 'cab', 'car', 'honda', 'mitsubishi', 'petrol', 'train', 'transport'
     ],
     'Bills & Utilities': [
       'bill', 'electricitybill', 'receipt', 'tax', 'utilities'
     ],
     'Home & Essentials': [
       'applaince', 'cash', 'chemicals', 'clothing', 'computer', 'construction', 'curryrice', 'cutting', 'edit', 'electronics', 'essentials', 'fertilizer', 'film', 'fire', 'fuel', 'glassbottle', 'gold', 'google', 'hf', 'hindu', 'home', 'hotel', 'iron', 'key', 'land', 'leaves', 'lightbulb', 'login', 'menuhorizontal', 'mouse', 'palmtree', 'rent', 'sale', 'settings', 'shoes', 'tablets', 'tag', 'tobbaco', 'tools', 'tractor', 'trash', 'tree', 'unlock', 'watch', 'waterbottele', 'wifi', 'wood', 'worker', 'workers', 'youtube'
     ],
     'Food & Beverages': [
       'coke', 'apple', 'banana', 'beans', 'beer', 'beverage', 'biscuit', 'bread', 'brinjal', 'broccoli', 'cabbage', 'carrot', 'chicken', 'chili', 'chocolate', 'corn', 'crab', 'cutlery', 'cylinder', 'dinning', 'drinks', 'egg', 'fish', 'flour', 'fries', 'garlic', 'grape', 'greens', 'groceries', 'hamburger', 'honey', 'icecream', 'instantfood', 'juice', 'knifes', 'lemon', 'milk', 'mocktail', 'mushroom', 'noodles', 'oils', 'onion', 'orange', 'peas', 'pineapple', 'pizza', 'potatoes', 'sandwich', 'shrimp', 'steak', 'strawberry', 'streetf', 'tomato', 'vegetables', 'watermelon', 'wheat', 'zomato'
     ],
     'Other': [
       'ac', 'accomidation', 'flight', 'fridge', 'furniture', 'help', 'idea', 'oiler', 'parking', 'pin', 'silver', 'spares', 'sports', 'sprout', 'stocks', 'unknown', 'chef', 'farmer', 'gas', 'knife', 'man', 'man2', 'man3', 'map', 'nodata', 'photographer', 'pot', 'user', 'woman'
     ],
   };
 }
  static Widget getIcon(String? label, {double size = 24.0}) {
    if (label == null || label.isEmpty) {
      print('No label provided, using default icon');
      return SvgPicture.asset(
        'assests/icons/AU.svg', // Default icon path
        width: size,
        height: size,
      );
    }
    final path = iconMap[label];
    if (path != null) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
      );
    }
    print('No icon found for label: $label'); // Debug print
    return SvgPicture.asset(
      'assets/icons/receipt.svg', // Default icon path
      width: size,
      height: size,
    );
  }

  static String getIconPath(String label) {
    return iconMap[label] ?? 'assets/icons/receipt.svg'; // Default icon path
  }
}

