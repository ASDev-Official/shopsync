'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "f98ae4df423c7d14296b2e4ab966baf1",
"version.json": "82ee61358a112d5cfc3bd864420bfab5",
"index.html": "24d0e9c74ccbc10826c18fc5078747c6",
"/": "24d0e9c74ccbc10826c18fc5078747c6",
"main.dart.js": "e6cfaa130ac50fa08be5937a4c3fbe39",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"main.dart.mjs": "a1cecb155f4766c88306732b42232326",
"icons/favicon.ico": "b21b23fb8ed0b4cbf7c555d56a9325b2",
"icons/apple-touch-icon.png": "92bb272b6c3a5feb9d48644773c5429b",
"icons/icon-192.png": "8c11f2fe05f3489008c02af1b0dc2290",
"icons/icon-192-maskable.png": "4ba47591cfa3d65fcc73668778cce84c",
"icons/icon-512-maskable.png": "c938e622035e2763db1cde74b97ff392",
"icons/icon-512.png": "43a3aceab5c41054d6974fde144ff91d",
"manifest.json": "04f4e31a8405a498095745f149d0db6f",
"main.dart.wasm": "e2e28bf6643d1a5c692f26c8e49b91d0",
"assets/LICENSE": "68af2a4e90a9d33178a7da90ba35325b",
"assets/AssetManifest.json": "da6838ed08f5764c0c8d2813f572f8bf",
"assets/NOTICES": "e7d93bf35db917d3540034c6256cd3c4",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "ea590a7193277fdc671c3585edd7b3f7",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "4067849e568a51bdcf03ae2fe826c78e",
"assets/fonts/MaterialIcons-Regular.otf": "689294253c585b3344181ffbbe7e8e27",
"assets/assets/logos/shopsync.png": "5d4f1b2a656a495502cf60993409ce42",
"assets/assets/icons/food_icons/drinks/icons8-alcoholic-beverage-licensing-50.svg": "9a39a018530e41bd95482623e7afc044",
"assets/assets/icons/food_icons/drinks/icons8-teacup-set-50.svg": "7a7df1b975a1d7200b1b985db156f618",
"assets/assets/icons/food_icons/drinks/icons8-wine-and-glass-50.svg": "fa1233dcb5c855cd4eb1d05421ad0d36",
"assets/assets/icons/food_icons/drinks/icons8-coffee-capsule-50.svg": "1ab53b4d9be6572b0fe2c7358c4ea651",
"assets/assets/icons/food_icons/drinks/icons8-oat-milk-50.svg": "7fce538de8fb692ee3cb002295aeab3e",
"assets/assets/icons/food_icons/drinks/icons8-hemp-milk-50.svg": "d38ddc2c419682b559021941ed610e96",
"assets/assets/icons/food_icons/drinks/icons8-coconut-milk-50.svg": "3fc5d039e3df3ed0d5834d0cbd841b85",
"assets/assets/icons/food_icons/drinks/icons8-orange-juice-50.svg": "d1f10a971360bcce1ad8bdce45596364",
"assets/assets/icons/food_icons/drinks/icons8-mulled-wine-50.svg": "9b6a971580476d01200fb97fa8169a0f",
"assets/assets/icons/food_icons/drinks/icons8-milk-bottle-50.svg": "a5d80145c421ce763bd00214031a172d",
"assets/assets/icons/food_icons/drinks/icons8-the-toast-50.svg": "3b781ee77346a874f0ed91af89266721",
"assets/assets/icons/food_icons/drinks/icons8-cola-50.svg": "22471abd9455fe52e87a86323fd60c56",
"assets/assets/icons/food_icons/drinks/icons8-milk-carton-50.svg": "e003c49576690c037f71c6ec7fe6e3f2",
"assets/assets/icons/food_icons/drinks/icons8-lemonade-50.svg": "9b64ffb09f7ea43afd00401b75b89253",
"assets/assets/icons/food_icons/drinks/icons8-hot-chocolate-50.svg": "57080063a2f1aee3ce549e826be4a96f",
"assets/assets/icons/food_icons/drinks/icons8-green-tea-50.svg": "5b8142a5e6dbd078587e2b76e331cfb3",
"assets/assets/icons/food_icons/berries/icons8-strawberry-50-2.svg": "82f43cc1b4c3d3f175e1c25f09075977",
"assets/assets/icons/food_icons/berries/icons8-strawberry-50.svg": "d4a7b0bf1bee612f6ac043ef2353a7fe",
"assets/assets/icons/food_icons/berries/icons8-blueberry-50.svg": "f158a473d18a4bd8e4b15ae2b00eb916",
"assets/assets/icons/food_icons/berries/icons8-grapes-50.svg": "d03cdbc96349f77255ef81abef7f7f13",
"assets/assets/icons/food_icons/berries/icons8-cherry-50.svg": "1730a551c1ef6fe016a5e765de977826",
"assets/assets/icons/food_icons/berries/icons8-raspberry-50.svg": "a6a20e3d4bf4392d4fb0f768153ea82d",
"assets/assets/icons/food_icons/fastfood/icons8-bitten-sandwich-50.svg": "4fcc69b7e8fa268f74160f2035b3f06e",
"assets/assets/icons/food_icons/fastfood/icons8-bao-bun-50.svg": "0002fa41e7540ebdb436c1e6aeef51ee",
"assets/assets/icons/food_icons/fastfood/icons8-plastic-food-container-50.svg": "c7ba14491515e674645dd611d28ba0b9",
"assets/assets/icons/food_icons/fastfood/icons8-french-fries-50.svg": "b24ad8e07e2cca5e541292f0870feb39",
"assets/assets/icons/food_icons/fastfood/icons8-fry-50.svg": "0466e13bcaa7c3e7c6f897b32f11bdd9",
"assets/assets/icons/food_icons/fastfood/icons8-nachos-50.svg": "8b619303aa291bb0134b0177b374c41d",
"assets/assets/icons/food_icons/fastfood/icons8-fried-chicken-50.svg": "2b88f100f113ead7498f261b8a40327b",
"assets/assets/icons/food_icons/fastfood/icons8-refreshments-50.svg": "1eeadca5cf5ceec966cf40280e0fab28",
"assets/assets/icons/food_icons/fastfood/icons8-chicken-and-waffle-50.svg": "73ea330465f55f479b251c5985dad5ea",
"assets/assets/icons/food_icons/fastfood/icons8-hamburger-50.svg": "00ce1540abd9844cc36c66dc2b0bed3d",
"assets/assets/icons/food_icons/fastfood/icons8-taco-50.svg": "7dc04f7879783080585c06aa8a7d75bf",
"assets/assets/icons/food_icons/fastfood/icons8-burrito-50.svg": "bbeee587549e8db0c26a496330c6a249",
"assets/assets/icons/food_icons/fastfood/icons8-sandwich-50.svg": "04471c46d460fdf453c5c21d1a5db2ec",
"assets/assets/icons/food_icons/fastfood/icons8-wrap-50.svg": "9f8831a4596d6100f2d8ebc8ab9e17f0",
"assets/assets/icons/food_icons/fastfood/icons8-take-away-food-50.svg": "c62a9395c17fbaa6f6bb9f99bb6013bb",
"assets/assets/icons/food_icons/fastfood/icons8-chinese-noodle-50.svg": "a4cd8245d5069dc1748cdccdc8ec5916",
"assets/assets/icons/food_icons/fastfood/icons8-hot-dog-50.svg": "e25516c3927536869f58e559b33c8139",
"assets/assets/icons/food_icons/fastfood/icons8-cereal-50.svg": "557746cbffdf4ced587d97587c0dd5fc",
"assets/assets/icons/food_icons/fastfood/icons8-box-of-cereal-50.svg": "304ede153107e959f70f5bf81b1b78d0",
"assets/assets/icons/food_icons/fastfood/icons8-street-food-50.svg": "b603c68391f9a01a2d354f41b4ba4405",
"assets/assets/icons/food_icons/fastfood/icons8-potato-chips-50.svg": "bb9fb637555f35dd0158dbddd4f8868b",
"assets/assets/icons/food_icons/fastfood/icons8-pizza-five-eighths-50.svg": "85b91f81a34a7356ba1362c364a4be60",
"assets/assets/icons/food_icons/fastfood/icons8-popcorn-50.svg": "1638da10fb031d626a25dc6d65e11c91",
"assets/assets/icons/food_icons/fastfood/icons8-kfc-chicken-50.svg": "d93d91044d890b72df7330ee2b0069e7",
"assets/assets/icons/food_icons/fastfood/icons8-quesadilla-50.svg": "f821b8f72267688c619fb0c5480542df",
"assets/assets/icons/food_icons/fastfood/icons8-chinese-fried-rice-50.svg": "9b62c1dcc854294f48f1e05b90896a84",
"assets/assets/icons/food_icons/fastfood/icons8-pizza-50.svg": "65333d63619105ca88d389afa8dde727",
"assets/assets/icons/food_icons/fastfood/icons8-mcdonald%2560s-french-fries-50.svg": "c190883fe0efeb54210e83dc233eb961",
"assets/assets/icons/food_icons/nuts/icons8-peanuts-50.svg": "05b741f548524138dc6106ab904bc43b",
"assets/assets/icons/food_icons/nuts/icons8-brazil-nut-50.svg": "c22adf9f95c006356d2877fbfb91933f",
"assets/assets/icons/food_icons/nuts/icons8-cashew-50.svg": "06fc481705370d69220f4fdc38ec3561",
"assets/assets/icons/food_icons/nuts/icons8-nut-50.svg": "5d70c5a00593beca06d26b4e873d6550",
"assets/assets/icons/food_icons/nuts/icons8-hazelnut-50.svg": "8106763d6b53f085623b2e6fc248b507",
"assets/assets/icons/food_icons/nuts/icons8-pecan-50.svg": "0d9a4531fbd8133dd4fed567abb54332",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-croissant-50.svg": "50f41e7962acb38520c155dce5a8ad3a",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-taco-50.svg": "f02b88f0c8b950c7318bbef625ca27c9",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-soda-50.svg": "a1f0d95b7621d702231e208eba0bb4ca",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-steak-50.svg": "38b55aea2bdf805456e3e45174c20764",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-coffee-50.svg": "5c49bcdff32a95f630a9541d2f048096",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-ice-cream-50.svg": "b271bc6862590bcd83c1433600a20f56",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-shellfish-50.svg": "a34673f70a9ad3c0e8f6c410696bbe0a",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-milk-50.svg": "41e941fc64e89fa904caffd8d00e1d9e",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-cupcake-50.svg": "9c0c5b20530349afb0198c62125ebc19",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-jam-50.svg": "3470662194af040906d7d94c103e8430",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-egg-50.svg": "c86a8951b7e5e970031f8813bd19fd34",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-broccoli-50.svg": "24274cd6fff4d92cab85cd62e91edf64",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-noodle-50.svg": "8fd842c32f6f5b262db8eeda8e16d0c2",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-french-fries-50.svg": "336bfedb8a1e066d90f0cee995ee9e39",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-bread-50.svg": "4f9cc6339ca08d225458002a56950206",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-jam-50-2.svg": "cdaefb5c029264941ff4c43e191f9a55",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-pizza-50.svg": "7fe459ba293c003b9be8e68b56c37e60",
"assets/assets/icons/food_icons/kawaii/icons8-kawaii-sushi-50.svg": "35f9d34b2824b09c6e062bd24397ee3e",
"assets/assets/icons/food_icons/kawaii/icons8-cute-pumpkin-50.svg": "66f2d2c84ee23bf2194e2df7e0cfe5ad",
"assets/assets/icons/food_icons/bakery/icons8-baguette-50.svg": "314a7784e1492dd742e4678f43780a90",
"assets/assets/icons/food_icons/bakery/icons8-bread-and-rolling-pin-50.svg": "3f0e8291547882f6b5e51eb58eb7776a",
"assets/assets/icons/food_icons/bakery/icons8-biscuits-50.svg": "48c27fa0756bb1b70fe0f08c95df6d78",
"assets/assets/icons/food_icons/bakery/icons8-naan-50.svg": "6901353a60ecca173f314e689c27000b",
"assets/assets/icons/food_icons/bakery/icons8-bread-loaf-50.svg": "4eb08b1c0caeff94590df25888f0dc8d",
"assets/assets/icons/food_icons/bakery/icons8-pretzel-50.svg": "6ba2636f0418e224a7f689a19fb83d2d",
"assets/assets/icons/food_icons/bakery/icons8-gingerbread-house-50.svg": "5912b6af27a72ef913e1b5ac07c96e08",
"assets/assets/icons/food_icons/bakery/icons8-bread-and-rye-50.svg": "b73909706b2a4e2363dcff71ec3e262e",
"assets/assets/icons/food_icons/bakery/icons8-merry-pie-50.svg": "5c4edb160bd3d12c0b888c32f8fd0d11",
"assets/assets/icons/food_icons/bakery/icons8-brezel-50.svg": "b89b1f1d9f21e96c8700e0808017016d",
"assets/assets/icons/food_icons/bakery/icons8-bread-50.svg": "826cf682fe7b02aafdc0d4b4e80922a9",
"assets/assets/icons/food_icons/bakery/icons8-bake-50.svg": "5e96b738485e629e8079813461b5aa35",
"assets/assets/icons/food_icons/meat/icons8-steak-50.svg": "7c1f88ed6ce88b6b1d434d7c50edee33",
"assets/assets/icons/food_icons/meat/icons8-meat-50.svg": "c210e2d62dd61d2fa271b0c641e1951b",
"assets/assets/icons/food_icons/meat/icons8-beef-50.svg": "1d8acd0b2c6614af3c1e207e79ab029e",
"assets/assets/icons/food_icons/meat/icons8-barbeque-50.svg": "eef583d8a784c00c37790e82f7b9dc12",
"assets/assets/icons/food_icons/meat/icons8-steak-very-hot-50.svg": "bfebbab19ed19e748527a45bab00e6e3",
"assets/assets/icons/food_icons/meat/icons8-poultry-leg-50.svg": "c997dcfe5d1b50587439fceaae959935",
"assets/assets/icons/food_icons/meat/icons8-steak-hot-50.svg": "f5d241b815a423f73ec544528aba2830",
"assets/assets/icons/food_icons/meat/icons8-bacon-50.svg": "2d4f3851f1d9c0e2c54eb3039e57c157",
"assets/assets/icons/food_icons/meat/icons8-sausages-50.svg": "45eb0b57938132505974e2f7e13facc8",
"assets/assets/icons/food_icons/meat/icons8-barbecue-50.svg": "70a8b49f754004508a61f558f7aa2c7e",
"assets/assets/icons/food_icons/meat/icons8-sausage-50.svg": "f1ce053ec6368ccf0fecb2267b6112e9",
"assets/assets/icons/food_icons/meat/icons8-thanksgiving-50.svg": "d06e264157e9c545775b90f9c0916c2b",
"assets/assets/icons/food_icons/meat/icons8-cuts-of-beef-50.svg": "266f0e15fb3760bf61720c3ca5fa3564",
"assets/assets/icons/food_icons/meat/icons8-jamon-50.svg": "8a7c9b72a05d593784d86ed1aed51569",
"assets/assets/icons/food_icons/meat/icons8-iranian-kebab-50.svg": "067d87e368aad9227e1f7298eb0baf43",
"assets/assets/icons/food_icons/meat/icons8-souvla-50.svg": "86f6d6639167af6e551277e2a7d7d277",
"assets/assets/icons/food_icons/meat/icons8-kebab-50.svg": "e9d61c6ee1eec7ced5db541d3d6768ee",
"assets/assets/icons/food_icons/meat/icons8-cuts-of-pork-50.svg": "49fe684e93351d4ba09cb0f61dfc5946",
"assets/assets/icons/food_icons/meat/icons8-roast-50.svg": "94d92e6f712e435b2185d3e2feda6017",
"assets/assets/icons/food_icons/vegetables/icons8-carrot-50.svg": "82ea3dc5fe21ec5f4190aa069ab3706b",
"assets/assets/icons/food_icons/vegetables/icons8-cauliflower-50.svg": "ad99029d5a6755016249732abc068fa3",
"assets/assets/icons/food_icons/vegetables/icons8-pumpkin-50.svg": "250fc38e3b3aa7fe14ddbda8560e69b9",
"assets/assets/icons/food_icons/vegetables/icons8-bok-choy-50.svg": "31b938362ec76453d0a1bff795db1cce",
"assets/assets/icons/food_icons/vegetables/icons8-artichoke-50.svg": "8a29a4ae9a04dd05d67fb8f5b8b4d81f",
"assets/assets/icons/food_icons/vegetables/icons8-soy-50.svg": "cc28eb249e8ba150b3fe67b96a1e8ccb",
"assets/assets/icons/food_icons/vegetables/icons8-vegetables-box-50.svg": "d267f6871ef4ca4b95ef31c5b12fb9f1",
"assets/assets/icons/food_icons/vegetables/icons8-tomatoes-50.svg": "064cba8c08f048993c92679307b33470",
"assets/assets/icons/food_icons/vegetables/icons8-kohlrabi-50.svg": "780473057528b6b048234ee40104b2c3",
"assets/assets/icons/food_icons/vegetables/icons8-tomato-50.svg": "28138e9eec581107a12fbf9c65da81e8",
"assets/assets/icons/food_icons/vegetables/icons8-leek-50.svg": "8ce771fab0db3699c521cc1360788833",
"assets/assets/icons/food_icons/vegetables/icons8-chili-pepper-50.svg": "d4345ba9942c14d92c276681bebba66e",
"assets/assets/icons/food_icons/vegetables/icons8-corn-50.svg": "43f33f5ed380aae649d686518322cdbb",
"assets/assets/icons/food_icons/vegetables/icons8-spinach-50.svg": "268b7c3f51b22c4fd4fb76a4ecf7cfa8",
"assets/assets/icons/food_icons/vegetables/icons8-beet-50.svg": "5dafdd94622074804b288a8dfc230af7",
"assets/assets/icons/food_icons/vegetables/icons8-broccolini-50.svg": "560c82565ecb31e63795918b455d47d8",
"assets/assets/icons/food_icons/vegetables/icons8-white-beans-50.svg": "33a19987b30a71a9f0686fe18b360781",
"assets/assets/icons/food_icons/vegetables/icons8-vegetables-bag-50.svg": "59605c15d0aef0dba045bdd865bc418f",
"assets/assets/icons/food_icons/vegetables/icons8-celery-50.svg": "27d4f83ff1adbdba4e21dd31dd24596a",
"assets/assets/icons/food_icons/vegetables/icons8-zucchini-50.svg": "83c74735c2e6a53d05a3ef705329a686",
"assets/assets/icons/food_icons/vegetables/icons8-asparagus-50.svg": "f3532ef3fc1be8c9a4f7ceb69f36300d",
"assets/assets/icons/food_icons/vegetables/icons8-chard-50.svg": "52b85a5e29b42c14502ebdca2ca3d125",
"assets/assets/icons/food_icons/vegetables/icons8-radish-50.svg": "98a037ee7fba02a4e1b5aa991f8d435b",
"assets/assets/icons/food_icons/vegetables/icons8-finocchio-50.svg": "281b0ec0c972c45bd7970484ddbebc7b",
"assets/assets/icons/food_icons/vegetables/icons8-you-choy-50.svg": "24a5bdfda63549b1429e451d62c7d7ff",
"assets/assets/icons/food_icons/vegetables/icons8-broccoli-50.svg": "b1d805afcdfa945070a34206a8d14d27",
"assets/assets/icons/food_icons/vegetables/icons8-group-of-vegetables-50.svg": "bb4a842be8153d3a4f52ebc1dd03148c",
"assets/assets/icons/food_icons/vegetables/icons8-sweet-potato-50.svg": "85bee9dd9c49666602d47b2d36d246ea",
"assets/assets/icons/food_icons/vegetables/icons8-onion-50.svg": "d8d53090af3a2e1f10362c4c08c3fea5",
"assets/assets/icons/food_icons/vegetables/icons8-gailan-50.svg": "9cadde02adcb1c8a72cef0ae6051ef3a",
"assets/assets/icons/food_icons/vegetables/icons8-eggplant-50.svg": "75800f62a142e2377877d34d7a9b5de9",
"assets/assets/icons/food_icons/vegetables/icons8-lettuce-50.svg": "4c6541c5257580c4b7bb02e186cd1aee",
"assets/assets/icons/food_icons/vegetables/icons8-squash-50.svg": "11d0df1c99499ea935dec53bb513145a",
"assets/assets/icons/food_icons/vegetables/icons8-cabbage-50.svg": "ae3545124b773d85a6347842d8a387b3",
"assets/assets/icons/food_icons/vegetables/icons8-collard-greens-50.svg": "176765a557bacfeaddc0acda5d992ca5",
"assets/assets/icons/food_icons/other/icons8-butter-churn-50.svg": "ec6c6ebc7bf95d89cbf5b37f7bb51bb7",
"assets/assets/icons/food_icons/other/icons8-empty-jam-jar-50.svg": "039558aa46040f000000b6b0411c050d",
"assets/assets/icons/food_icons/other/icons8-halal-food-50.svg": "8b22a7f5cf49af30ce4323223ec69892",
"assets/assets/icons/food_icons/other/icons8-hot-chocolate-with-marshmallows-50.svg": "51c32cea79444d650aaeffb740a8291c",
"assets/assets/icons/food_icons/other/icons8-picnic-50.svg": "0580453c9397137a6eff117f0947cb61",
"assets/assets/icons/food_icons/other/icons8-grocery-bag-50.svg": "4c308cab4142df5debcb34d6e7fa33ab",
"assets/assets/icons/food_icons/other/icons8-haram-food-50.svg": "e4baccfd2dcad2b8df00a6910b9adb4a",
"assets/assets/icons/food_icons/other/icons8-peas-50.svg": "0d6a21e27390ddaeab2503359b7c5fd9",
"assets/assets/icons/food_icons/other/icons8-firm-tofu-50.svg": "d09101a415b400c9b5bf2b896d487138",
"assets/assets/icons/food_icons/other/icons8-lunch-50.svg": "9b5c3fc024fb76f8ebca80b7c77e5c90",
"assets/assets/icons/food_icons/other/icons8-heinz-beans-50.svg": "69b937e994a817f8ff9b45c44c10a13a",
"assets/assets/icons/food_icons/other/icons8-grocery-shelf-50.svg": "c8137b57e328e9524be707c58627c19a",
"assets/assets/icons/food_icons/other/icons8-sabzeh-50.svg": "aaef2a3f1df45fcd1f17ce90dfb1c194",
"assets/assets/icons/food_icons/other/icons8-deliver-food-50.svg": "a6c03b02a652c08562474c07d1bb21f1",
"assets/assets/icons/food_icons/other/icons8-fast-food-drive-thru-50.svg": "41412d7fa30d975e2aa3c54a6795f3e2",
"assets/assets/icons/food_icons/other/icons8-coffee-beans-50.svg": "5061c1e8a00ec5b7fdcd8003ecd17a3a",
"assets/assets/icons/food_icons/other/icons8-breakfast-50.svg": "2e71d92b13184e8249f09cbc7b08d565",
"assets/assets/icons/food_icons/other/icons8-soup-plate-50.svg": "d7a7ceb816a72e6858e0f3f29a2d7131",
"assets/assets/icons/food_icons/other/icons8-fast-moving-consumer-goods-50.svg": "795eb474c458a71b345fec095afc04cb",
"assets/assets/icons/food_icons/other/icons8-flour-50.svg": "c02675f471438168c7baffaa7682050e",
"assets/assets/icons/food_icons/other/icons8-tiffin-50.svg": "c6a493d945578802f9421d517a02bcd1",
"assets/assets/icons/food_icons/other/icons8-food-receiver-50.svg": "314d239ae297264051fe9d5ab9ad759b",
"assets/assets/icons/food_icons/other/icons8-ice-50.svg": "5d3234049c388963470c783e52c949af",
"assets/assets/icons/food_icons/other/icons8-olive-50.svg": "6cdee24c8a077c63600dafcb60c24396",
"assets/assets/icons/food_icons/other/icons8-mushroom-50.svg": "5ff056c7196bbaa3f57ea089ad166643",
"assets/assets/icons/food_icons/other/icons8-international-food-50.svg": "0a30e599fdf231e8aad81b4b43b63ebe",
"assets/assets/icons/food_icons/other/icons8-brigadeiro-50.svg": "c324297d0167617562a54fb3b79753d6",
"assets/assets/icons/food_icons/other/icons8-egg-stand-50.svg": "20a75389b7118ff7525b9c71a4cb1d40",
"assets/assets/icons/food_icons/other/icons8-nonya-kueh-50.svg": "5c4a45e8948e3bb4f7dd497fe3d1a884",
"assets/assets/icons/food_icons/other/icons8-gum-50.svg": "40b29bb35e8de3af57a80e164dbbd34b",
"assets/assets/icons/food_icons/other/icons8-bad-apple-50.svg": "68677e59960e91e952449e5f97cc449a",
"assets/assets/icons/food_icons/other/icons8-wicker-basket-50.svg": "25bfbb71db4000d4d2c8c60a553d3d37",
"assets/assets/icons/food_icons/other/icons8-biting-a-carrot-50.svg": "79ec8c54490663a922ac6c2222172e92",
"assets/assets/icons/food_icons/other/icons8-potato-50.svg": "21b7b436df4d8559b74d51eeb7982565",
"assets/assets/icons/food_icons/other/icons8-real-food-for-meals-50.svg": "e9ff7e14a0b6b8aeaa065b91bfdf5edb",
"assets/assets/icons/food_icons/other/icons8-salami-50.svg": "a17468a6e04f7ebbdca8c74374cf8b28",
"assets/assets/icons/food_icons/other/icons8-garlic-50.svg": "6b2b46d5213584d69f941317a0943907",
"assets/assets/icons/food_icons/other/icons8-stir-50.svg": "d7d852c3a21c101e2e6537c925daceee",
"assets/assets/icons/food_icons/other/icons8-spoiled-food-50.svg": "8ed7214d1b434d190da03a65ab5ea6ab",
"assets/assets/icons/food_icons/other/icons8-topping-50.svg": "035085b3b72e4e11ca7a8bf988390bcb",
"assets/assets/icons/food_icons/other/icons8-paprika-50.svg": "3d65092e232acc9db9928ab0eb4b5928",
"assets/assets/icons/food_icons/other/icons8-rack-of-lamb-50.svg": "18f59e1285dda544390debce863f0dab",
"assets/assets/icons/food_icons/other/icons8-low-cholesterol-food-50.svg": "34008a675d42849a167a8538c2f43439",
"assets/assets/icons/food_icons/other/icons8-cooking-book-50.svg": "aa64bda188b6a51675a453a4ac46bfeb",
"assets/assets/icons/food_icons/other/icons8-tempeh-50.svg": "3fe8defba9f3b0907c261cbb85f2214f",
"assets/assets/icons/food_icons/other/icons8-cookbook-50.svg": "9b9607a2fc3f67a38681e7956493e238",
"assets/assets/icons/food_icons/other/icons8-mushbooh-food-50.svg": "e0a55ebfbfc5f9e38183d37d2d26f0a0",
"assets/assets/icons/food_icons/other/icons8-food-donor-50.svg": "22d0d965e3940bee98ab318f738601e8",
"assets/assets/icons/food_icons/other/icons8-lettuce-50.svg": "a8daa4d812c208c83667b753df3de678",
"assets/assets/icons/food_icons/other/icons8-plum-50.svg": "569dc59f88793e37e07ef6fdc5943283",
"assets/assets/icons/food_icons/other/icons8-kiwi-50.svg": "155ee8ce80595982fb0ed49fb97eb4d1",
"assets/assets/icons/food_icons/other/icons8-diabetic-food-50.svg": "7f86844e07702bdba149d5e28ccea13a",
"assets/assets/icons/food_icons/other/icons8-silken-tofu-50.svg": "ea8296e30ef8a0a559b461b34f586fe8",
"assets/assets/icons/food_icons/other/icons8-dinner-50.svg": "25457b2283643edfcb87338e067a8ab6",
"assets/assets/icons/food_icons/seafood/icons8-octopus-50.svg": "a78e9028dadd3248555de6bb3400a9f3",
"assets/assets/icons/food_icons/seafood/icons8-fish-fillet-50.svg": "d679d95c605b48b2a5c5dda8ba9bc53b",
"assets/assets/icons/food_icons/seafood/icons8-crab-50.svg": "f6eb7991d03b2e4286da87be508c7e6f",
"assets/assets/icons/food_icons/seafood/icons8-shellfish-50.svg": "0fc7913f52f01c88b1e432297aab9b2a",
"assets/assets/icons/food_icons/seafood/icons8-dressed-fish-50.svg": "e300930e4068107a1ec281c6888f2fa7",
"assets/assets/icons/food_icons/seafood/icons8-fish-food-50.svg": "20e041189617c6e58c00d133628e21d0",
"assets/assets/icons/food_icons/seafood/icons8-prawn-50.svg": "8038669fbc513925c2fa410838171cdb",
"assets/assets/icons/food_icons/seafood/icons8-whole-fish-50.svg": "4d21d8a5f8dd7e11233adc321550cba0",
"assets/assets/icons/food_icons/desserts/icons8-berry-jam-50.svg": "9c0af7fac59b02a330c6cdb027b78115",
"assets/assets/icons/food_icons/desserts/icons8-melting-ice-cream-50.svg": "d2ae2820d9ef439fa03801b36a779997",
"assets/assets/icons/food_icons/desserts/icons8-banana-split-50.svg": "47e080fd1a35ebf09164dc0c64b3c51b",
"assets/assets/icons/food_icons/desserts/icons8-sweets-50.svg": "e1e03a98a46dc128d8c0fabce6ed362b",
"assets/assets/icons/food_icons/desserts/icons8-ice-cream-cone-50.svg": "66906c19d951875e3dda7fd8a47a51eb",
"assets/assets/icons/food_icons/desserts/icons8-chocolate-bar-50.svg": "3abd8b224caf61b2b4a14d363e9f82ed",
"assets/assets/icons/food_icons/desserts/icons8-pastel-de-nata-50.svg": "26fc0040d3a800857d71f00ff9a10df2",
"assets/assets/icons/food_icons/desserts/icons8-apple-jam-50.svg": "d72ab40371377c9f6e1dd2ff75766eac",
"assets/assets/icons/food_icons/desserts/icons8-candy-50.svg": "d60345b5ddfe6d8cf1a943d148481592",
"assets/assets/icons/food_icons/desserts/icons8-ice-cream-sundae-50.svg": "0d70453ad74f0f5aa0ab49ddc60e8a1e",
"assets/assets/icons/food_icons/desserts/icons8-cotton-candy-50.svg": "555a395c7874dc8930bdabe1f4c1d406",
"assets/assets/icons/food_icons/desserts/icons8-cheesecake-50.svg": "9a28b78204760880e52b8058588f468a",
"assets/assets/icons/food_icons/desserts/icons8-cherry-cheesecake-50.svg": "5a898bd92a34e8f83d9e965a1462dd47",
"assets/assets/icons/food_icons/desserts/icons8-dessert-50.svg": "ee08f9b2a1efc8cce0a590ce0b8a1fa6",
"assets/assets/icons/food_icons/desserts/icons8-strawberry-cheesecake-50.svg": "08f0074e70def3026621559826c79039",
"assets/assets/icons/food_icons/desserts/icons8-jam-50.svg": "2eb3b67e1e3dadb4c85260b39e276c37",
"assets/assets/icons/food_icons/desserts/icons8-chocolate-bar-white-50.svg": "35ec89c765fe431f8d3496b6ce2a8845",
"assets/assets/icons/food_icons/desserts/icons8-jelly-50.svg": "517371011289d01444ec59bde9bb205c",
"assets/assets/icons/food_icons/pastries/icons8-cookie-50.svg": "4c6e4ddb091f802b15c73824ddc042cf",
"assets/assets/icons/food_icons/pastries/icons8-samosa-50.svg": "854c6785ef6365590cbb8a0e76b984f3",
"assets/assets/icons/food_icons/pastries/icons8-cupcake-50.svg": "d4829b19714f84a897d594efcd0e683c",
"assets/assets/icons/food_icons/pastries/icons8-cookies-50.svg": "8338bbf01cb966b69f8a2a74c9b60208",
"assets/assets/icons/food_icons/pastries/icons8-croissant-50.svg": "c3f5550ea2d0fb80ddb8c5adf806bc4d",
"assets/assets/icons/food_icons/pastries/icons8-pie-50.svg": "e50a20e0b3c834fb719bc189629ca90a",
"assets/assets/icons/food_icons/pastries/icons8-doughnut-50.svg": "ff180ff461eb96fc9e11e94930be371f",
"assets/assets/icons/food_icons/pastries/icons8-birthday-cake-50.svg": "db5d4889b4fb05a56a1af69d259f7915",
"assets/assets/icons/food_icons/pastries/icons8-macaron-50.svg": "14e2b96852d2d1308969c73297c817fc",
"assets/assets/icons/food_icons/pastries/icons8-korean-rice-cake-50.svg": "5fed818efc5f45252cb97803925dec10",
"assets/assets/icons/food_icons/pastries/icons8-cake-50.svg": "2687b62e23d351938cc381a43558a3b7",
"assets/assets/icons/food_icons/pastries/icons8-cinnamon-roll-50.svg": "23a7a4aa011dc586673a7d5b91f40188",
"assets/assets/icons/food_icons/ingredients/icons8-chia-seeds-50.svg": "b8983af9ed9241eeed4130d335b9b071",
"assets/assets/icons/food_icons/ingredients/icons8-cinnamon-sticks-50.svg": "4de3814ae2d6c99b2164827bc0f9f82e",
"assets/assets/icons/food_icons/ingredients/icons8-maple-syrup-50.svg": "65e07e0e1efbcb91aa78e5a7363f117f",
"assets/assets/icons/food_icons/ingredients/icons8-hamper-50.svg": "1dd0d4c9765e4adc2c368773c8b5fe55",
"assets/assets/icons/food_icons/ingredients/icons8-sweetener-50.svg": "75c366f2444779fe871e946649df3e82",
"assets/assets/icons/food_icons/ingredients/icons8-ketchup-50.svg": "d6e056bd93fd4fcd168cff63fc530ed6",
"assets/assets/icons/food_icons/ingredients/icons8-flour-in-paper-packaging-50.svg": "d9d46c8e24ab733ff7736d15e467030d",
"assets/assets/icons/food_icons/ingredients/icons8-eggs-50.svg": "17083ab53e7d26a02a0db4bfa86f70ea",
"assets/assets/icons/food_icons/ingredients/icons8-pistachio-sauce-50.svg": "3625dfd89080634dc9e0bbf1bbe3db25",
"assets/assets/icons/food_icons/ingredients/icons8-icing-sugar-50.svg": "fa4d2fc05319ee32b0ebe4aec3ce2fc5",
"assets/assets/icons/food_icons/ingredients/icons8-ginger-50.svg": "ef0f25c7afb95679585dc38be39d6c2d",
"assets/assets/icons/food_icons/ingredients/icons8-basil-50.svg": "24f65138d72f792243ecd2a2c045c947",
"assets/assets/icons/food_icons/ingredients/icons8-flax-seeds-50.svg": "1213b1cf7268e314113950331b343bea",
"assets/assets/icons/food_icons/ingredients/icons8-worcestershire-sauce-50.svg": "254208171d3bad3416c247d49f69e976",
"assets/assets/icons/food_icons/ingredients/icons8-dozen-eggs-50.svg": "48c3c68c6a26941fcc6086e3b362b81f",
"assets/assets/icons/food_icons/ingredients/icons8-sugar-cubes-50.svg": "0d749dede42bb9750a275b741437ef36",
"assets/assets/icons/food_icons/ingredients/icons8-quorn-50.svg": "d5f4efa8f913521adcac6d40f4e04bdd",
"assets/assets/icons/food_icons/ingredients/icons8-sesame-50.svg": "e2d0f7a615d1d64f857b6640f1876741",
"assets/assets/icons/food_icons/ingredients/icons8-dressing-50.svg": "f48be298466ba3c3952cd2e89199ff9f",
"assets/assets/icons/food_icons/ingredients/icons8-olive-oil-50.svg": "ff400ae6993ea2fdf799d906f2d87c2e",
"assets/assets/icons/food_icons/ingredients/icons8-salt-shaker-50.svg": "b4257e46c7cff579b01156682355e07b",
"assets/assets/icons/food_icons/ingredients/icons8-honey-50.svg": "5d3cf28a602e72cd2d512f1cba4f3c45",
"assets/assets/icons/food_icons/ingredients/icons8-sugar-50.svg": "09b036c8c0fedce5b10a786794e02f11",
"assets/assets/icons/food_icons/ingredients/icons8-rolled-oats-50.svg": "33f06798b541a1f04cb3ffddce45aff6",
"assets/assets/icons/food_icons/ingredients/icons8-egg-basket-50.svg": "34008524a0a48cd8979075a1cdad7ece",
"assets/assets/icons/food_icons/ingredients/icons8-flour-of-rye-50.svg": "e7bb7cb408f56e9139da15da15b95987",
"assets/assets/icons/food_icons/ingredients/icons8-spice-50.svg": "a1e1dbc9b0700f8d20023db632b0ca46",
"assets/assets/icons/food_icons/ingredients/icons8-butter-50.svg": "bad1678c2f679d134a578c8b69e0ace6",
"assets/assets/icons/food_icons/ingredients/icons8-sesame-oil-50.svg": "12f5b2acc1117adde0e0d7ff480072a6",
"assets/assets/icons/food_icons/ingredients/icons8-olive-oil-bottle-50.svg": "ec3e9861297f5d06440ac2aabad6f320",
"assets/assets/icons/food_icons/ingredients/icons8-peanut-butter-50.svg": "36ec337c04126944a94c6cbf949ae049",
"assets/assets/icons/food_icons/ingredients/icons8-mustard-50.svg": "cded5a57a056ea794dfe856876d6fae7",
"assets/assets/icons/food_icons/ingredients/icons8-thyme-50.svg": "fe5f428f390be4292d85dc97cb278b96",
"assets/assets/icons/food_icons/ingredients/icons8-almond-butter-50.svg": "e15449295eaa628bed23bfedb5a07444",
"assets/assets/icons/food_icons/ingredients/icons8-honey-dipper-with-honey-dripping-50.svg": "8cf872a6860a9cb5920a09b76a4667dd",
"assets/assets/icons/food_icons/ingredients/icons8-sunflower-butter-50.svg": "fbeec1b3429ffedcc02ee9860129e6d4",
"assets/assets/icons/food_icons/ingredients/icons8-list-view-50.svg": "e49aff95a6314ee746d4f4ee3de60cd8",
"assets/assets/icons/food_icons/ingredients/icons8-sauce-bottle-50.svg": "aaa30086bd9975d54fc65b47e412b750",
"assets/assets/icons/food_icons/ingredients/icons8-lentil-50.svg": "17f51205ab9bd9c4c5b3e811ddf849ba",
"assets/assets/icons/food_icons/ingredients/icons8-raisins-50.svg": "2f114542193d7e38d130e99ba63deb2d",
"assets/assets/icons/food_icons/ingredients/icons8-mint-50.svg": "f94e445d4f5e2855b80f77b4a1b5fa69",
"assets/assets/icons/food_icons/ingredients/icons8-vegetable-bouillion-paste-50.svg": "ee0389ad0a6a5723fb27bae124116955",
"assets/assets/icons/food_icons/ingredients/icons8-sunflower-oil-50.svg": "d10d74d029451a38d863e45d6155bc67",
"assets/assets/icons/food_icons/ingredients/icons8-ingredients-for-cooking-50.svg": "8b1d56613f7ec0936a5bb47229caf292",
"assets/assets/icons/food_icons/ingredients/icons8-grains-of-rice-50.svg": "c3ce8f5fc4a80ae3a6c66f34fd71dbcb",
"assets/assets/icons/food_icons/ingredients/icons8-egg-carton-50.svg": "ef394076b60563da35f89284790e6a72",
"assets/assets/icons/food_icons/ingredients/icons8-ingredients-50.svg": "d9fdb6e8797a128be0cfc0c37cb8fb00",
"assets/assets/icons/food_icons/ingredients/icons8-honey-spoon-50.svg": "5f8b25415a13e69aa1a48243a1802002",
"assets/assets/icons/food_icons/ingredients/icons8-spoon-of-sugar-50.svg": "638d24e1c91d6c34834146b292ca70a5",
"assets/assets/icons/food_icons/ingredients/icons8-mozzarella-50.svg": "48d3bc4a9c2823fbbe5618c40066256a",
"assets/assets/icons/food_icons/ingredients/icons8-mayonnaise-50.svg": "7c02a8f6e6f382afd6248445af7a6e77",
"assets/assets/icons/food_icons/ingredients/icons8-whipped-cream-50.svg": "a908cdbb7a275984d0557424db914381",
"assets/assets/icons/food_icons/ingredients/icons8-sugar-cube-50.svg": "eae80d15ec1f9eca4b7f671bcf5dc896",
"assets/assets/icons/food_icons/ingredients/icons8-rice-vinegar-50.svg": "99bb9a2d6d354f5b65d09b4751cf5f97",
"assets/assets/icons/food_icons/ingredients/icons8-soy-sauce-50.svg": "77a33963f9705b03fad11c07e63facb9",
"assets/assets/icons/food_icons/dishes/icons8-chocolate-spread-50.svg": "08ae5ade68f249a9e6decd1a82ea4cb0",
"assets/assets/icons/food_icons/dishes/icons8-salad-50.svg": "db0cd9e99b2a03a19bf086bb056f666c",
"assets/assets/icons/food_icons/dishes/icons8-spam-can-50.svg": "3f4ff87fd8236961534729ff4cdee441",
"assets/assets/icons/food_icons/dishes/icons8-fish-and-vegetables-50.svg": "3bd7115ee6103d4141c7e777f11e656d",
"assets/assets/icons/food_icons/dishes/icons8-toast-50.svg": "b5f16719f16f65806e62ae2668744e00",
"assets/assets/icons/food_icons/dishes/icons8-greek-salad-50.svg": "f37a0585e18fe6e2d63f755f05483106",
"assets/assets/icons/food_icons/dishes/icons8-guacamole-50.svg": "577e76612d22cf9687007a347aae0abf",
"assets/assets/icons/food_icons/dishes/icons8-sandwich-with-fried-egg-50.svg": "5fc73d1399149502084741f53cf51691",
"assets/assets/icons/food_icons/dishes/icons8-paella-50.svg": "6a1166ec4a2ab762bca5fb0076847e2c",
"assets/assets/icons/food_icons/dishes/icons8-rice-bowl-50.svg": "55527ec3991c9e297d876c3df2eb6c3f",
"assets/assets/icons/food_icons/dishes/icons8-sunny-side-up-eggs-50.svg": "30dcf24e5f61fc0c711de94fee507be1",
"assets/assets/icons/food_icons/dishes/icons8-tapas-50.svg": "5dfdf1a02dcc2170733290366ba3ef1f",
"assets/assets/icons/food_icons/dishes/icons8-salmon-sushi-50.svg": "6f4d8bd850eb50b0c260c4bdef4293ed",
"assets/assets/icons/food_icons/dishes/icons8-cheese-50.svg": "01817e3a231174acf1227ac5f9ed3e0b",
"assets/assets/icons/food_icons/dishes/icons8-rice-bowl-50-2.svg": "55527ec3991c9e297d876c3df2eb6c3f",
"assets/assets/icons/food_icons/dishes/icons8-noodles-50.svg": "aa7ace46ada1b675e12296fcd192a29d",
"assets/assets/icons/food_icons/dishes/icons8-yogurt-50.svg": "597547d9e640411a48f64e2c58c8cc2e",
"assets/assets/icons/food_icons/dishes/icons8-bento-50.svg": "734433381f4d16ed3f3b5aeeb6d97e46",
"assets/assets/icons/food_icons/dishes/icons8-dim-sum-50.svg": "e4af73ab38c13d98de32c054663d1735",
"assets/assets/icons/food_icons/dishes/icons8-omlette-50.svg": "784d567907bb2d5b82d8bbd00062aab5",
"assets/assets/icons/food_icons/dishes/icons8-tin-can-50.svg": "b7a199de0ef1cfdafeb2b75d1e58b7d1",
"assets/assets/icons/food_icons/dishes/icons8-caviar-50.svg": "4c1209acaa7aef0d38fe900904cb3fb5",
"assets/assets/icons/food_icons/dishes/icons8-porridge-50.svg": "9f1b47a759bff44b3536c3bc838ae289",
"assets/assets/icons/food_icons/dishes/icons8-sauce-50.svg": "083fa9d4ca0ed2d406bd04848f648344",
"assets/assets/icons/food_icons/dishes/icons8-spring-roll-50.svg": "383c47b99cf6319dd2ecad5ab2da01a0",
"assets/assets/icons/food_icons/dishes/icons8-fondue-50.svg": "63822427904f9ada7746ccdbe8482b46",
"assets/assets/icons/food_icons/dishes/icons8-gyoza-50.svg": "63c85a2db7f883ccaada11cd634d8e47",
"assets/assets/icons/food_icons/dishes/icons8-pancake-stack-50.svg": "90d21bedd1eedc2e144be1b75abee85b",
"assets/assets/icons/food_icons/dishes/icons8-seafood-50.svg": "409ad964f6d61d7c9a304d75c4ced1ce",
"assets/assets/icons/food_icons/dishes/icons8-dolmades-50.svg": "9c68f1fddddeafcd84d4fd11ba341acd",
"assets/assets/icons/food_icons/dishes/icons8-lunchbox-50.svg": "68692e4d461bcada48e4cb35d42ef3c3",
"assets/assets/icons/food_icons/dishes/icons8-salami-pizza-50.svg": "bc8eb5969edf490936f0044270de3aa5",
"assets/assets/icons/food_icons/dishes/icons8-spaghetti-50.svg": "6984d8cbd4a3e75025c29e23c4fbb92e",
"assets/assets/icons/food_icons/dishes/icons8-food-and-wine-50.svg": "0aa1e551aff8b52e7e36f94a4a9b48a9",
"assets/assets/icons/food_icons/dishes/icons8-bagel-50.svg": "2dc4594a4a1f87eaaa29254645501029",
"assets/assets/icons/food_icons/dishes/icons8-lasagna-50.svg": "74c5798aa5cc5ef5fb9cd852efe563b6",
"assets/assets/icons/food_icons/dishes/icons8-sushi-50.svg": "c15b783a6cf093b7901be1e15424714e",
"assets/assets/icons/food_icons/fruits/icons8-jackfruit-50.svg": "9e73e398122617047b38083a4039d3ed",
"assets/assets/icons/food_icons/fruits/icons8-coconut-50.svg": "01d598f8b3b68db8d43257c695fd79ea",
"assets/assets/icons/food_icons/fruits/icons8-soursop-50.svg": "1336434f6ea81dd6ddc7fc2112035d0d",
"assets/assets/icons/food_icons/fruits/icons8-mangosteen-50.svg": "fc4e7e388969a5278e6c3066ee109fa8",
"assets/assets/icons/food_icons/fruits/icons8-cut-watermelon-50.svg": "034ac3d0a3863aee4b913913379197a5",
"assets/assets/icons/food_icons/fruits/icons8-rambutan-50.svg": "a0c50c06a41c0affa5d0885e119e7fd5",
"assets/assets/icons/food_icons/fruits/icons8-lime-50.svg": "49884d50e0191c0d2526c12c09fcd7fd",
"assets/assets/icons/food_icons/fruits/icons8-watermelon-50-2.svg": "02f7e2fcd2e670d4b146bd61730a3fa3",
"assets/assets/icons/food_icons/fruits/icons8-papaya-50.svg": "c7c0bb567588f7aa11dd81092cf6d16a",
"assets/assets/icons/food_icons/fruits/icons8-cucumber-50.svg": "17c89ddbcecb3a30b209995b1d7afdb2",
"assets/assets/icons/food_icons/fruits/icons8-pears-50.svg": "96ecdc826de4f0d2d88c5be95dd9816b",
"assets/assets/icons/food_icons/fruits/icons8-orange-50.svg": "4aea7f03ffbe5a90974ecb79423d965f",
"assets/assets/icons/food_icons/fruits/icons8-peeled-banana-50.svg": "47f1a4c4c22c1816fd6ec89fc2ce36f5",
"assets/assets/icons/food_icons/fruits/icons8-peach-50.svg": "ddb7e4c5b33cd7bf9f8497051e1cb5c4",
"assets/assets/icons/food_icons/fruits/icons8-bad-banana-50.svg": "d0a87c0c9a5235ff65ab10dfab874b2a",
"assets/assets/icons/food_icons/fruits/icons8-group-of-fruits-50.svg": "761f9b7a50393451a87ff2dc97c4174b",
"assets/assets/icons/food_icons/fruits/icons8-apricot-50.svg": "9292b6b7ae47680c685451014cd42ff4",
"assets/assets/icons/food_icons/fruits/icons8-whole-apple-50.svg": "4a222cd9a431bfa1fe6281d2be63048c",
"assets/assets/icons/food_icons/fruits/icons8-cut-melon-50.svg": "45e4063dfcb83a329a4e12942aed41ab",
"assets/assets/icons/food_icons/fruits/icons8-citrus-50.svg": "96b40d2ff993767dfac57b0e9856ebbd",
"assets/assets/icons/food_icons/fruits/icons8-melon-50.svg": "622606acd086cd6ebc4f88323f9f6b18",
"assets/assets/icons/food_icons/fruits/icons8-coconut-50-2.svg": "5f3f06ae23e40a2126af15c0a8033cf6",
"assets/assets/icons/food_icons/fruits/icons8-lychee-50.svg": "ce707de237006848e16b6cd85b51e09e",
"assets/assets/icons/food_icons/fruits/icons8-fig-fruit-50.svg": "d2c86f04ed48b15bed5dc188ef6f358c",
"assets/assets/icons/food_icons/fruits/icons8-apple-fruit-50.svg": "85f06a67de1d80e984f8624f1eaa39e8",
"assets/assets/icons/food_icons/fruits/icons8-citrus-50-2.svg": "35f53effab182c3d487d104d9d5a664c",
"assets/assets/icons/food_icons/fruits/icons8-half-orange-50.svg": "711a310623e5a3850fe9bf335eead69e",
"assets/assets/icons/food_icons/fruits/icons8-pear-50.svg": "9e36590152ecbdec08f63de254457ec8",
"assets/assets/icons/food_icons/fruits/icons8-apples--plate-50.svg": "c99b39c1429a72bfbd7caae5b052f080",
"assets/assets/icons/food_icons/fruits/icons8-pomegranate-50.svg": "2a64788297d8010afb99520bf825d18d",
"assets/assets/icons/food_icons/fruits/icons8-durian-50.svg": "9c507029ce4b6120054fbedb31297627",
"assets/assets/icons/food_icons/fruits/icons8-pineapple-50.svg": "1ccc9f2b105f30b18783974957448bff",
"assets/assets/icons/food_icons/fruits/icons8-tangelo-50.svg": "1d9c9849fd9b5cce11eda0f2eaaced10",
"assets/assets/icons/food_icons/fruits/icons8-dragon-fruit-50.svg": "5d999805c6391d54afdb520b4e9ae202",
"assets/assets/icons/food_icons/fruits/icons8-date-fruit-50.svg": "39d9bc882521c10aec6e3eaa25954249",
"assets/assets/icons/food_icons/fruits/icons8-mango-50.svg": "dfdf2ce6d1a3f4385f226b3065d31a0d",
"assets/assets/icons/food_icons/fruits/icons8-apples-plate-50.svg": "b324727084ace39e230ea6b9106ed5e1",
"assets/assets/icons/food_icons/fruits/icons8-whole-watermelon-50.svg": "fa66a7c870db981e838afd97dbb95e2c",
"assets/assets/icons/food_icons/fruits/icons8-bad-pear-50.svg": "815a3b4716a188e371915225cd8f4fb3",
"assets/assets/icons/food_icons/fruits/icons8-banana-50.svg": "383e9adb86131bba5612bfa3d4cf9573",
"assets/assets/icons/food_icons/fruits/icons8-avocado-50.svg": "c251b64fc4cf5ef26e66443229cb639b",
"assets/assets/icons/food_icons/fruits/icons8-watermelon-50.svg": "3cc796fd31349621a3166b32beb0e883",
"assets/assets/icons/food_icons/fruits/icons8-fruit-bag-50.svg": "ef16addfb64a039b4019b8ffc1c3cf33",
"assets/assets/icons/food_icons/fruits/icons8-bad-orange-50.svg": "31071bb007e83ba458b8c74a41e52e52",
"assets/assets/icons/food_icons/fruits/icons8-whole-melon-50.svg": "ba76affa2a30df52cdad918794746f13",
"assets/assets/icons/food_icons/nutrition/icons8-dairy-50.svg": "c54813f5068d65524d94c3dd719f2290",
"assets/assets/icons/food_icons/nutrition/icons8-no-eggs-50.svg": "6a88085aa664030091b696810ba9a64f",
"assets/assets/icons/food_icons/nutrition/icons8-fiber-50.svg": "1392c0ac21ba53d39baed4d5ed17ade1",
"assets/assets/icons/food_icons/nutrition/icons8-halal-sign-50.svg": "2092f4cab15ba47a3ddbe68904b455c4",
"assets/assets/icons/food_icons/nutrition/icons8-no-meat-50.svg": "398affa3720ffc2960594cc2aff04b2f",
"assets/assets/icons/food_icons/nutrition/icons8-no-sesame-50.svg": "452d09b6fc8ee18e87b96fa04fce8f8c",
"assets/assets/icons/food_icons/nutrition/icons8-dead-food-50.svg": "1e0ec25d50d6a4395e16409cb1fe5278",
"assets/assets/icons/food_icons/nutrition/icons8-no-soy-50.svg": "25c90c53a2a95e2efe309f8c0ea32f0e",
"assets/assets/icons/food_icons/nutrition/icons8-organic-food-50.svg": "7e54b35b0b1e159243ed0100b30b06e3",
"assets/assets/icons/food_icons/nutrition/icons8-no-gmo-50.svg": "c31ee66c1c658badab6633bb9b4127a2",
"assets/assets/icons/food_icons/nutrition/icons8-calories-50.svg": "c85120a2ee2d800a4eae3e4b6da3fe9a",
"assets/assets/icons/food_icons/nutrition/icons8-no-sugar-50.svg": "4074c069afb31087af0c59f3de61a1b1",
"assets/assets/icons/food_icons/nutrition/icons8-no-mustard-50.svg": "00bbc28ae62ccf733439cc3f4eb1459d",
"assets/assets/icons/food_icons/nutrition/icons8-healthy-food-50.svg": "c98aab2f3d8c457e9bc2ddef9fcbf506",
"assets/assets/icons/food_icons/nutrition/icons8-healthy-food-calories-calculator-50.svg": "4557a64ceea2cdf3c63340d22bd6fc47",
"assets/assets/icons/food_icons/nutrition/icons8-no-lupines-50.svg": "c0cf17c69ee098c88003d962634616b3",
"assets/assets/icons/food_icons/nutrition/icons8-no-crustaceans-50.svg": "4ef9a3a875d415138dac52a07f629547",
"assets/assets/icons/food_icons/nutrition/icons8-healthy-eating-50.svg": "bcc7c2135a7d8c4dc1711e5913d58436",
"assets/assets/icons/food_icons/nutrition/icons8-vegetarian-food-50.svg": "3cc99161d165d1284c8e2217b2e0bdbc",
"assets/assets/icons/food_icons/nutrition/icons8-vegan-food-50.svg": "c48414231d423f031dce50523d7aca08",
"assets/assets/icons/food_icons/nutrition/icons8-low-salt-50.svg": "211ea74aa479d87fad9bdd62877ed157",
"assets/assets/icons/food_icons/nutrition/icons8-no-fish-50.svg": "d9456ba49efe00a337da3dd398063e54",
"assets/assets/icons/food_icons/nutrition/icons8-no-gluten-50.svg": "a152fd1a041a31610d3c136c10e6809e",
"assets/assets/icons/food_icons/nutrition/icons8-sodium-50.svg": "7cf5e7e5b2c9acc74ca19163fda890e1",
"assets/assets/icons/food_icons/nutrition/icons8-no-pork-50.svg": "beb26d151e59f09815b83e3a43be8967",
"assets/assets/icons/food_icons/nutrition/icons8-lipids-50.svg": "ad0d72997a43a73f5a305681f83b540d",
"assets/assets/icons/food_icons/nutrition/icons8-paleo-diet-50.svg": "4656ad3d5edf2edbf782fb9e006dd541",
"assets/assets/icons/food_icons/nutrition/icons8-natural-food-50.svg": "ecf295857f69dad68224b5142102a2ef",
"assets/assets/icons/food_icons/nutrition/icons8-non-lactose-food-50.svg": "e53b6ff95538969e237c41ee91abdcd0",
"assets/assets/icons/food_icons/nutrition/icons8-no-fructose-50.svg": "a15aa06706fdd2d8e6ae365f8497dfb7",
"assets/assets/icons/food_icons/nutrition/icons8-carbohydrates-50.svg": "be03ed45d14031a0b16e692ca16fe37c",
"assets/assets/icons/food_icons/nutrition/icons8-protein-50.svg": "06995664c44e2a66c865b1aacf2ab327",
"assets/assets/icons/food_icons/nutrition/icons8-no-nuts-50.svg": "91f8d1c31dfba32bfbfc8a1048782084",
"assets/assets/icons/food_icons/nutrition/icons8-no-peanut-50.svg": "f38e5ae481d2bf22b5465778cd3a75e7",
"assets/assets/icons/food_icons/nutrition/icons8-no-shellfish-50.svg": "8235fb53399f129b86a0fcd9941c3d28",
"assets/assets/icons/food_icons/nutrition/icons8-sugar-free-50.svg": "c1f7684f0aafe0ee5bf58f19e9655469",
"assets/assets/icons/food_icons/nutrition/icons8-no-celery-50.svg": "006a6357d561d026ecb2f096d7c4a5aa",
"assets/assets/icons/food_icons/nutrition/icons8-no-apple-50.svg": "8f0fcc8d95d3b0bb613980cf86dc1f55",
"assets/assets/badges/google/android/png@4x/light/android_light_rd_ctn@4x.png": "09283aa5fae1a557d2823a09de63a9f5",
"assets/assets/badges/google/android/png@4x/light/android_light_sq_ctn@4x.png": "5b731baefe6eeff0208dcaf94395b189",
"assets/assets/badges/google/android/png@4x/dark/android_dark_rd_ctn@4x.png": "0c25d31236a4d739f968d8fdc1862193",
"assets/assets/badges/google/android/png@4x/dark/android_dark_rd_na@4x.png": "10f79edd2208a70a8b2c6b2016bdbcb8",
"assets/assets/badges/google/android/png@4x/dark/android_dark_sq_ctn@4x.png": "9ae616246a9e42ac5a229f2abfaea098",
"assets/assets/badges/google/android/png@4x/dark/android_dark_sq_na@4x.png": "2fc60cf3513fa461a285fdf9de1bc682",
"assets/assets/animations/no_internet.json": "8cebdc6bbfa1b7a36f54368edfa2dee4",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
