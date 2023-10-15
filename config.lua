Config = {}

Config.CookLocations = {
    {
        vector3(813.24, -752.98, 27.78),    --Where the temp management is
        vector3(812.08, -754.94, 26.78),    --Where to start the cooking
        "cook"
    },      --Pizza Making Area
    {
        vector3(807.62, -760.23, 27.78),    --Where the temp management is
        vector3(810.0, -761.16, 26.78),    --Where to start the cooking
        "cook"
    },      --Pizza Restaurant Pasta Making Area
    {
        vector3(806.2, -763.63, 27.78),    --Where the temp management is
        vector3(810.0, -761.16, 26.78),    --Where to start the cooking
        "cook"
    },      --Pizza Restaurant Dessert Making Area
    {
        vector3(806.2, -762.93, 27.78),    --Where the temp management is
        vector3(810.0, -761.16, 26.78),    --Where to start the cooking
        "cook"
    },      --Pizza Restaurant Baked Item Making Area (Chicken Parmigiana)
    {
        vector3(-1199.99, -900.48, 15.0),    --Where the temp management is
        vector3(-1199.13, -901.61, 14.0),    --Where to start the cooking
        "cook"
    },      --Burger Shot
    {
        vector3(-1202.37, -896.89, 15.0),    --Where the temp management is
        vector3(-1199.13, -901.61, 14.0),    --Where to start the cooking
        "cook"
    },      --Burger Shot
    {
        vector3(-1201.19, -898.72, 15.0),    --Where the temp management is
        vector3(-1199.13, -901.61, 14.0),    --Where to start the cooking
        "cook"
    },      --Burger Shot
    {
        vector3(-590.47, -1056.54, 23.36),    --Where the temp management is
        vector3(-590.48, -1063.01, 22.36),    --Where to start the cooking
        "cook"
    },      --UwU Cafe
    {
        vector3(-590.36, -1059.75, 23.34),    --Where the temp management is
        vector3(-590.48, -1063.01, 22.36),    --Where to start the cooking
        "cook"
    },      --UwU Cafe
    {
        vector3(129.98, -1282.09, 29.27),    --Where the temp management is
        vector3(129.98, -1282.09, 29.27),    --Where to start the cooking
        "drinkmix"
    },      --VU drink making
}

Config.LocationJob = {
    "pizza",
    "pizza",
    "pizza",
    "pizza",
    "burgershot",
    "burgershot",
    "burgershot",
    "uwu",
    "uwu",
    "entertainer"
}

Config.LocationFoods = {
    {
        ["pepperonipizza"] = {
            {                           --Ingredients
                {{"pepperoni"}, 15, "Pepperoni"},
                {{"tomatosauce"}, 2, "Tomato Sauce"},
                {{"dough"}, 1, "Dough"},
                {{"cheese"}, 4, "Cheese"}
            },
            15,                         --Cook time in secods per
            {350, 425},                 --Temp Range
            "Pepperoni Pizza"           --Display name of the food
        },
        ["cheesepizza"] = {
            {                           --Ingredients
                {{"tomatosauce"}, 2, "Tomato Sauce"},
                {{"dough"}, 1, "Dough"},
                {{"cheese"}, 6, "Cheese"}
            },
            15,                         --Cook time in secods per
            {350, 425},                 --Temp Range
            "Cheese Pizza"              --Display name of the food
        },
        ["meatpizza"] = {
            {                           --Ingredients
                {{"pepperoni"}, 15, "Pepperoni"},
                {{"sausage"}, 6, "Sausage"},    
                {{"dicedchicken"}, 6, "Diced Chicken"},
                {{"tomatosauce"}, 2, "Tomato Sauce"},
                {{"dough"}, 1, "Dough"},
                {{"cheese"}, 4, "Cheese"}
            },
            15,                         --Cook time in secods per
            {350, 425},                 --Temp Range
            "Meat Pizza"                --Display name of the food
        },
    },
    {
        ["seafoodpasta"] = {
            {                           --Ingredients
                {{"seafoodingredient"}, 4, "Prepared Sea Food"},
                {{"pasta"}, 4, "Pasta"},
                {{"tomatosauce"}, 1, "Tomato Sauce"}
            },
            15,                         --Cook time in secods per
            {300, 350},                 --Temp Range
            "Seafood Pasta"             --Display name of the food
        },
    },
    {
        ["tiramisu"] = {
            {                           --Ingredients
                {{"egg"}, 3, "Egg"},
                {{"flour"}, 1, "Flour"},
                {{"sugar"}, 1, "Sugar"},
                {{"cocoapowder"}, 1, "Cocoa Powder"},
                {{"heavycream"}, 1, "Heavy Cream"},
                {{"coffee"}, 1, "Coffe"}
            },
            30,                         --Cook time in secods per
            {400, 430},                 --Temp Range
            "Tiramisu"              --Display name of the food
        },
    },
    {
        ["chickenparmigiana"] = {
            {                           --Ingredients
                {{"chickenbreast"}, 2, "Chicken Breast"},
                {{"pasta"}, 2, "Pasta"},
                {{"tomatosauce"}, 1, "Tomato Sauce"},
                {{"cheese"}, 2, "Cheese"}
            },
            30,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Chicken Parmigiana"              --Display name of the food
        },
        ["chickensalad"] = {
            {                           --Ingredients
                {{"chickenbreast"}, 2, "Chicken Breast"},
                {{"tomato"}, 2, "Tomato"},
                {{"carrot"}, 2, "Carrot"},
                {{"saladmix"}, 2, "Salad Mix"},
            },
            25,                         --Cook time in secods per
            {100, 145},                 --Temp Range
            "Chicken Salad"              --Display name of the food
        },
    },
    {
        ["heartstopper"] = {
            {                           --Ingredients
                {{"deermeat"}, 2, "Deer Meat"},
                {{"chickenbreast"}, 1, "Chicken Breast"},
                {{"sausage"}, 1, "Sausage"},
                {{"boarmeat"}, 1, "Boar Meat"},
                {{"coyotemeat"}, 1, "Coyote Meat"},
                {{"mtlionmeat"}, 1, "Mt. Lion Meat"},
                {{"cheese"}, 5, "Cheese"},
                {{"buns"}, 1, "Buns"},
                {{"tomato"}, 1, "Tomato"},
            },
            30,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Heart Stopper"              --Display name of the food
        },
        ["torpedo"] = {
            {                           --Ingredients
                {{"boarmeat"}, 1, "Boar Meat"},
                {{"sausage"}, 1, "Sausage"},
                {{"deermeat"}, 1, "Deer Meat"},
                {{"buns"}, 1, "Buns"},
            },
            22,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Torpedo"              --Display name of the food
        },
        ["hamburger"] = {
            {                           --Ingredients
                {{"deermeat"}, 2, "Deer Meat"},
                {{"buns"}, 1, "Buns"},
                {{"tomato"}, 1, "Tomato"},
            },
            22,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Hamburger"              --Display name of the food
        },
    },
    {
        ["bleeder"] = {
            {                           --Ingredients
                {{"deermeat"}, 2, "Deer Meat"},
                {{"boarmeat"}, 1, "Boar Meat"},
                {{"coyotemeat"}, 1, "Coyote Meat"},
                {{"cheese"}, 2, "Cheese"},
                {{"buns"}, 1, "Buns"},
                {{"tomato"}, 1, "Tomato"},
            },
            27,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Bleeder"              --Display name of the food
        },
        ["cheeseburger"] = {
            {                           --Ingredients
                {{"deermeat"}, 2, "Deer Meat"},
                {{"cheese"}, 1, "Cheese"},
                {{"buns"}, 1, "Buns"},
                {{"tomato"}, 1, "Tomato"},
            },
            22,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Cheese Burger"              --Display name of the food
        },
        ["veggieburger"] = {
            {                           --Ingredients
                {{"veggiepatty"}, 2, "Veggie Patty"},
                {{"buns"}, 1, "Buns"},
                {{"tomato"}, 1, "Tomato"},
            },
            22,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Veggie Burger"              --Display name of the food
        },
    },
    {
        ["fries"] = {
            {                           --Ingredients
                {{"potato"}, 1, "Potato"},
                {{"salt"}, 1, "Salt"},
            },
            22,                         --Cook time in secods per
            {400, 500},                 --Temp Range
            "Fries"              --Display name of the food
        },
    },
    {
        ["bentobox"] = {
            {                           --Ingredients
                {{"seafoodingredient"}, 2, "Prepared Sea Food"},
                {{"tomato"}, 1, "Tomato"},
                {{"egg"}, 1, "Egg"},
                {{"mushroom"}, 1, "Mushroom"},
                {{"carrot"}, 1, "Carrot"},
                {{"broccoli"}, 1, "Broccoli"},
                {{"rice"}, 1, "Rice"},
            },
            25,                         --Cook time in secods per
            {100, 145},                 --Temp Range
            "Bento Box"              --Display name of the food
        },
        ["sussyramen"] = {
            {                           --Ingredients
                {{"fish", "fish1", "fish2"}, 4, "Raw Fish"},
                {{"egg"}, 1, "Egg"},
                {{"flour"}, 1, "Flour"},
                {{"mushroom"}, 1, "Mushroom"},
                {{"waterjug"}, 1, "Water"},
            },
            27,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Sussy Ramen"              --Display name of the food
        },
        ["bakadonut"] = {
            {                           --Ingredients
                {{"sugar"}, 1, "Sugar"},
                {{"flour"}, 2, "Flour"},
                {{"waterjug"}, 1, "Water"},
            },
            17,                         --Cook time in secods per
            {400, 450},                 --Temp Range
            "Baka Donut"              --Display name of the food
        },
    },
    {
        ["onichococake"] = {
            {                           --Ingredients
                {{"sugar"}, 1, "Sugar"},
                {{"flour"}, 2, "Flour"},
                {{"cocoapowder"}, 1, "Cocoa Powder"},
                {{"waterjug"}, 1, "Water"},
            },
            37,                         --Cook time in secods per
            {400, 435},                 --Temp Range
            "Oni Choco Cake"              --Display name of the food
        },
    },
    {
        ["orangeparadise"] = {
            {                           --Ingredients
                {{"sugar"}, 2, "Sugar"},
                {{"vodka"}, 1, "Vodka"},
                {{"orange"}, 4, "Orange"},
            },
            7.5,                         --Cook time in secods per
            "Orange Paradise"
        },
        ["strawberrydaiquiri"] = {
            {                           --Ingredients
                {{"sugar"}, 2, "Sugar"},
                {{"strawberry"}, 4, "strawberry"},
                {{"rum"}, 1, "Rum"},
            },
            7.5,                         --Cook time in secods per
            "Strawberry Daiquiri"
        },
    }
}

Config.Drinks = {
    ["uwu"] = {
        "hicxd", "herbalboba", "chocolateboba", "chitea", "ahegaocoffee", "coffee"
    },
    ["pizza"] = {
        "rigatoniwine", "italiancreamsoda"
    },
    ["burgershot"] = {
        "burgershotcoke", "burgershotsprite"
    },
}