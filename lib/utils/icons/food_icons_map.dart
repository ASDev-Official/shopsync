import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icon mapping data structure for food and beverage icons
class FoodIconMapping {
  final String identifier;
  final String displayName;
  final String assetPath;

  const FoodIconMapping({
    required this.identifier,
    required this.displayName,
    required this.assetPath,
  });

  /// Create a widget to display the SVG icon
  Widget buildIcon({
    double? width = 24,
    double? height = 24,
    Color? color,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

class FoodIconMap {
  static const Map<String, FoodIconMapping> _foodIconMap = {
    // Bakery
    'baguette': FoodIconMapping(
      identifier: 'baguette',
      displayName: 'Baguette',
      assetPath: 'assets/icons/food_icons/bakery/icons8-baguette-50.svg',
    ),
    'bake': FoodIconMapping(
      identifier: 'bake',
      displayName: 'Bake',
      assetPath: 'assets/icons/food_icons/bakery/icons8-bake-50.svg',
    ),
    'biscuits': FoodIconMapping(
      identifier: 'biscuits',
      displayName: 'Biscuits',
      assetPath: 'assets/icons/food_icons/bakery/icons8-biscuits-50.svg',
    ),
    'bread': FoodIconMapping(
      identifier: 'bread',
      displayName: 'Bread',
      assetPath: 'assets/icons/food_icons/bakery/icons8-bread-50.svg',
    ),
    'breadAndRollingPin': FoodIconMapping(
      identifier: 'breadAndRollingPin',
      displayName: 'Rolling Pin Bread',
      assetPath:
          'assets/icons/food_icons/bakery/icons8-bread-and-rolling-pin-50.svg',
    ),
    'breadAndRye': FoodIconMapping(
      identifier: 'breadAndRye',
      displayName: 'Bread and Rye',
      assetPath: 'assets/icons/food_icons/bakery/icons8-bread-and-rye-50.svg',
    ),
    'breadLoaf': FoodIconMapping(
      identifier: 'breadLoaf',
      displayName: 'Bread Loaf',
      assetPath: 'assets/icons/food_icons/bakery/icons8-bread-loaf-50.svg',
    ),
    'brezel': FoodIconMapping(
      identifier: 'brezel',
      displayName: 'Brezel',
      assetPath: 'assets/icons/food_icons/bakery/icons8-brezel-50.svg',
    ),
    'gingerbreadHouse': FoodIconMapping(
      identifier: 'gingerbreadHouse',
      displayName: 'Gingerbread House',
      assetPath:
          'assets/icons/food_icons/bakery/icons8-gingerbread-house-50.svg',
    ),
    'merryPie': FoodIconMapping(
      identifier: 'merryPie',
      displayName: 'Merry Pie',
      assetPath: 'assets/icons/food_icons/bakery/icons8-merry-pie-50.svg',
    ),
    'naan': FoodIconMapping(
      identifier: 'naan',
      displayName: 'Naan',
      assetPath: 'assets/icons/food_icons/bakery/icons8-naan-50.svg',
    ),
    'pretzel': FoodIconMapping(
      identifier: 'pretzel',
      displayName: 'Pretzel',
      assetPath: 'assets/icons/food_icons/bakery/icons8-pretzel-50.svg',
    ),

    // Berries
    'blueberry': FoodIconMapping(
      identifier: 'blueberry',
      displayName: 'Blueberry',
      assetPath: 'assets/icons/food_icons/berries/icons8-blueberry-50.svg',
    ),
    'cherry': FoodIconMapping(
      identifier: 'cherry',
      displayName: 'Cherry',
      assetPath: 'assets/icons/food_icons/berries/icons8-cherry-50.svg',
    ),
    'grapes': FoodIconMapping(
      identifier: 'grapes',
      displayName: 'Grapes',
      assetPath: 'assets/icons/food_icons/berries/icons8-grapes-50.svg',
    ),
    'raspberry': FoodIconMapping(
      identifier: 'raspberry',
      displayName: 'Raspberry',
      assetPath: 'assets/icons/food_icons/berries/icons8-raspberry-50.svg',
    ),
    'strawberry': FoodIconMapping(
      identifier: 'strawberry',
      displayName: 'Strawberry',
      assetPath: 'assets/icons/food_icons/berries/icons8-strawberry-50.svg',
    ),
    'strawberry2': FoodIconMapping(
      identifier: 'strawberry2',
      displayName: 'Strawberry (Alt)',
      assetPath: 'assets/icons/food_icons/berries/icons8-strawberry-50-2.svg',
    ),

    // Desserts
    'appleJam': FoodIconMapping(
      identifier: 'appleJam',
      displayName: 'Apple Jam',
      assetPath: 'assets/icons/food_icons/desserts/icons8-apple-jam-50.svg',
    ),
    'bananaSplit': FoodIconMapping(
      identifier: 'bananaSplit',
      displayName: 'Banana Split',
      assetPath: 'assets/icons/food_icons/desserts/icons8-banana-split-50.svg',
    ),
    'berryJam': FoodIconMapping(
      identifier: 'berryJam',
      displayName: 'Berry Jam',
      assetPath: 'assets/icons/food_icons/desserts/icons8-berry-jam-50.svg',
    ),
    'candyDessert': FoodIconMapping(
      identifier: 'candyDessert',
      displayName: 'Candy',
      assetPath: 'assets/icons/food_icons/desserts/icons8-candy-50.svg',
    ),
    'cheesecakeDessert': FoodIconMapping(
      identifier: 'cheesecakeDessert',
      displayName: 'Cheesecake',
      assetPath: 'assets/icons/food_icons/desserts/icons8-cheesecake-50.svg',
    ),
    'cherryCheesecake': FoodIconMapping(
      identifier: 'cherryCheesecake',
      displayName: 'Cherry Cheesecake',
      assetPath:
          'assets/icons/food_icons/desserts/icons8-cherry-cheesecake-50.svg',
    ),
    'chocolateBarDessert': FoodIconMapping(
      identifier: 'chocolateBarDessert',
      displayName: 'Chocolate Bar',
      assetPath: 'assets/icons/food_icons/desserts/icons8-chocolate-bar-50.svg',
    ),
    'chocolateBarWhite': FoodIconMapping(
      identifier: 'chocolateBarWhite',
      displayName: 'White Chocolate Bar',
      assetPath:
          'assets/icons/food_icons/desserts/icons8-chocolate-bar-white-50.svg',
    ),
    'cottonCandy': FoodIconMapping(
      identifier: 'cottonCandy',
      displayName: 'Cotton Candy',
      assetPath: 'assets/icons/food_icons/desserts/icons8-cotton-candy-50.svg',
    ),
    'dessertGeneral': FoodIconMapping(
      identifier: 'dessertGeneral',
      displayName: 'Dessert',
      assetPath: 'assets/icons/food_icons/desserts/icons8-dessert-50.svg',
    ),
    'iceCreamConeDessert': FoodIconMapping(
      identifier: 'iceCreamConeDessert',
      displayName: 'Ice Cream Cone',
      assetPath:
          'assets/icons/food_icons/desserts/icons8-ice-cream-cone-50.svg',
    ),
    'iceCreamSundae': FoodIconMapping(
      identifier: 'iceCreamSundae',
      displayName: 'Ice Cream Sundae',
      assetPath:
          'assets/icons/food_icons/desserts/icons8-ice-cream-sundae-50.svg',
    ),
    'jamDessert': FoodIconMapping(
      identifier: 'jamDessert',
      displayName: 'Jam',
      assetPath: 'assets/icons/food_icons/desserts/icons8-jam-50.svg',
    ),
    'jelly': FoodIconMapping(
      identifier: 'jelly',
      displayName: 'Jelly',
      assetPath: 'assets/icons/food_icons/desserts/icons8-jelly-50.svg',
    ),
    'meltingIceCream': FoodIconMapping(
      identifier: 'meltingIceCream',
      displayName: 'Melting Ice Cream',
      assetPath:
          'assets/icons/food_icons/desserts/icons8-melting-ice-cream-50.svg',
    ),
    'pastelDeNata': FoodIconMapping(
      identifier: 'pastelDeNata',
      displayName: 'Pastel de Nata',
      assetPath:
          'assets/icons/food_icons/desserts/icons8-pastel-de-nata-50.svg',
    ),
    'strawberryCheesecake': FoodIconMapping(
      identifier: 'strawberryCheesecake',
      displayName: 'Strawberry Cheesecake',
      assetPath:
          'assets/icons/food_icons/desserts/icons8-strawberry-cheesecake-50.svg',
    ),
    'sweets': FoodIconMapping(
      identifier: 'sweets',
      displayName: 'Sweets',
      assetPath: 'assets/icons/food_icons/desserts/icons8-sweets-50.svg',
    ),

    // Dishes
    'bagel': FoodIconMapping(
      identifier: 'bagel',
      displayName: 'Bagel',
      assetPath: 'assets/icons/food_icons/dishes/icons8-bagel-50.svg',
    ),
    'bento': FoodIconMapping(
      identifier: 'bento',
      displayName: 'Bento',
      assetPath: 'assets/icons/food_icons/dishes/icons8-bento-50.svg',
    ),
    'caviar': FoodIconMapping(
      identifier: 'caviar',
      displayName: 'Caviar',
      assetPath: 'assets/icons/food_icons/dishes/icons8-caviar-50.svg',
    ),
    'cheese': FoodIconMapping(
      identifier: 'cheese',
      displayName: 'Cheese',
      assetPath: 'assets/icons/food_icons/dishes/icons8-cheese-50.svg',
    ),
    'chocolateSpread': FoodIconMapping(
      identifier: 'chocolateSpread',
      displayName: 'Chocolate Spread',
      assetPath:
          'assets/icons/food_icons/dishes/icons8-chocolate-spread-50.svg',
    ),
    'dimSum': FoodIconMapping(
      identifier: 'dimSum',
      displayName: 'Dim Sum',
      assetPath: 'assets/icons/food_icons/dishes/icons8-dim-sum-50.svg',
    ),
    'dolmades': FoodIconMapping(
      identifier: 'dolmades',
      displayName: 'Dolmades',
      assetPath: 'assets/icons/food_icons/dishes/icons8-dolmades-50.svg',
    ),
    'fishAndVegetables': FoodIconMapping(
      identifier: 'fishAndVegetables',
      displayName: 'Fish and Vegetables',
      assetPath:
          'assets/icons/food_icons/dishes/icons8-fish-and-vegetables-50.svg',
    ),
    'fondue': FoodIconMapping(
      identifier: 'fondue',
      displayName: 'Fondue',
      assetPath: 'assets/icons/food_icons/dishes/icons8-fondue-50.svg',
    ),
    'foodAndWine': FoodIconMapping(
      identifier: 'foodAndWine',
      displayName: 'Food and Wine',
      assetPath: 'assets/icons/food_icons/dishes/icons8-food-and-wine-50.svg',
    ),
    'greekSalad': FoodIconMapping(
      identifier: 'greekSalad',
      displayName: 'Greek Salad',
      assetPath: 'assets/icons/food_icons/dishes/icons8-greek-salad-50.svg',
    ),
    'guacamole': FoodIconMapping(
      identifier: 'guacamole',
      displayName: 'Guacamole',
      assetPath: 'assets/icons/food_icons/dishes/icons8-guacamole-50.svg',
    ),
    'gyoza': FoodIconMapping(
      identifier: 'gyoza',
      displayName: 'Gyoza',
      assetPath: 'assets/icons/food_icons/dishes/icons8-gyoza-50.svg',
    ),
    'lasagna': FoodIconMapping(
      identifier: 'lasagna',
      displayName: 'Lasagna',
      assetPath: 'assets/icons/food_icons/dishes/icons8-lasagna-50.svg',
    ),
    'lunchbox': FoodIconMapping(
      identifier: 'lunchbox',
      displayName: 'Lunchbox',
      assetPath: 'assets/icons/food_icons/dishes/icons8-lunchbox-50.svg',
    ),
    'noodles': FoodIconMapping(
      identifier: 'noodles',
      displayName: 'Noodles',
      assetPath: 'assets/icons/food_icons/dishes/icons8-noodles-50.svg',
    ),
    'omlette': FoodIconMapping(
      identifier: 'omlette',
      displayName: 'Omelette',
      assetPath: 'assets/icons/food_icons/dishes/icons8-omlette-50.svg',
    ),
    'paella': FoodIconMapping(
      identifier: 'paella',
      displayName: 'Paella',
      assetPath: 'assets/icons/food_icons/dishes/icons8-paella-50.svg',
    ),
    'pancakeStack': FoodIconMapping(
      identifier: 'pancakeStack',
      displayName: 'Pancake Stack',
      assetPath: 'assets/icons/food_icons/dishes/icons8-pancake-stack-50.svg',
    ),
    'porridge': FoodIconMapping(
      identifier: 'porridge',
      displayName: 'Porridge',
      assetPath: 'assets/icons/food_icons/dishes/icons8-porridge-50.svg',
    ),
    'riceBowl': FoodIconMapping(
      identifier: 'riceBowl',
      displayName: 'Rice Bowl',
      assetPath: 'assets/icons/food_icons/dishes/icons8-rice-bowl-50.svg',
    ),
    'riceBowl2': FoodIconMapping(
      identifier: 'riceBowl2',
      displayName: 'Rice Bowl (Alt)',
      assetPath: 'assets/icons/food_icons/dishes/icons8-rice-bowl-50-2.svg',
    ),
    'saladDish': FoodIconMapping(
      identifier: 'saladDish',
      displayName: 'Salad',
      assetPath: 'assets/icons/food_icons/dishes/icons8-salad-50.svg',
    ),
    'salamiPizza': FoodIconMapping(
      identifier: 'salamiPizza',
      displayName: 'Salami Pizza',
      assetPath: 'assets/icons/food_icons/dishes/icons8-salami-pizza-50.svg',
    ),
    'salmonSushi': FoodIconMapping(
      identifier: 'salmonSushi',
      displayName: 'Salmon Sushi',
      assetPath: 'assets/icons/food_icons/dishes/icons8-salmon-sushi-50.svg',
    ),
    'sandwichWithFriedEgg': FoodIconMapping(
      identifier: 'sandwichWithFriedEgg',
      displayName: 'Sandwich with Fried Egg',
      assetPath:
          'assets/icons/food_icons/dishes/icons8-sandwich-with-fried-egg-50.svg',
    ),
    'sauce': FoodIconMapping(
      identifier: 'sauce',
      displayName: 'Sauce',
      assetPath: 'assets/icons/food_icons/dishes/icons8-sauce-50.svg',
    ),
    'seafoodDish': FoodIconMapping(
      identifier: 'seafoodDish',
      displayName: 'Seafood',
      assetPath: 'assets/icons/food_icons/dishes/icons8-seafood-50.svg',
    ),
    'spaghetti': FoodIconMapping(
      identifier: 'spaghetti',
      displayName: 'Spaghetti',
      assetPath: 'assets/icons/food_icons/dishes/icons8-spaghetti-50.svg',
    ),
    'spamCan': FoodIconMapping(
      identifier: 'spamCan',
      displayName: 'Spam Can',
      assetPath: 'assets/icons/food_icons/dishes/icons8-spam-can-50.svg',
    ),
    'springRoll': FoodIconMapping(
      identifier: 'springRoll',
      displayName: 'Spring Roll',
      assetPath: 'assets/icons/food_icons/dishes/icons8-spring-roll-50.svg',
    ),
    'sunnySideUpEggs': FoodIconMapping(
      identifier: 'sunnySideUpEggs',
      displayName: 'Sunny Side Up Eggs',
      assetPath:
          'assets/icons/food_icons/dishes/icons8-sunny-side-up-eggs-50.svg',
    ),
    'sushiDish': FoodIconMapping(
      identifier: 'sushiDish',
      displayName: 'Sushi',
      assetPath: 'assets/icons/food_icons/dishes/icons8-sushi-50.svg',
    ),
    'tapas': FoodIconMapping(
      identifier: 'tapas',
      displayName: 'Tapas',
      assetPath: 'assets/icons/food_icons/dishes/icons8-tapas-50.svg',
    ),
    'tinCan': FoodIconMapping(
      identifier: 'tinCan',
      displayName: 'Tin Can',
      assetPath: 'assets/icons/food_icons/dishes/icons8-tin-can-50.svg',
    ),
    'toast': FoodIconMapping(
      identifier: 'toast',
      displayName: 'Toast',
      assetPath: 'assets/icons/food_icons/dishes/icons8-toast-50.svg',
    ),
    'yogurt': FoodIconMapping(
      identifier: 'yogurt',
      displayName: 'Yogurt',
      assetPath: 'assets/icons/food_icons/dishes/icons8-yogurt-50.svg',
    ),

    // Drinks
    'alcoholicBeverageLicensing': FoodIconMapping(
      identifier: 'alcoholicBeverageLicensing',
      displayName: 'Alcoholic Beverage',
      assetPath:
          'assets/icons/food_icons/drinks/icons8-alcoholic-beverage-licensing-50.svg',
    ),
    'coconutMilk': FoodIconMapping(
      identifier: 'coconutMilk',
      displayName: 'Coconut Milk',
      assetPath: 'assets/icons/food_icons/drinks/icons8-coconut-milk-50.svg',
    ),
    'coffeeCapsule': FoodIconMapping(
      identifier: 'coffeeCapsule',
      displayName: 'Coffee Capsule',
      assetPath: 'assets/icons/food_icons/drinks/icons8-coffee-capsule-50.svg',
    ),
    'colaDrink': FoodIconMapping(
      identifier: 'colaDrink',
      displayName: 'Cola',
      assetPath: 'assets/icons/food_icons/drinks/icons8-cola-50.svg',
    ),
    'greenTea': FoodIconMapping(
      identifier: 'greenTea',
      displayName: 'Green Tea',
      assetPath: 'assets/icons/food_icons/drinks/icons8-green-tea-50.svg',
    ),
    'hempMilk': FoodIconMapping(
      identifier: 'hempMilk',
      displayName: 'Hemp Milk',
      assetPath: 'assets/icons/food_icons/drinks/icons8-hemp-milk-50.svg',
    ),
    'hotChocolateDrink': FoodIconMapping(
      identifier: 'hotChocolateDrink',
      displayName: 'Hot Chocolate',
      assetPath: 'assets/icons/food_icons/drinks/icons8-hot-chocolate-50.svg',
    ),
    'lemonade': FoodIconMapping(
      identifier: 'lemonade',
      displayName: 'Lemonade',
      assetPath: 'assets/icons/food_icons/drinks/icons8-lemonade-50.svg',
    ),
    'milkBottle': FoodIconMapping(
      identifier: 'milkBottle',
      displayName: 'Milk Bottle',
      assetPath: 'assets/icons/food_icons/drinks/icons8-milk-bottle-50.svg',
    ),
    'milkCarton': FoodIconMapping(
      identifier: 'milkCarton',
      displayName: 'Milk Carton',
      assetPath: 'assets/icons/food_icons/drinks/icons8-milk-carton-50.svg',
    ),
    'mulledWine': FoodIconMapping(
      identifier: 'mulledWine',
      displayName: 'Mulled Wine',
      assetPath: 'assets/icons/food_icons/drinks/icons8-mulled-wine-50.svg',
    ),
    'oatMilk': FoodIconMapping(
      identifier: 'oatMilk',
      displayName: 'Oat Milk',
      assetPath: 'assets/icons/food_icons/drinks/icons8-oat-milk-50.svg',
    ),
    'orangeJuiceDrink': FoodIconMapping(
      identifier: 'orangeJuiceDrink',
      displayName: 'Orange Juice',
      assetPath: 'assets/icons/food_icons/drinks/icons8-orange-juice-50.svg',
    ),
    'teacupSet': FoodIconMapping(
      identifier: 'teacupSet',
      displayName: 'Teacup Set',
      assetPath: 'assets/icons/food_icons/drinks/icons8-teacup-set-50.svg',
    ),
    'theToast': FoodIconMapping(
      identifier: 'theToast',
      displayName: 'The Toast',
      assetPath: 'assets/icons/food_icons/drinks/icons8-the-toast-50.svg',
    ),
    'wineAndGlass': FoodIconMapping(
      identifier: 'wineAndGlass',
      displayName: 'Wine and Glass',
      assetPath: 'assets/icons/food_icons/drinks/icons8-wine-and-glass-50.svg',
    ),

    // Fastfood
    'baoBun': FoodIconMapping(
      identifier: 'baoBun',
      displayName: 'Bao Bun',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-bao-bun-50.svg',
    ),
    'bittenSandwich': FoodIconMapping(
      identifier: 'bittenSandwich',
      displayName: 'Bitten Sandwich',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-bitten-sandwich-50.svg',
    ),
    'boxOfCereal': FoodIconMapping(
      identifier: 'boxOfCereal',
      displayName: 'Box of Cereal',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-box-of-cereal-50.svg',
    ),
    'burrito': FoodIconMapping(
      identifier: 'burrito',
      displayName: 'Burrito',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-burrito-50.svg',
    ),
    'cereal': FoodIconMapping(
      identifier: 'cereal',
      displayName: 'Cereal',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-cereal-50.svg',
    ),
    'chickenAndWaffle': FoodIconMapping(
      identifier: 'chickenAndWaffle',
      displayName: 'Chicken and Waffle',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-chicken-and-waffle-50.svg',
    ),
    'chineseFriedRice': FoodIconMapping(
      identifier: 'chineseFriedRice',
      displayName: 'Chinese Fried Rice',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-chinese-fried-rice-50.svg',
    ),
    'chineseNoodle': FoodIconMapping(
      identifier: 'chineseNoodle',
      displayName: 'Chinese Noodle',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-chinese-noodle-50.svg',
    ),
    'frenchFries': FoodIconMapping(
      identifier: 'frenchFries',
      displayName: 'French Fries',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-french-fries-50.svg',
    ),
    'friedChicken': FoodIconMapping(
      identifier: 'friedChicken',
      displayName: 'Fried Chicken',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-fried-chicken-50.svg',
    ),
    'fry': FoodIconMapping(
      identifier: 'fry',
      displayName: 'Fry',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-fry-50.svg',
    ),
    'hamburger': FoodIconMapping(
      identifier: 'hamburger',
      displayName: 'Hamburger',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-hamburger-50.svg',
    ),
    'hotDog': FoodIconMapping(
      identifier: 'hotDog',
      displayName: 'Hot Dog',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-hot-dog-50.svg',
    ),
    'kfcChicken': FoodIconMapping(
      identifier: 'kfcChicken',
      displayName: 'KFC Chicken',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-kfc-chicken-50.svg',
    ),
    'mcdonaldsFrenchFries': FoodIconMapping(
      identifier: 'mcdonaldsFrenchFries',
      displayName: 'McDonald\'s French Fries',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-mcdonald`s-french-fries-50.svg',
    ),
    'nachos': FoodIconMapping(
      identifier: 'nachos',
      displayName: 'Nachos',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-nachos-50.svg',
    ),
    'pizzaFastfood': FoodIconMapping(
      identifier: 'pizzaFastfood',
      displayName: 'Pizza',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-pizza-50.svg',
    ),
    'pizzaFiveEighths': FoodIconMapping(
      identifier: 'pizzaFiveEighths',
      displayName: 'Pizza Five Eighths',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-pizza-five-eighths-50.svg',
    ),
    'plasticFoodContainer': FoodIconMapping(
      identifier: 'plasticFoodContainer',
      displayName: 'Plastic Food Container',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-plastic-food-container-50.svg',
    ),
    'popcornFastfood': FoodIconMapping(
      identifier: 'popcornFastfood',
      displayName: 'Popcorn',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-popcorn-50.svg',
    ),
    'potatoChips': FoodIconMapping(
      identifier: 'potatoChips',
      displayName: 'Potato Chips',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-potato-chips-50.svg',
    ),
    'quesadilla': FoodIconMapping(
      identifier: 'quesadilla',
      displayName: 'Quesadilla',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-quesadilla-50.svg',
    ),
    'refreshments': FoodIconMapping(
      identifier: 'refreshments',
      displayName: 'Refreshments',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-refreshments-50.svg',
    ),
    'sandwichFastfood': FoodIconMapping(
      identifier: 'sandwichFastfood',
      displayName: 'Sandwich',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-sandwich-50.svg',
    ),
    'streetFood': FoodIconMapping(
      identifier: 'streetFood',
      displayName: 'Street Food',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-street-food-50.svg',
    ),
    'taco': FoodIconMapping(
      identifier: 'taco',
      displayName: 'Taco',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-taco-50.svg',
    ),
    'takeAwayFood': FoodIconMapping(
      identifier: 'takeAwayFood',
      displayName: 'Take Away Food',
      assetPath:
          'assets/icons/food_icons/fastfood/icons8-take-away-food-50.svg',
    ),
    'wrap': FoodIconMapping(
      identifier: 'wrap',
      displayName: 'Wrap',
      assetPath: 'assets/icons/food_icons/fastfood/icons8-wrap-50.svg',
    ),

    // Fruits
    'appleFruit': FoodIconMapping(
      identifier: 'appleFruit',
      displayName: 'Apple',
      assetPath: 'assets/icons/food_icons/fruits/icons8-apple-fruit-50.svg',
    ),
    'applesPlate': FoodIconMapping(
      identifier: 'applesPlate',
      displayName: 'Apples on Plate',
      assetPath: 'assets/icons/food_icons/fruits/icons8-apples--plate-50.svg',
    ),
    'applesPlate2': FoodIconMapping(
      identifier: 'applesPlate2',
      displayName: 'Apples Plate (Alt)',
      assetPath: 'assets/icons/food_icons/fruits/icons8-apples-plate-50.svg',
    ),
    'apricot': FoodIconMapping(
      identifier: 'apricot',
      displayName: 'Apricot',
      assetPath: 'assets/icons/food_icons/fruits/icons8-apricot-50.svg',
    ),
    'avocado': FoodIconMapping(
      identifier: 'avocado',
      displayName: 'Avocado',
      assetPath: 'assets/icons/food_icons/fruits/icons8-avocado-50.svg',
    ),
    'badBanana': FoodIconMapping(
      identifier: 'badBanana',
      displayName: 'Bad Banana',
      assetPath: 'assets/icons/food_icons/fruits/icons8-bad-banana-50.svg',
    ),
    'badOrange': FoodIconMapping(
      identifier: 'badOrange',
      displayName: 'Bad Orange',
      assetPath: 'assets/icons/food_icons/fruits/icons8-bad-orange-50.svg',
    ),
    'badPear': FoodIconMapping(
      identifier: 'badPear',
      displayName: 'Bad Pear',
      assetPath: 'assets/icons/food_icons/fruits/icons8-bad-pear-50.svg',
    ),
    'banana': FoodIconMapping(
      identifier: 'banana',
      displayName: 'Banana',
      assetPath: 'assets/icons/food_icons/fruits/icons8-banana-50.svg',
    ),
    'citrus': FoodIconMapping(
      identifier: 'citrus',
      displayName: 'Citrus',
      assetPath: 'assets/icons/food_icons/fruits/icons8-citrus-50.svg',
    ),
    'citrus2': FoodIconMapping(
      identifier: 'citrus2',
      displayName: 'Citrus (Alt)',
      assetPath: 'assets/icons/food_icons/fruits/icons8-citrus-50-2.svg',
    ),
    'coconut': FoodIconMapping(
      identifier: 'coconut',
      displayName: 'Coconut',
      assetPath: 'assets/icons/food_icons/fruits/icons8-coconut-50.svg',
    ),
    'coconut2': FoodIconMapping(
      identifier: 'coconut2',
      displayName: 'Coconut (Alt)',
      assetPath: 'assets/icons/food_icons/fruits/icons8-coconut-50-2.svg',
    ),
    'cucumber': FoodIconMapping(
      identifier: 'cucumber',
      displayName: 'Cucumber',
      assetPath: 'assets/icons/food_icons/fruits/icons8-cucumber-50.svg',
    ),
    'cutMelon': FoodIconMapping(
      identifier: 'cutMelon',
      displayName: 'Cut Melon',
      assetPath: 'assets/icons/food_icons/fruits/icons8-cut-melon-50.svg',
    ),
    'cutWatermelon': FoodIconMapping(
      identifier: 'cutWatermelon',
      displayName: 'Cut Watermelon',
      assetPath: 'assets/icons/food_icons/fruits/icons8-cut-watermelon-50.svg',
    ),
    'dateFruit': FoodIconMapping(
      identifier: 'dateFruit',
      displayName: 'Date Fruit',
      assetPath: 'assets/icons/food_icons/fruits/icons8-date-fruit-50.svg',
    ),
    'dragonFruit': FoodIconMapping(
      identifier: 'dragonFruit',
      displayName: 'Dragon Fruit',
      assetPath: 'assets/icons/food_icons/fruits/icons8-dragon-fruit-50.svg',
    ),
    'durian': FoodIconMapping(
      identifier: 'durian',
      displayName: 'Durian',
      assetPath: 'assets/icons/food_icons/fruits/icons8-durian-50.svg',
    ),
    'figFruit': FoodIconMapping(
      identifier: 'figFruit',
      displayName: 'Fig Fruit',
      assetPath: 'assets/icons/food_icons/fruits/icons8-fig-fruit-50.svg',
    ),
    'fruitBag': FoodIconMapping(
      identifier: 'fruitBag',
      displayName: 'Fruit Bag',
      assetPath: 'assets/icons/food_icons/fruits/icons8-fruit-bag-50.svg',
    ),
    'groupOfFruits': FoodIconMapping(
      identifier: 'groupOfFruits',
      displayName: 'Group of Fruits',
      assetPath: 'assets/icons/food_icons/fruits/icons8-group-of-fruits-50.svg',
    ),
    'halfOrange': FoodIconMapping(
      identifier: 'halfOrange',
      displayName: 'Half Orange',
      assetPath: 'assets/icons/food_icons/fruits/icons8-half-orange-50.svg',
    ),
    'jackfruit': FoodIconMapping(
      identifier: 'jackfruit',
      displayName: 'Jackfruit',
      assetPath: 'assets/icons/food_icons/fruits/icons8-jackfruit-50.svg',
    ),
    'lime': FoodIconMapping(
      identifier: 'lime',
      displayName: 'Lime',
      assetPath: 'assets/icons/food_icons/fruits/icons8-lime-50.svg',
    ),
    'lychee': FoodIconMapping(
      identifier: 'lychee',
      displayName: 'Lychee',
      assetPath: 'assets/icons/food_icons/fruits/icons8-lychee-50.svg',
    ),
    'mango': FoodIconMapping(
      identifier: 'mango',
      displayName: 'Mango',
      assetPath: 'assets/icons/food_icons/fruits/icons8-mango-50.svg',
    ),
    'mangosteen': FoodIconMapping(
      identifier: 'mangosteen',
      displayName: 'Mangosteen',
      assetPath: 'assets/icons/food_icons/fruits/icons8-mangosteen-50.svg',
    ),
    'melon': FoodIconMapping(
      identifier: 'melon',
      displayName: 'Melon',
      assetPath: 'assets/icons/food_icons/fruits/icons8-melon-50.svg',
    ),
    'orange': FoodIconMapping(
      identifier: 'orange',
      displayName: 'Orange',
      assetPath: 'assets/icons/food_icons/fruits/icons8-orange-50.svg',
    ),
    'papaya': FoodIconMapping(
      identifier: 'papaya',
      displayName: 'Papaya',
      assetPath: 'assets/icons/food_icons/fruits/icons8-papaya-50.svg',
    ),
    'peach': FoodIconMapping(
      identifier: 'peach',
      displayName: 'Peach',
      assetPath: 'assets/icons/food_icons/fruits/icons8-peach-50.svg',
    ),
    'pear': FoodIconMapping(
      identifier: 'pear',
      displayName: 'Pear',
      assetPath: 'assets/icons/food_icons/fruits/icons8-pear-50.svg',
    ),
    'pears': FoodIconMapping(
      identifier: 'pears',
      displayName: 'Pears',
      assetPath: 'assets/icons/food_icons/fruits/icons8-pears-50.svg',
    ),
    'peeledBanana': FoodIconMapping(
      identifier: 'peeledBanana',
      displayName: 'Peeled Banana',
      assetPath: 'assets/icons/food_icons/fruits/icons8-peeled-banana-50.svg',
    ),
    'pineapple': FoodIconMapping(
      identifier: 'pineapple',
      displayName: 'Pineapple',
      assetPath: 'assets/icons/food_icons/fruits/icons8-pineapple-50.svg',
    ),
    'pomegranate': FoodIconMapping(
      identifier: 'pomegranate',
      displayName: 'Pomegranate',
      assetPath: 'assets/icons/food_icons/fruits/icons8-pomegranate-50.svg',
    ),
    'rambutan': FoodIconMapping(
      identifier: 'rambutan',
      displayName: 'Rambutan',
      assetPath: 'assets/icons/food_icons/fruits/icons8-rambutan-50.svg',
    ),
    'soursop': FoodIconMapping(
      identifier: 'soursop',
      displayName: 'Soursop',
      assetPath: 'assets/icons/food_icons/fruits/icons8-soursop-50.svg',
    ),
    'tangelo': FoodIconMapping(
      identifier: 'tangelo',
      displayName: 'Tangelo',
      assetPath: 'assets/icons/food_icons/fruits/icons8-tangelo-50.svg',
    ),
    'watermelon': FoodIconMapping(
      identifier: 'watermelon',
      displayName: 'Watermelon',
      assetPath: 'assets/icons/food_icons/fruits/icons8-watermelon-50.svg',
    ),
    'watermelon2': FoodIconMapping(
      identifier: 'watermelon2',
      displayName: 'Watermelon (Alt)',
      assetPath: 'assets/icons/food_icons/fruits/icons8-watermelon-50-2.svg',
    ),
    'wholeApple': FoodIconMapping(
      identifier: 'wholeApple',
      displayName: 'Whole Apple',
      assetPath: 'assets/icons/food_icons/fruits/icons8-whole-apple-50.svg',
    ),
    'wholeMelon': FoodIconMapping(
      identifier: 'wholeMelon',
      displayName: 'Whole Melon',
      assetPath: 'assets/icons/food_icons/fruits/icons8-whole-melon-50.svg',
    ),
    'wholeWatermelon': FoodIconMapping(
      identifier: 'wholeWatermelon',
      displayName: 'Whole Watermelon',
      assetPath:
          'assets/icons/food_icons/fruits/icons8-whole-watermelon-50.svg',
    ),

    // Vegetables
    'artichoke': FoodIconMapping(
      identifier: 'artichoke',
      displayName: 'Artichoke',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-artichoke-50.svg',
    ),
    'asparagus': FoodIconMapping(
      identifier: 'asparagus',
      displayName: 'Asparagus',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-asparagus-50.svg',
    ),
    'beet': FoodIconMapping(
      identifier: 'beet',
      displayName: 'Beet',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-beet-50.svg',
    ),
    'bokChoy': FoodIconMapping(
      identifier: 'bokChoy',
      displayName: 'Bok Choy',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-bok-choy-50.svg',
    ),
    'broccoli': FoodIconMapping(
      identifier: 'broccoli',
      displayName: 'Broccoli',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-broccoli-50.svg',
    ),
    'broccolini': FoodIconMapping(
      identifier: 'broccolini',
      displayName: 'Broccolini',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-broccolini-50.svg',
    ),
    'cabbage': FoodIconMapping(
      identifier: 'cabbage',
      displayName: 'Cabbage',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-cabbage-50.svg',
    ),
    'carrot': FoodIconMapping(
      identifier: 'carrot',
      displayName: 'Carrot',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-carrot-50.svg',
    ),
    'cauliflower': FoodIconMapping(
      identifier: 'cauliflower',
      displayName: 'Cauliflower',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-cauliflower-50.svg',
    ),
    'celery': FoodIconMapping(
      identifier: 'celery',
      displayName: 'Celery',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-celery-50.svg',
    ),
    'chard': FoodIconMapping(
      identifier: 'chard',
      displayName: 'Chard',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-chard-50.svg',
    ),
    'chiliPepper': FoodIconMapping(
      identifier: 'chiliPepper',
      displayName: 'Chili Pepper',
      assetPath:
          'assets/icons/food_icons/vegetables/icons8-chili-pepper-50.svg',
    ),
    'collardGreens': FoodIconMapping(
      identifier: 'collardGreens',
      displayName: 'Collard Greens',
      assetPath:
          'assets/icons/food_icons/vegetables/icons8-collard-greens-50.svg',
    ),
    'corn': FoodIconMapping(
      identifier: 'corn',
      displayName: 'Corn',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-corn-50.svg',
    ),
    'eggplant': FoodIconMapping(
      identifier: 'eggplant',
      displayName: 'Eggplant',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-eggplant-50.svg',
    ),
    'finocchio': FoodIconMapping(
      identifier: 'finocchio',
      displayName: 'Finocchio',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-finocchio-50.svg',
    ),
    'gailan': FoodIconMapping(
      identifier: 'gailan',
      displayName: 'Gailan',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-gailan-50.svg',
    ),
    'groupOfVegetables': FoodIconMapping(
      identifier: 'groupOfVegetables',
      displayName: 'Group of Vegetables',
      assetPath:
          'assets/icons/food_icons/vegetables/icons8-group-of-vegetables-50.svg',
    ),
    'kohlrabi': FoodIconMapping(
      identifier: 'kohlrabi',
      displayName: 'Kohlrabi',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-kohlrabi-50.svg',
    ),
    'leek': FoodIconMapping(
      identifier: 'leek',
      displayName: 'Leek',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-leek-50.svg',
    ),
    'lettuce': FoodIconMapping(
      identifier: 'lettuce',
      displayName: 'Lettuce',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-lettuce-50.svg',
    ),
    'onion': FoodIconMapping(
      identifier: 'onion',
      displayName: 'Onion',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-onion-50.svg',
    ),
    'pumpkin': FoodIconMapping(
      identifier: 'pumpkin',
      displayName: 'Pumpkin',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-pumpkin-50.svg',
    ),
    'radish': FoodIconMapping(
      identifier: 'radish',
      displayName: 'Radish',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-radish-50.svg',
    ),
    'soy': FoodIconMapping(
      identifier: 'soy',
      displayName: 'Soy',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-soy-50.svg',
    ),
    'spinach': FoodIconMapping(
      identifier: 'spinach',
      displayName: 'Spinach',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-spinach-50.svg',
    ),
    'squash': FoodIconMapping(
      identifier: 'squash',
      displayName: 'Squash',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-squash-50.svg',
    ),
    'sweetPotato': FoodIconMapping(
      identifier: 'sweetPotato',
      displayName: 'Sweet Potato',
      assetPath:
          'assets/icons/food_icons/vegetables/icons8-sweet-potato-50.svg',
    ),
    'tomato': FoodIconMapping(
      identifier: 'tomato',
      displayName: 'Tomato',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-tomato-50.svg',
    ),
    'tomatoes': FoodIconMapping(
      identifier: 'tomatoes',
      displayName: 'Tomatoes',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-tomatoes-50.svg',
    ),
    'vegetablesBag': FoodIconMapping(
      identifier: 'vegetablesBag',
      displayName: 'Vegetables Bag',
      assetPath:
          'assets/icons/food_icons/vegetables/icons8-vegetables-bag-50.svg',
    ),
    'vegetablesBox': FoodIconMapping(
      identifier: 'vegetablesBox',
      displayName: 'Vegetables Box',
      assetPath:
          'assets/icons/food_icons/vegetables/icons8-vegetables-box-50.svg',
    ),
    'whiteBeans': FoodIconMapping(
      identifier: 'whiteBeans',
      displayName: 'White Beans',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-white-beans-50.svg',
    ),
    'youChoy': FoodIconMapping(
      identifier: 'youChoy',
      displayName: 'You Choy',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-you-choy-50.svg',
    ),
    'zucchini': FoodIconMapping(
      identifier: 'zucchini',
      displayName: 'Zucchini',
      assetPath: 'assets/icons/food_icons/vegetables/icons8-zucchini-50.svg',
    ),

    // Ingredients
    'almondButter': FoodIconMapping(
      identifier: 'almondButter',
      displayName: 'Almond Butter',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-almond-butter-50.svg',
    ),
    'basil': FoodIconMapping(
      identifier: 'basil',
      displayName: 'Basil',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-basil-50.svg',
    ),
    'butter': FoodIconMapping(
      identifier: 'butter',
      displayName: 'Butter',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-butter-50.svg',
    ),
    'chiaSeeds': FoodIconMapping(
      identifier: 'chiaSeeds',
      displayName: 'Chia Seeds',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-chia-seeds-50.svg',
    ),
    'cinnamonSticks': FoodIconMapping(
      identifier: 'cinnamonSticks',
      displayName: 'Cinnamon Sticks',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-cinnamon-sticks-50.svg',
    ),
    'dozenEggs': FoodIconMapping(
      identifier: 'dozenEggs',
      displayName: 'Dozen Eggs',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-dozen-eggs-50.svg',
    ),
    'dressing': FoodIconMapping(
      identifier: 'dressing',
      displayName: 'Dressing',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-dressing-50.svg',
    ),
    'eggBasket': FoodIconMapping(
      identifier: 'eggBasket',
      displayName: 'Egg Basket',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-egg-basket-50.svg',
    ),
    'eggCarton': FoodIconMapping(
      identifier: 'eggCarton',
      displayName: 'Egg Carton',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-egg-carton-50.svg',
    ),
    'eggs': FoodIconMapping(
      identifier: 'eggs',
      displayName: 'Eggs',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-eggs-50.svg',
    ),
    'flaxSeeds': FoodIconMapping(
      identifier: 'flaxSeeds',
      displayName: 'Flax Seeds',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-flax-seeds-50.svg',
    ),
    'flourInPaperPackaging': FoodIconMapping(
      identifier: 'flourInPaperPackaging',
      displayName: 'Flour in Paper Packaging',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-flour-in-paper-packaging-50.svg',
    ),
    'flourOfRye': FoodIconMapping(
      identifier: 'flourOfRye',
      displayName: 'Flour of Rye',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-flour-of-rye-50.svg',
    ),
    'ginger': FoodIconMapping(
      identifier: 'ginger',
      displayName: 'Ginger',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-ginger-50.svg',
    ),
    'grainsOfRice': FoodIconMapping(
      identifier: 'grainsOfRice',
      displayName: 'Grains of Rice',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-grains-of-rice-50.svg',
    ),
    'hamper': FoodIconMapping(
      identifier: 'hamper',
      displayName: 'Hamper',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-hamper-50.svg',
    ),
    'honey': FoodIconMapping(
      identifier: 'honey',
      displayName: 'Honey',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-honey-50.svg',
    ),
    'honeyDipperWithHoneyDripping': FoodIconMapping(
      identifier: 'honeyDipperWithHoneyDripping',
      displayName: 'Honey Dipper with Honey Dripping',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-honey-dipper-with-honey-dripping-50.svg',
    ),
    'honeySpoon': FoodIconMapping(
      identifier: 'honeySpoon',
      displayName: 'Honey Spoon',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-honey-spoon-50.svg',
    ),
    'icingSugar': FoodIconMapping(
      identifier: 'icingSugar',
      displayName: 'Icing Sugar',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-icing-sugar-50.svg',
    ),
    'ingredients': FoodIconMapping(
      identifier: 'ingredients',
      displayName: 'Ingredients',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-ingredients-50.svg',
    ),
    'ingredientsForCooking': FoodIconMapping(
      identifier: 'ingredientsForCooking',
      displayName: 'Ingredients for Cooking',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-ingredients-for-cooking-50.svg',
    ),
    'ketchup': FoodIconMapping(
      identifier: 'ketchup',
      displayName: 'Ketchup',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-ketchup-50.svg',
    ),
    'lentil': FoodIconMapping(
      identifier: 'lentil',
      displayName: 'Lentil',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-lentil-50.svg',
    ),
    'listView': FoodIconMapping(
      identifier: 'listView',
      displayName: 'List View',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-list-view-50.svg',
    ),
    'mapleSyrup': FoodIconMapping(
      identifier: 'mapleSyrup',
      displayName: 'Maple Syrup',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-maple-syrup-50.svg',
    ),
    'mayonnaise': FoodIconMapping(
      identifier: 'mayonnaise',
      displayName: 'Mayonnaise',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-mayonnaise-50.svg',
    ),
    'mint': FoodIconMapping(
      identifier: 'mint',
      displayName: 'Mint',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-mint-50.svg',
    ),
    'mozzarella': FoodIconMapping(
      identifier: 'mozzarella',
      displayName: 'Mozzarella',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-mozzarella-50.svg',
    ),
    'mustard': FoodIconMapping(
      identifier: 'mustard',
      displayName: 'Mustard',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-mustard-50.svg',
    ),
    'oliveOil': FoodIconMapping(
      identifier: 'oliveOil',
      displayName: 'Olive Oil',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-olive-oil-50.svg',
    ),
    'oliveOilBottle': FoodIconMapping(
      identifier: 'oliveOilBottle',
      displayName: 'Olive Oil Bottle',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-olive-oil-bottle-50.svg',
    ),
    'peanutButter': FoodIconMapping(
      identifier: 'peanutButter',
      displayName: 'Peanut Butter',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-peanut-butter-50.svg',
    ),
    'pistachioSauce': FoodIconMapping(
      identifier: 'pistachioSauce',
      displayName: 'Pistachio Sauce',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-pistachio-sauce-50.svg',
    ),
    'quorn': FoodIconMapping(
      identifier: 'quorn',
      displayName: 'Quorn',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-quorn-50.svg',
    ),
    'raisins': FoodIconMapping(
      identifier: 'raisins',
      displayName: 'Raisins',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-raisins-50.svg',
    ),
    'riceVinegar': FoodIconMapping(
      identifier: 'riceVinegar',
      displayName: 'Rice Vinegar',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-rice-vinegar-50.svg',
    ),
    'rolledOats': FoodIconMapping(
      identifier: 'rolledOats',
      displayName: 'Rolled Oats',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-rolled-oats-50.svg',
    ),
    'saltShaker': FoodIconMapping(
      identifier: 'saltShaker',
      displayName: 'Salt Shaker',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-salt-shaker-50.svg',
    ),
    'sauceBottle': FoodIconMapping(
      identifier: 'sauceBottle',
      displayName: 'Sauce Bottle',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-sauce-bottle-50.svg',
    ),
    'sesame': FoodIconMapping(
      identifier: 'sesame',
      displayName: 'Sesame',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-sesame-50.svg',
    ),
    'sesameOil': FoodIconMapping(
      identifier: 'sesameOil',
      displayName: 'Sesame Oil',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-sesame-oil-50.svg',
    ),
    'soySauce': FoodIconMapping(
      identifier: 'soySauce',
      displayName: 'Soy Sauce',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-soy-sauce-50.svg',
    ),
    'spice': FoodIconMapping(
      identifier: 'spice',
      displayName: 'Spice',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-spice-50.svg',
    ),
    'spoonOfSugar': FoodIconMapping(
      identifier: 'spoonOfSugar',
      displayName: 'Spoon of Sugar',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-spoon-of-sugar-50.svg',
    ),
    'sugar': FoodIconMapping(
      identifier: 'sugar',
      displayName: 'Sugar',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-sugar-50.svg',
    ),
    'sugarCube': FoodIconMapping(
      identifier: 'sugarCube',
      displayName: 'Sugar Cube',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-sugar-cube-50.svg',
    ),
    'sugarCubes': FoodIconMapping(
      identifier: 'sugarCubes',
      displayName: 'Sugar Cubes',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-sugar-cubes-50.svg',
    ),
    'sunflowerButter': FoodIconMapping(
      identifier: 'sunflowerButter',
      displayName: 'Sunflower Butter',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-sunflower-butter-50.svg',
    ),
    'sunflowerOil': FoodIconMapping(
      identifier: 'sunflowerOil',
      displayName: 'Sunflower Oil',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-sunflower-oil-50.svg',
    ),
    'sweetener': FoodIconMapping(
      identifier: 'sweetener',
      displayName: 'Sweetener',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-sweetener-50.svg',
    ),
    'thyme': FoodIconMapping(
      identifier: 'thyme',
      displayName: 'Thyme',
      assetPath: 'assets/icons/food_icons/ingredients/icons8-thyme-50.svg',
    ),
    'vegetableBouillionPaste': FoodIconMapping(
      identifier: 'vegetableBouillionPaste',
      displayName: 'Vegetable Bouillon Paste',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-vegetable-bouillion-paste-50.svg',
    ),
    'whippedCream': FoodIconMapping(
      identifier: 'whippedCream',
      displayName: 'Whipped Cream',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-whipped-cream-50.svg',
    ),
    'worcestershireSauce': FoodIconMapping(
      identifier: 'worcestershireSauce',
      displayName: 'Worcestershire Sauce',
      assetPath:
          'assets/icons/food_icons/ingredients/icons8-worcestershire-sauce-50.svg',
    ),

    // Meat
    'bacon': FoodIconMapping(
      identifier: 'bacon',
      displayName: 'Bacon',
      assetPath: 'assets/icons/food_icons/meat/icons8-bacon-50.svg',
    ),
    'barbecue': FoodIconMapping(
      identifier: 'barbecue',
      displayName: 'Barbecue',
      assetPath: 'assets/icons/food_icons/meat/icons8-barbecue-50.svg',
    ),
    'barbeque': FoodIconMapping(
      identifier: 'barbeque',
      displayName: 'Barbeque',
      assetPath: 'assets/icons/food_icons/meat/icons8-barbeque-50.svg',
    ),
    'beef': FoodIconMapping(
      identifier: 'beef',
      displayName: 'Beef',
      assetPath: 'assets/icons/food_icons/meat/icons8-beef-50.svg',
    ),
    'cutsOfBeef': FoodIconMapping(
      identifier: 'cutsOfBeef',
      displayName: 'Cuts of Beef',
      assetPath: 'assets/icons/food_icons/meat/icons8-cuts-of-beef-50.svg',
    ),
    'cutsOfPork': FoodIconMapping(
      identifier: 'cutsOfPork',
      displayName: 'Cuts of Pork',
      assetPath: 'assets/icons/food_icons/meat/icons8-cuts-of-pork-50.svg',
    ),
    'iranianKebab': FoodIconMapping(
      identifier: 'iranianKebab',
      displayName: 'Iranian Kebab',
      assetPath: 'assets/icons/food_icons/meat/icons8-iranian-kebab-50.svg',
    ),
    'jamon': FoodIconMapping(
      identifier: 'jamon',
      displayName: 'Jamon',
      assetPath: 'assets/icons/food_icons/meat/icons8-jamon-50.svg',
    ),
    'kebab': FoodIconMapping(
      identifier: 'kebab',
      displayName: 'Kebab',
      assetPath: 'assets/icons/food_icons/meat/icons8-kebab-50.svg',
    ),
    'meat': FoodIconMapping(
      identifier: 'meat',
      displayName: 'Meat',
      assetPath: 'assets/icons/food_icons/meat/icons8-meat-50.svg',
    ),
    'poultryLeg': FoodIconMapping(
      identifier: 'poultryLeg',
      displayName: 'Poultry Leg',
      assetPath: 'assets/icons/food_icons/meat/icons8-poultry-leg-50.svg',
    ),
    'roast': FoodIconMapping(
      identifier: 'roast',
      displayName: 'Roast',
      assetPath: 'assets/icons/food_icons/meat/icons8-roast-50.svg',
    ),
    'sausage': FoodIconMapping(
      identifier: 'sausage',
      displayName: 'Sausage',
      assetPath: 'assets/icons/food_icons/meat/icons8-sausage-50.svg',
    ),
    'sausages': FoodIconMapping(
      identifier: 'sausages',
      displayName: 'Sausages',
      assetPath: 'assets/icons/food_icons/meat/icons8-sausages-50.svg',
    ),
    'souvla': FoodIconMapping(
      identifier: 'souvla',
      displayName: 'Souvla',
      assetPath: 'assets/icons/food_icons/meat/icons8-souvla-50.svg',
    ),
    'steak': FoodIconMapping(
      identifier: 'steak',
      displayName: 'Steak',
      assetPath: 'assets/icons/food_icons/meat/icons8-steak-50.svg',
    ),
    'steakHot': FoodIconMapping(
      identifier: 'steakHot',
      displayName: 'Steak Hot',
      assetPath: 'assets/icons/food_icons/meat/icons8-steak-hot-50.svg',
    ),
    'steakVeryHot': FoodIconMapping(
      identifier: 'steakVeryHot',
      displayName: 'Steak Very Hot',
      assetPath: 'assets/icons/food_icons/meat/icons8-steak-very-hot-50.svg',
    ),
    'thanksgiving': FoodIconMapping(
      identifier: 'thanksgiving',
      displayName: 'Thanksgiving',
      assetPath: 'assets/icons/food_icons/meat/icons8-thanksgiving-50.svg',
    ),

    // Nutrition
    'calories': FoodIconMapping(
      identifier: 'calories',
      displayName: 'Calories',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-calories-50.svg',
    ),
    'carbohydrates': FoodIconMapping(
      identifier: 'carbohydrates',
      displayName: 'Carbohydrates',
      assetPath:
          'assets/icons/food_icons/nutrition/icons8-carbohydrates-50.svg',
    ),
    'dairy': FoodIconMapping(
      identifier: 'dairy',
      displayName: 'Dairy',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-dairy-50.svg',
    ),
    'deadFood': FoodIconMapping(
      identifier: 'deadFood',
      displayName: 'Dead Food',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-dead-food-50.svg',
    ),
    'fiber': FoodIconMapping(
      identifier: 'fiber',
      displayName: 'Fiber',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-fiber-50.svg',
    ),
    'halalSign': FoodIconMapping(
      identifier: 'halalSign',
      displayName: 'Halal Sign',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-halal-sign-50.svg',
    ),
    'healthyEating': FoodIconMapping(
      identifier: 'healthyEating',
      displayName: 'Healthy Eating',
      assetPath:
          'assets/icons/food_icons/nutrition/icons8-healthy-eating-50.svg',
    ),
    'healthyFood': FoodIconMapping(
      identifier: 'healthyFood',
      displayName: 'Healthy Food',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-healthy-food-50.svg',
    ),
    'healthyFoodCaloriesCalculator': FoodIconMapping(
      identifier: 'healthyFoodCaloriesCalculator',
      displayName: 'Healthy Food Calories Calculator',
      assetPath:
          'assets/icons/food_icons/nutrition/icons8-healthy-food-calories-calculator-50.svg',
    ),
    'lipids': FoodIconMapping(
      identifier: 'lipids',
      displayName: 'Lipids',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-lipids-50.svg',
    ),
    'lowSalt': FoodIconMapping(
      identifier: 'lowSalt',
      displayName: 'Low Salt',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-low-salt-50.svg',
    ),
    'naturalFood': FoodIconMapping(
      identifier: 'naturalFood',
      displayName: 'Natural Food',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-natural-food-50.svg',
    ),
    'noApple': FoodIconMapping(
      identifier: 'noApple',
      displayName: 'No Apple',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-apple-50.svg',
    ),
    'noCelery': FoodIconMapping(
      identifier: 'noCelery',
      displayName: 'No Celery',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-celery-50.svg',
    ),
    'noCrustaceans': FoodIconMapping(
      identifier: 'noCrustaceans',
      displayName: 'No Crustaceans',
      assetPath:
          'assets/icons/food_icons/nutrition/icons8-no-crustaceans-50.svg',
    ),
    'noEggs': FoodIconMapping(
      identifier: 'noEggs',
      displayName: 'No Eggs',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-eggs-50.svg',
    ),
    'noFish': FoodIconMapping(
      identifier: 'noFish',
      displayName: 'No Fish',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-fish-50.svg',
    ),
    'noFructose': FoodIconMapping(
      identifier: 'noFructose',
      displayName: 'No Fructose',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-fructose-50.svg',
    ),
    'noGluten': FoodIconMapping(
      identifier: 'noGluten',
      displayName: 'No Gluten',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-gluten-50.svg',
    ),
    'noGmo': FoodIconMapping(
      identifier: 'noGmo',
      displayName: 'No GMO',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-gmo-50.svg',
    ),
    'noLupines': FoodIconMapping(
      identifier: 'noLupines',
      displayName: 'No Lupines',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-lupines-50.svg',
    ),
    'noMeat': FoodIconMapping(
      identifier: 'noMeat',
      displayName: 'No Meat',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-meat-50.svg',
    ),
    'noMustard': FoodIconMapping(
      identifier: 'noMustard',
      displayName: 'No Mustard',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-mustard-50.svg',
    ),
    'noNuts': FoodIconMapping(
      identifier: 'noNuts',
      displayName: 'No Nuts',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-nuts-50.svg',
    ),
    'noPeanut': FoodIconMapping(
      identifier: 'noPeanut',
      displayName: 'No Peanut',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-peanut-50.svg',
    ),
    'noPork': FoodIconMapping(
      identifier: 'noPork',
      displayName: 'No Pork',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-pork-50.svg',
    ),
    'noSesame': FoodIconMapping(
      identifier: 'noSesame',
      displayName: 'No Sesame',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-sesame-50.svg',
    ),
    'noShellfish': FoodIconMapping(
      identifier: 'noShellfish',
      displayName: 'No Shellfish',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-shellfish-50.svg',
    ),
    'noSoy': FoodIconMapping(
      identifier: 'noSoy',
      displayName: 'No Soy',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-soy-50.svg',
    ),
    'noSugar': FoodIconMapping(
      identifier: 'noSugar',
      displayName: 'No Sugar',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-no-sugar-50.svg',
    ),
    'nonLactoseFood': FoodIconMapping(
      identifier: 'nonLactoseFood',
      displayName: 'Non Lactose Food',
      assetPath:
          'assets/icons/food_icons/nutrition/icons8-non-lactose-food-50.svg',
    ),
    'organicFood': FoodIconMapping(
      identifier: 'organicFood',
      displayName: 'Organic Food',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-organic-food-50.svg',
    ),
    'paleoDiet': FoodIconMapping(
      identifier: 'paleoDiet',
      displayName: 'Paleo Diet',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-paleo-diet-50.svg',
    ),
    'protein': FoodIconMapping(
      identifier: 'protein',
      displayName: 'Protein',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-protein-50.svg',
    ),
    'sodium': FoodIconMapping(
      identifier: 'sodium',
      displayName: 'Sodium',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-sodium-50.svg',
    ),
    'sugarFree': FoodIconMapping(
      identifier: 'sugarFree',
      displayName: 'Sugar Free',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-sugar-free-50.svg',
    ),
    'veganFood': FoodIconMapping(
      identifier: 'veganFood',
      displayName: 'Vegan Food',
      assetPath: 'assets/icons/food_icons/nutrition/icons8-vegan-food-50.svg',
    ),
    'vegetarianFood': FoodIconMapping(
      identifier: 'vegetarianFood',
      displayName: 'Vegetarian Food',
      assetPath:
          'assets/icons/food_icons/nutrition/icons8-vegetarian-food-50.svg',
    ),

    // Nuts
    'brazilNut': FoodIconMapping(
      identifier: 'brazilNut',
      displayName: 'Brazil Nut',
      assetPath: 'assets/icons/food_icons/nuts/icons8-brazil-nut-50.svg',
    ),
    'cashew': FoodIconMapping(
      identifier: 'cashew',
      displayName: 'Cashew',
      assetPath: 'assets/icons/food_icons/nuts/icons8-cashew-50.svg',
    ),
    'hazelnut': FoodIconMapping(
      identifier: 'hazelnut',
      displayName: 'Hazelnut',
      assetPath: 'assets/icons/food_icons/nuts/icons8-hazelnut-50.svg',
    ),
    'nut': FoodIconMapping(
      identifier: 'nut',
      displayName: 'Nut',
      assetPath: 'assets/icons/food_icons/nuts/icons8-nut-50.svg',
    ),
    'peanuts': FoodIconMapping(
      identifier: 'peanuts',
      displayName: 'Peanuts',
      assetPath: 'assets/icons/food_icons/nuts/icons8-peanuts-50.svg',
    ),
    'pecan': FoodIconMapping(
      identifier: 'pecan',
      displayName: 'Pecan',
      assetPath: 'assets/icons/food_icons/nuts/icons8-pecan-50.svg',
    ),

    // Pastries
    'birthdayCake': FoodIconMapping(
      identifier: 'birthdayCake',
      displayName: 'Birthday Cake',
      assetPath: 'assets/icons/food_icons/pastries/icons8-birthday-cake-50.svg',
    ),
    'cake': FoodIconMapping(
      identifier: 'cake',
      displayName: 'Cake',
      assetPath: 'assets/icons/food_icons/pastries/icons8-cake-50.svg',
    ),
    'cinnamonRoll': FoodIconMapping(
      identifier: 'cinnamonRoll',
      displayName: 'Cinnamon Roll',
      assetPath: 'assets/icons/food_icons/pastries/icons8-cinnamon-roll-50.svg',
    ),
    'cookie': FoodIconMapping(
      identifier: 'cookie',
      displayName: 'Cookie',
      assetPath: 'assets/icons/food_icons/pastries/icons8-cookie-50.svg',
    ),
    'cookies': FoodIconMapping(
      identifier: 'cookies',
      displayName: 'Cookies',
      assetPath: 'assets/icons/food_icons/pastries/icons8-cookies-50.svg',
    ),
    'croissant': FoodIconMapping(
      identifier: 'croissant',
      displayName: 'Croissant',
      assetPath: 'assets/icons/food_icons/pastries/icons8-croissant-50.svg',
    ),
    'cupcake': FoodIconMapping(
      identifier: 'cupcake',
      displayName: 'Cupcake',
      assetPath: 'assets/icons/food_icons/pastries/icons8-cupcake-50.svg',
    ),
    'doughnut': FoodIconMapping(
      identifier: 'doughnut',
      displayName: 'Doughnut',
      assetPath: 'assets/icons/food_icons/pastries/icons8-doughnut-50.svg',
    ),
    'koreanRiceCake': FoodIconMapping(
      identifier: 'koreanRiceCake',
      displayName: 'Korean Rice Cake',
      assetPath:
          'assets/icons/food_icons/pastries/icons8-korean-rice-cake-50.svg',
    ),
    'macaron': FoodIconMapping(
      identifier: 'macaron',
      displayName: 'Macaron',
      assetPath: 'assets/icons/food_icons/pastries/icons8-macaron-50.svg',
    ),
    'pie': FoodIconMapping(
      identifier: 'pie',
      displayName: 'Pie',
      assetPath: 'assets/icons/food_icons/pastries/icons8-pie-50.svg',
    ),
    'samosa': FoodIconMapping(
      identifier: 'samosa',
      displayName: 'Samosa',
      assetPath: 'assets/icons/food_icons/pastries/icons8-samosa-50.svg',
    ),

    // Seafood
    'crab': FoodIconMapping(
      identifier: 'crab',
      displayName: 'Crab',
      assetPath: 'assets/icons/food_icons/seafood/icons8-crab-50.svg',
    ),
    'dressedFish': FoodIconMapping(
      identifier: 'dressedFish',
      displayName: 'Dressed Fish',
      assetPath: 'assets/icons/food_icons/seafood/icons8-dressed-fish-50.svg',
    ),
    'fishFillet': FoodIconMapping(
      identifier: 'fishFillet',
      displayName: 'Fish Fillet',
      assetPath: 'assets/icons/food_icons/seafood/icons8-fish-fillet-50.svg',
    ),
    'fishFood': FoodIconMapping(
      identifier: 'fishFood',
      displayName: 'Fish Food',
      assetPath: 'assets/icons/food_icons/seafood/icons8-fish-food-50.svg',
    ),
    'octopus': FoodIconMapping(
      identifier: 'octopus',
      displayName: 'Octopus',
      assetPath: 'assets/icons/food_icons/seafood/icons8-octopus-50.svg',
    ),
    'prawn': FoodIconMapping(
      identifier: 'prawn',
      displayName: 'Prawn',
      assetPath: 'assets/icons/food_icons/seafood/icons8-prawn-50.svg',
    ),
    'shellfish': FoodIconMapping(
      identifier: 'shellfish',
      displayName: 'Shellfish',
      assetPath: 'assets/icons/food_icons/seafood/icons8-shellfish-50.svg',
    ),
    'wholeFish': FoodIconMapping(
      identifier: 'wholeFish',
      displayName: 'Whole Fish',
      assetPath: 'assets/icons/food_icons/seafood/icons8-whole-fish-50.svg',
    ),

    // Other
    'badApple': FoodIconMapping(
      identifier: 'badApple',
      displayName: 'Bad Apple',
      assetPath: 'assets/icons/food_icons/other/icons8-bad-apple-50.svg',
    ),
    'bitingACarrot': FoodIconMapping(
      identifier: 'bitingACarrot',
      displayName: 'Biting a Carrot',
      assetPath: 'assets/icons/food_icons/other/icons8-biting-a-carrot-50.svg',
    ),
    'breakfast': FoodIconMapping(
      identifier: 'breakfast',
      displayName: 'Breakfast',
      assetPath: 'assets/icons/food_icons/other/icons8-breakfast-50.svg',
    ),
    'brigadeiro': FoodIconMapping(
      identifier: 'brigadeiro',
      displayName: 'Brigadeiro',
      assetPath: 'assets/icons/food_icons/other/icons8-brigadeiro-50.svg',
    ),
    'butterChurn': FoodIconMapping(
      identifier: 'butterChurn',
      displayName: 'Butter Churn',
      assetPath: 'assets/icons/food_icons/other/icons8-butter-churn-50.svg',
    ),
    'coffeeBeans': FoodIconMapping(
      identifier: 'coffeeBeans',
      displayName: 'Coffee Beans',
      assetPath: 'assets/icons/food_icons/other/icons8-coffee-beans-50.svg',
    ),
    'cookbook': FoodIconMapping(
      identifier: 'cookbook',
      displayName: 'Cookbook',
      assetPath: 'assets/icons/food_icons/other/icons8-cookbook-50.svg',
    ),
    'cookingBook': FoodIconMapping(
      identifier: 'cookingBook',
      displayName: 'Cooking Book',
      assetPath: 'assets/icons/food_icons/other/icons8-cooking-book-50.svg',
    ),
    'deliverFood': FoodIconMapping(
      identifier: 'deliverFood',
      displayName: 'Deliver Food',
      assetPath: 'assets/icons/food_icons/other/icons8-deliver-food-50.svg',
    ),
    'diabeticFood': FoodIconMapping(
      identifier: 'diabeticFood',
      displayName: 'Diabetic Food',
      assetPath: 'assets/icons/food_icons/other/icons8-diabetic-food-50.svg',
    ),
    'dinner': FoodIconMapping(
      identifier: 'dinner',
      displayName: 'Dinner',
      assetPath: 'assets/icons/food_icons/other/icons8-dinner-50.svg',
    ),
    'eggStand': FoodIconMapping(
      identifier: 'eggStand',
      displayName: 'Egg Stand',
      assetPath: 'assets/icons/food_icons/other/icons8-egg-stand-50.svg',
    ),
    'emptyJamJar': FoodIconMapping(
      identifier: 'emptyJamJar',
      displayName: 'Empty Jam Jar',
      assetPath: 'assets/icons/food_icons/other/icons8-empty-jam-jar-50.svg',
    ),
    'fastFoodDriveThru': FoodIconMapping(
      identifier: 'fastFoodDriveThru',
      displayName: 'Fast Food Drive Thru',
      assetPath:
          'assets/icons/food_icons/other/icons8-fast-food-drive-thru-50.svg',
    ),
    'fastMovingConsumerGoods': FoodIconMapping(
      identifier: 'fastMovingConsumerGoods',
      displayName: 'Fast Moving Consumer Goods',
      assetPath:
          'assets/icons/food_icons/other/icons8-fast-moving-consumer-goods-50.svg',
    ),
    'firmTofu': FoodIconMapping(
      identifier: 'firmTofu',
      displayName: 'Firm Tofu',
      assetPath: 'assets/icons/food_icons/other/icons8-firm-tofu-50.svg',
    ),
    'flour': FoodIconMapping(
      identifier: 'flour',
      displayName: 'Flour',
      assetPath: 'assets/icons/food_icons/other/icons8-flour-50.svg',
    ),
    'foodDonor': FoodIconMapping(
      identifier: 'foodDonor',
      displayName: 'Food Donor',
      assetPath: 'assets/icons/food_icons/other/icons8-food-donor-50.svg',
    ),
    'foodReceiver': FoodIconMapping(
      identifier: 'foodReceiver',
      displayName: 'Food Receiver',
      assetPath: 'assets/icons/food_icons/other/icons8-food-receiver-50.svg',
    ),
    'garlic': FoodIconMapping(
      identifier: 'garlic',
      displayName: 'Garlic',
      assetPath: 'assets/icons/food_icons/other/icons8-garlic-50.svg',
    ),
    'groceryBag': FoodIconMapping(
      identifier: 'groceryBag',
      displayName: 'Grocery Bag',
      assetPath: 'assets/icons/food_icons/other/icons8-grocery-bag-50.svg',
    ),
    'groceryShelf': FoodIconMapping(
      identifier: 'groceryShelf',
      displayName: 'Grocery Shelf',
      assetPath: 'assets/icons/food_icons/other/icons8-grocery-shelf-50.svg',
    ),
    'gum': FoodIconMapping(
      identifier: 'gum',
      displayName: 'Gum',
      assetPath: 'assets/icons/food_icons/other/icons8-gum-50.svg',
    ),
    'halalFood': FoodIconMapping(
      identifier: 'halalFood',
      displayName: 'Halal Food',
      assetPath: 'assets/icons/food_icons/other/icons8-halal-food-50.svg',
    ),
    'haramFood': FoodIconMapping(
      identifier: 'haramFood',
      displayName: 'Haram Food',
      assetPath: 'assets/icons/food_icons/other/icons8-haram-food-50.svg',
    ),
    'heinzBeans': FoodIconMapping(
      identifier: 'heinzBeans',
      displayName: 'Heinz Beans',
      assetPath: 'assets/icons/food_icons/other/icons8-heinz-beans-50.svg',
    ),
    'hotChocolateWithMarshmallows': FoodIconMapping(
      identifier: 'hotChocolateWithMarshmallows',
      displayName: 'Hot Chocolate with Marshmallows',
      assetPath:
          'assets/icons/food_icons/other/icons8-hot-chocolate-with-marshmallows-50.svg',
    ),
    'ice': FoodIconMapping(
      identifier: 'ice',
      displayName: 'Ice',
      assetPath: 'assets/icons/food_icons/other/icons8-ice-50.svg',
    ),
    'internationalFood': FoodIconMapping(
      identifier: 'internationalFood',
      displayName: 'International Food',
      assetPath:
          'assets/icons/food_icons/other/icons8-international-food-50.svg',
    ),
    'kiwi': FoodIconMapping(
      identifier: 'kiwi',
      displayName: 'Kiwi',
      assetPath: 'assets/icons/food_icons/other/icons8-kiwi-50.svg',
    ),
    'lettuceOther': FoodIconMapping(
      identifier: 'lettuceOther',
      displayName: 'Lettuce (Other)',
      assetPath: 'assets/icons/food_icons/other/icons8-lettuce-50.svg',
    ),
    'lowCholesterolFood': FoodIconMapping(
      identifier: 'lowCholesterolFood',
      displayName: 'Low Cholesterol Food',
      assetPath:
          'assets/icons/food_icons/other/icons8-low-cholesterol-food-50.svg',
    ),
    'lunch': FoodIconMapping(
      identifier: 'lunch',
      displayName: 'Lunch',
      assetPath: 'assets/icons/food_icons/other/icons8-lunch-50.svg',
    ),
    'mushboohFood': FoodIconMapping(
      identifier: 'mushboohFood',
      displayName: 'Mushbooh Food',
      assetPath: 'assets/icons/food_icons/other/icons8-mushbooh-food-50.svg',
    ),
    'mushroom': FoodIconMapping(
      identifier: 'mushroom',
      displayName: 'Mushroom',
      assetPath: 'assets/icons/food_icons/other/icons8-mushroom-50.svg',
    ),
    'nonyaKueh': FoodIconMapping(
      identifier: 'nonyaKueh',
      displayName: 'Nonya Kueh',
      assetPath: 'assets/icons/food_icons/other/icons8-nonya-kueh-50.svg',
    ),
    'olive': FoodIconMapping(
      identifier: 'olive',
      displayName: 'Olive',
      assetPath: 'assets/icons/food_icons/other/icons8-olive-50.svg',
    ),
    'paprika': FoodIconMapping(
      identifier: 'paprika',
      displayName: 'Paprika',
      assetPath: 'assets/icons/food_icons/other/icons8-paprika-50.svg',
    ),
    'peas': FoodIconMapping(
      identifier: 'peas',
      displayName: 'Peas',
      assetPath: 'assets/icons/food_icons/other/icons8-peas-50.svg',
    ),
    'picnic': FoodIconMapping(
      identifier: 'picnic',
      displayName: 'Picnic',
      assetPath: 'assets/icons/food_icons/other/icons8-picnic-50.svg',
    ),
    'plum': FoodIconMapping(
      identifier: 'plum',
      displayName: 'Plum',
      assetPath: 'assets/icons/food_icons/other/icons8-plum-50.svg',
    ),
    'potato': FoodIconMapping(
      identifier: 'potato',
      displayName: 'Potato',
      assetPath: 'assets/icons/food_icons/other/icons8-potato-50.svg',
    ),
    'rackOfLamb': FoodIconMapping(
      identifier: 'rackOfLamb',
      displayName: 'Rack of Lamb',
      assetPath: 'assets/icons/food_icons/other/icons8-rack-of-lamb-50.svg',
    ),
    'realFoodForMeals': FoodIconMapping(
      identifier: 'realFoodForMeals',
      displayName: 'Real Food for Meals',
      assetPath:
          'assets/icons/food_icons/other/icons8-real-food-for-meals-50.svg',
    ),
    'sabzeh': FoodIconMapping(
      identifier: 'sabzeh',
      displayName: 'Sabzeh',
      assetPath: 'assets/icons/food_icons/other/icons8-sabzeh-50.svg',
    ),
    'salami': FoodIconMapping(
      identifier: 'salami',
      displayName: 'Salami',
      assetPath: 'assets/icons/food_icons/other/icons8-salami-50.svg',
    ),
    'silkenTofu': FoodIconMapping(
      identifier: 'silkenTofu',
      displayName: 'Silken Tofu',
      assetPath: 'assets/icons/food_icons/other/icons8-silken-tofu-50.svg',
    ),
    'soupPlate': FoodIconMapping(
      identifier: 'soupPlate',
      displayName: 'Soup Plate',
      assetPath: 'assets/icons/food_icons/other/icons8-soup-plate-50.svg',
    ),
    'spoiledFood': FoodIconMapping(
      identifier: 'spoiledFood',
      displayName: 'Spoiled Food',
      assetPath: 'assets/icons/food_icons/other/icons8-spoiled-food-50.svg',
    ),
    'stir': FoodIconMapping(
      identifier: 'stir',
      displayName: 'Stir',
      assetPath: 'assets/icons/food_icons/other/icons8-stir-50.svg',
    ),
    'tempeh': FoodIconMapping(
      identifier: 'tempeh',
      displayName: 'Tempeh',
      assetPath: 'assets/icons/food_icons/other/icons8-tempeh-50.svg',
    ),
    'tiffin': FoodIconMapping(
      identifier: 'tiffin',
      displayName: 'Tiffin',
      assetPath: 'assets/icons/food_icons/other/icons8-tiffin-50.svg',
    ),
    'topping': FoodIconMapping(
      identifier: 'topping',
      displayName: 'Topping',
      assetPath: 'assets/icons/food_icons/other/icons8-topping-50.svg',
    ),
    'wickerBasket': FoodIconMapping(
      identifier: 'wickerBasket',
      displayName: 'Wicker Basket',
      assetPath: 'assets/icons/food_icons/other/icons8-wicker-basket-50.svg',
    ),
  };

  /// Get a food icon mapping by identifier
  static FoodIconMapping? getIcon(String identifier) {
    return _foodIconMap[identifier];
  }

  /// Get the asset path by identifier
  static String? getAssetPath(String identifier) {
    return _foodIconMap[identifier]?.assetPath;
  }

  /// Get a widget for the icon by identifier
  static Widget? getIconWidget(
    String identifier, {
    double? width = 24,
    double? height = 24,
    Color? color,
  }) {
    final mapping = _foodIconMap[identifier];
    return mapping?.buildIcon(width: width, height: height, color: color);
  }

  /// Get the display name by identifier
  static String? getDisplayName(String identifier) {
    return _foodIconMap[identifier]?.displayName;
  }

  /// Get all available food icon identifiers
  static List<String> getAllIdentifiers() {
    return _foodIconMap.keys.toList();
  }

  /// Get all food icon mappings
  static List<FoodIconMapping> getAllIcons() {
    return _foodIconMap.values.toList();
  }

  /// Search food icons by display name or identifier
  static List<FoodIconMapping> searchFoodIcons(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _foodIconMap.values
        .where((mapping) =>
            mapping.displayName.toLowerCase().contains(lowercaseQuery) ||
            mapping.identifier.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Get food icons by category
  static List<FoodIconMapping> getFoodIconsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'bakery':
        return [
          'baguette',
          'bake',
          'biscuits',
          'bread',
          'breadAndRollingPin',
          'breadAndRye',
          'breadLoaf',
          'brezel',
          'gingerbreadHouse',
          'merryPie',
          'naan',
          'pretzel'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'berries':
        return [
          'blueberry',
          'cherry',
          'grapes',
          'raspberry',
          'strawberry',
          'strawberry2'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'desserts':
        return [
          'appleJam',
          'bananaSplit',
          'berryJam',
          'candyDessert',
          'cheesecakeDessert',
          'cherryCheesecake',
          'chocolateBarDessert',
          'chocolateBarWhite',
          'cottonCandy',
          'dessertGeneral',
          'iceCreamConeDessert',
          'iceCreamSundae',
          'jamDessert',
          'jelly',
          'meltingIceCream',
          'pastelDeNata',
          'strawberryCheesecake',
          'sweets'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'dishes':
        return [
          'bagel',
          'bento',
          'caviar',
          'cheese',
          'chocolateSpread',
          'dimSum',
          'dolmades',
          'fishAndVegetables',
          'fondue',
          'foodAndWine',
          'greekSalad',
          'guacamole',
          'gyoza',
          'lasagna',
          'lunchbox',
          'noodles',
          'omlette',
          'paella',
          'pancakeStack',
          'porridge',
          'riceBowl',
          'riceBowl2',
          'saladDish',
          'salamiPizza',
          'salmonSushi',
          'sandwichWithFriedEgg',
          'sauce',
          'seafoodDish',
          'spaghetti',
          'spamCan',
          'springRoll',
          'sunnySideUpEggs',
          'sushiDish',
          'tapas',
          'tinCan',
          'toast',
          'yogurt'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'drinks':
        return [
          'alcoholicBeverageLicensing',
          'coconutMilk',
          'coffeeCapsule',
          'colaDrink',
          'greenTea',
          'hempMilk',
          'hotChocolateDrink',
          'lemonade',
          'milkBottle',
          'milkCarton',
          'mulledWine',
          'oatMilk',
          'orangeJuiceDrink',
          'teacupSet',
          'theToast',
          'wineAndGlass'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'fastfood':
        return [
          'baoBun',
          'bittenSandwich',
          'boxOfCereal',
          'burrito',
          'cereal',
          'chickenAndWaffle',
          'chineseFriedRice',
          'chineseNoodle',
          'frenchFries',
          'friedChicken',
          'fry',
          'hamburger',
          'hotDog',
          'kfcChicken',
          'mcdonaldsFrenchFries',
          'nachos',
          'pizzaFastfood',
          'pizzaFiveEighths',
          'plasticFoodContainer',
          'popcornFastfood',
          'potatoChips',
          'quesadilla',
          'refreshments',
          'sandwichFastfood',
          'streetFood',
          'taco',
          'takeAwayFood',
          'wrap'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'fruits':
        return [
          'appleFruit',
          'applesPlate',
          'applesPlate2',
          'apricot',
          'avocado',
          'badBanana',
          'badOrange',
          'badPear',
          'banana',
          'citrus',
          'citrus2',
          'coconut',
          'coconut2',
          'cucumber',
          'cutMelon',
          'cutWatermelon',
          'dateFruit',
          'dragonFruit',
          'durian',
          'figFruit',
          'fruitBag',
          'groupOfFruits',
          'halfOrange',
          'jackfruit',
          'lime',
          'lychee',
          'mango',
          'mangosteen',
          'melon',
          'orange',
          'papaya',
          'peach',
          'pear',
          'pears',
          'peeledBanana',
          'pineapple',
          'pomegranate',
          'rambutan',
          'soursop',
          'tangelo',
          'watermelon',
          'watermelon2',
          'wholeApple',
          'wholeMelon',
          'wholeWatermelon'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'vegetables':
        return [
          'artichoke',
          'asparagus',
          'beet',
          'bokChoy',
          'broccoli',
          'broccolini',
          'cabbage',
          'carrot',
          'cauliflower',
          'celery',
          'chard',
          'chiliPepper',
          'collardGreens',
          'corn',
          'eggplant',
          'finocchio',
          'gailan',
          'groupOfVegetables',
          'kohlrabi',
          'leek',
          'lettuce',
          'onion',
          'pumpkin',
          'radish',
          'soy',
          'spinach',
          'squash',
          'sweetPotato',
          'tomato',
          'tomatoes',
          'vegetablesBag',
          'vegetablesBox',
          'whiteBeans',
          'youChoy',
          'zucchini'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'ingredients':
        return [
          'almondButter',
          'basil',
          'butter',
          'chiaSeeds',
          'cinnamonSticks',
          'dozenEggs',
          'dressing',
          'eggBasket',
          'eggCarton',
          'eggs',
          'flaxSeeds',
          'flourInPaperPackaging',
          'flourOfRye',
          'ginger',
          'grainsOfRice',
          'hamper',
          'honey',
          'honeyDipperWithHoneyDripping',
          'honeySpoon',
          'icingSugar',
          'ingredients',
          'ingredientsForCooking',
          'ketchup',
          'lentil',
          'listView',
          'mapleSyrup',
          'mayonnaise',
          'mint',
          'mozzarella',
          'mustard',
          'oliveOil',
          'oliveOilBottle',
          'peanutButter',
          'pistachioSauce',
          'quorn',
          'raisins',
          'riceVinegar',
          'rolledOats',
          'saltShaker',
          'sauceBottle',
          'sesame',
          'sesameOil',
          'soySauce',
          'spice',
          'spoonOfSugar',
          'sugar',
          'sugarCube',
          'sugarCubes',
          'sunflowerButter',
          'sunflowerOil',
          'sweetener',
          'thyme',
          'vegetableBouillionPaste',
          'whippedCream',
          'worcestershireSauce'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'meat':
        return [
          'bacon',
          'barbecue',
          'barbeque',
          'beef',
          'cutsOfBeef',
          'cutsOfPork',
          'iranianKebab',
          'jamon',
          'kebab',
          'meat',
          'poultryLeg',
          'roast',
          'sausage',
          'sausages',
          'souvla',
          'steak',
          'steakHot',
          'steakVeryHot',
          'thanksgiving'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'nutrition':
        return [
          'calories',
          'carbohydrates',
          'dairy',
          'deadFood',
          'fiber',
          'halalSign',
          'healthyEating',
          'healthyFood',
          'healthyFoodCaloriesCalculator',
          'lipids',
          'lowSalt',
          'naturalFood',
          'noApple',
          'noCelery',
          'noCrustaceans',
          'noEggs',
          'noFish',
          'noFructose',
          'noGluten',
          'noGmo',
          'noLupines',
          'noMeat',
          'noMustard',
          'noNuts',
          'noPeanut',
          'noPork',
          'noSesame',
          'noShellfish',
          'noSoy',
          'noSugar',
          'nonLactoseFood',
          'organicFood',
          'paleoDiet',
          'protein',
          'sodium',
          'sugarFree',
          'veganFood',
          'vegetarianFood'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'nuts':
        return ['brazilNut', 'cashew', 'hazelnut', 'nut', 'peanuts', 'pecan']
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'pastries':
        return [
          'birthdayCake',
          'cake',
          'cinnamonRoll',
          'cookie',
          'cookies',
          'croissant',
          'cupcake',
          'doughnut',
          'koreanRiceCake',
          'macaron',
          'pie',
          'samosa'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'seafood':
        return [
          'crab',
          'dressedFish',
          'fishFillet',
          'fishFood',
          'octopus',
          'prawn',
          'shellfish',
          'wholeFish'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'other':
        return [
          'badApple',
          'bitingACarrot',
          'breakfast',
          'brigadeiro',
          'butterChurn',
          'coffeeBeans',
          'cookbook',
          'cookingBook',
          'deliverFood',
          'diabeticFood',
          'dinner',
          'eggStand',
          'emptyJamJar',
          'fastFoodDriveThru',
          'fastMovingConsumerGoods',
          'firmTofu',
          'flour',
          'foodDonor',
          'foodReceiver',
          'garlic',
          'groceryBag',
          'groceryShelf',
          'gum',
          'halalFood',
          'haramFood',
          'heinzBeans',
          'hotChocolateWithMarshmallows',
          'ice',
          'internationalFood',
          'kiwi',
          'lettuceOther',
          'lowCholesterolFood',
          'lunch',
          'mushboohFood',
          'mushroom',
          'nonyaKueh',
          'olive',
          'paprika',
          'peas',
          'picnic',
          'plum',
          'potato',
          'rackOfLamb',
          'realFoodForMeals',
          'sabzeh',
          'salami',
          'silkenTofu',
          'soupPlate',
          'spoiledFood',
          'stir',
          'tempeh',
          'tiffin',
          'topping',
          'wickerBasket'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      case 'popular':
        return [
          // Basic fruits
          'appleFruit',
          'banana',
          'orange',
          'strawberry',
          'grapes',

          // Common vegetables
          'tomato',
          'carrot',
          'onion',
          'potato',
          'lettuce',
          'broccoli',

          // Basic proteins
          'beef',
          'meat',
          'poultryLeg',
          'bacon',
          'eggs',

          // Dairy basics
          'milkBottle',
          'cheese',
          'butter',
          'yogurt',

          // Grains and bread
          'bread',
          'riceBowl',
          'spaghetti',

          // Common beverages
          'milkBottle',
          'colaDrink',
          'coffeeCapsule',
          'greenTea',

          // Fast food favorites
          'hamburger',
          'pizzaFastfood',
          'frenchFries',
          'hotDog',

          // Sweet treats
          'cake',
          'cookie',
          'iceCreamConeDessert',
          'chocolateBarDessert',

          // Cooking essentials
          'saltShaker',
          'sugar',
          'oliveOil',
          'garlic',

          // Meal categories
          'breakfast',
          'lunch',
          'dinner'
        ]
            .map((id) => _foodIconMap[id])
            .where((mapping) => mapping != null)
            .cast<FoodIconMapping>()
            .toList();

      default:
        return [];
    }
  }
}
