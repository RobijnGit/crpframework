Shared = Shared or {}
Shared.CustomTypes = {
    ["ammo"] = {
        ["Pistol"] = {
            Label = "Pistol Ammo x50",
            Image = "ammo-pistol.png",
            Price = 25,
            Craft = {
                { Item = "aluminum", Amount = 3 },
                { Item = "plastic", Amount = 3 },
                { Item = "rubber", Amount = 3 },
            },
        },
        ["Rifle"] = {
            Label = "Rifle Ammo x50",
            Image = "ammo-rifle.png",
            Price = 35,
            Craft = {
                { Item = "aluminum", Amount = 3 },
                { Item = "plastic", Amount = 3 },
                { Item = "rubber", Amount = 3 },
            },
        },
        ["Smg"] = {
            Label = "Sub Ammo x50",
            Image = "ammo-smg.png",
            Price = 35,
            Craft = {
                { Item = "aluminum", Amount = 6 },
                { Item = "plastic", Amount = 3 },
                { Item = "rubber", Amount = 3 },
            },
        },
        ["Shotgun"] = {
            Label = "SG Ammo x12",
            Image = "ammo-shotgun.png",
            Price = 35,
            Craft = {
                { Item = "steel", Amount = 9 },
                { Item = "plastic", Amount = 3 },
            },
        },
        ["Rubber"] = {
            Label = "Rubber Slugs x20",
            Image = "ammo-rubber.png",
            Price = 35,
            Craft = {},
        },
        ["Taser"] = {
            Label = "Taser Cartridges",
            Image = "ammo-taser.png",
            Price = 15,
        },
        ["Paintball"] = {
            Label = "Paintballs",
            Image = "ammo-paintball.png",
            Price = 35,
        },
        ["Sniper"] = {
            Label = "Sniper Ammo x12",
            Image = "ammo-sniper.png",
            Price = 35,
        },
        ["Emp"] = {
            Label = "EMP Ammo x3",
            Image = "ammo-emp.png",
            Price = 45,
        },
        ["Revolver"] = {
            Label = "Revolver Ammo x12",
            Image = "ammo-revolver.png",
            Price = 45,
        },
        ["Snowball"] = {
            Label = "Snowball Ammo x3",
            Image = "ammo-snowball.png",
            Price = 45,
        }
    },
    ["business-bag"] = {
        ["pizzeria"] = {
            Label = "Pizza Box",
            Image = "pizzeria-box.png",
            Description = "A box with pizza?",
        },
        ["duffel"] = {
            Label = "Duffel Bag",
            Image = "duffel-bag.png",
            Description = "I hope there's room for a few things in here..",
        },
        ["policeduffel"] = {
            Label = "(PD) Duffel Bag",
            Image = "duffel-bag.png",
            Description = "Equipment issued by the government (POLICE/EMS)",
            Price = 1000,
        },
        ["uwucafe"] = {
            Label = "Bento Box",
            Image = "uwu-bentobox.png",
            Description = "Is there a cat in here?",
        },
        ["burgershot"] = {
            Label = "Burger Bag",
            Image = "burger-box.png",
            Description = "Some tasty goodies are in here.",
        },
        ["dragonsden"] = {
            Label = "Take-away Box",
            Image = "dragonsden-box.png",
            Description = "I'd open it quickly if I were you..",
        },
        ["petitcroissant"] = {
            Label = "Take-away Box",
            Image = "petitcroissant-box.png",
            Description = "The petit croissant, the real baker.",
        },
        ["cassettebox"] = {
            Label = "Cassette Boxes",
            Image = "cassettebox.png",
            Description = "A box full of music...",
            Craft = {
                { Item = "plastic", Amount = 23 } 
            }
        },
    },
    ["heist-usb"] = {
        ["green"] = {
            Label = "Green USB",
            Image = "heist-usb-green.png",
        },
        ["blue"] = {
            Label = "Blue USB",
            Image = "heist-usb-blue.png",
        },
        ["red"] = {
            Label = "Red USB",
            Image = "heist-usb-red.png",
        },
        ["yellow"] = {
            Label = "Yellow USB",
            Image = "heist-usb-yellow.png",
        },
        ["black"] = {
            Label = "Black USB",
            Image = "heist-usb-black.png",
        },
    },
    ["heist-laptop"] = {
        ["green"] = {
            Image = "heist-laptop-green.png",
        },
        ["blue"] = {
            Image = "heist-laptop-blue.png",
        },
        ["red"] = {
            Image = "heist-laptop-red.png",
        },
        ["yellow"] = {
            Image = "heist-laptop-yellow.png",
        },
    },
    ["heist-loot"] = {
        ["tracked"] = {
            Label = "Trackable Valuable Goods",
            Image = "tracked-valuable-goods.png",
            Description = "Do you see a GPS tracker in here?"
        },
    },
    ["fish"] = {
        ["Bass"] = {
            Label = "Bass",
            Image = "fish-bass.png",
            Description = "A little fish from the water..",
        },
        ["Blue"] = {
            Label = "Blue Fish",
            Image = "fish-bluefish.png",
            Description = "Whoever came up with this name was a genius!",
        },
        ["Cod"] = {
            Label = "Cod",
            Image = "fish-cod.png",
            Description = "Nice cod, huh.",
        },
        ["Flounder"] = {
            Label = "Flounder",
            Image = "fish-flounder.png",
            Description = "I went fishing, and the only thing I got was this worthless fish.",
        },
        ["Mackerel"] = {
            Label = "Mackerel",
            Image = "fish-mackerel.png",
            Description = "Sometimes holy.",
        },
        ["Shark"] = {
            Label = "Baby Shark",
            Image = "fish-shark.png",
            Description = "A damn shark! Is there someone who wants to buy it? Haha, just kidding. Throw it back. Unless...?",
        },
        ["Whale"] = {
            Label = "Baby Whale",
            Image = "fish-whale.png",
            Description = "A damn whale! Is there someone who wants to buy it? Haha, just kidding. Throw it back. Unless...?",
        },
    },
    ["ingredient"] = {
        ["Cream"] = {
            Label = "Cream",
            Image = "ingredients_icecream.png",
            Description = "Used to make food.<br/><br/><b>Food category: Cream</b>",
        },
        ["Beans"] = {
            Label = "Coffee Beans",
            Image = "ingredient-beans.png",
            Description = "Used to make food.<br/><br/><b>Food category: Coffee Beans</b>",
        },
        ["Beef"] = {
            Label = "Beef",
            Image = "ingredient-beef.png",
            Description = "Used to make food.<br/><br/><b>Food category: Meat</b>",
        },
        ["Dairy"] = {
            Label = "Milk",
            Image = "ingredient-dairy.png",
            Description = "Used to make food.<br/><br/><b>Food category: Dairy</b>",
        },
        ["Cabbage"] = {
            Label = "Cabbage",
            Image = "ingredients_cabbage.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["Carrot"] = {
            Label = "Carrot",
            Image = "ingredients_carrot.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["Corn"] = {
            Label = "Corn",
            Image = "ingredients_corn.png",
            Description = "Used to make food.<br/><br/><b>Food category: Grain</b>",
        },
        ["Cucumber"] = {
            Label = "Cucumber",
            Image = "ingredients_cucumber.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["Garlic"] = {
            Label = "Garlic",
            Image = "ingredients_garlic.png",
            Description = "Used to make food.<br/><br/><b>Food category: Herbs</b>",
        },
        ["Onion"] = {
            Label = "Onion",
            Image = "ingredients_onion.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["Potato"] = {
            Label = "Potato",
            Image = "ingredient-potato.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["Pumpkin"] = {
            Label = "Pumpkin",
            Image = "ingredients_pumpkin.png",
            Description = "Used to make food.<br/><br/><b>Food category: Sugar</b>",
        },
        ["Radish"] = {
            Label = "Radish",
            Image = "ingredients_radish.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["RedBeet"] = {
            Label = "Red Beet",
            Image = "ingredients_redbeet.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["Sunflower"] = {
            Label = "Sunflower Oil",
            Image = "ingredient-sunflower.png",
            Description = "Used to make food.<br/><br/><b>Food category: Oil</b>",
        },
        ["Tomato"] = {
            Label = "Tomato",
            Image = "ingredients_tomato.png",
            Description = "Used to make food.<br/><br/><b>Food category: Vegetables</b>",
        },
        ["Watermelon"] = {
            Label = "Watermelon",
            Image = "ingredient-watermelon.png",
            Description = "Used to make food.<br/><br/><b>Food category: Sugar</b>",
        },
        ["Wheat"] = {
            Label = "Grain",
            Image = "ingredient-grain.png",
            Description = "Used to make food.<br/><br/><b>Food category: Grain</b>",
        },
        ["Honey"] = {
            Label = "Honey",
            Image = "bee-honey.png",
            Description = "Smells delicious.. I'm craving pancakes!<br/><br/><b>Food category: Sugar</b>",
        },
    },
    ["cryptostick"] = {
        ["GNE5"] = {
            Label = "GNE Stick",
            Description = "A USB with 5 GNE on it."
        },
        ["GNE10"] = {
            Label = "GNE Stick",
            Description = "A USB with 10 GNE on it."
        },
        ["GNE25"] = {
            Label = "GNE Stick",
            Description = "A USB with 25 GNE on it."
        },
        ["GNE50"] = {
            Label = "GNE Stick",
            Description = "A USB with 50 GNE on it."
        },
        ["GNE100"] = {
            Label = "GNE Stick",
            Description = "A USB with 100 GNE on it."
        },
        ["GNE250"] = {
            Label = "GNE Stick",
            Description = "A USB with 250 GNE on it."
        },
    },
    ["farming-seed"] = {
        ["Cabbage"] = {
            Label = "Cabbage Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-cabbage.png",
        },
        ["Carrot"] = {
            Label = "Carrot Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-carrot.png",
        },
        ["Corn"] = {
            Label = "Corn Kernel",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-corn.png",
        },
        ["Cucumber"] = {
            Label = "Cucumber Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-cucumber.png",
        },
        ["Garlic"] = {
            Label = "Garlic Seed",
            Description = "Seeds to plant in a garden..",
            Image = "weed-seeds.png",
        },
        ["Onion"] = {
            Label = "Onion Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-onion.png",
        },
        ["Potato"] = {
            Label = "Potato Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-potato.png",
        },
        ["Pumpkin"] = {
            Label = "Pumpkin Seed",
            Description = "Seeds to plant in a garden, for Halloween..",
            Image = "farming-seed-pumpkin.png",
        },
        ["Radish"] = {
            Label = "Radish Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-radish.png",
        },
        ["RedBeet"] = {
            Label = "Red Beet Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-beetroot.png",
        },
        ["Sunflower"] = {
            Label = "Sunflower Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-sunflower.png",
        },
        ["Tomato"] = {
            Label = "Tomato Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-tomato.png",
        },
        ["Watermelon"] = {
            Label = "Watermelon Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-watermelon.png",
        },
        ["Wheat"] = {
            Label = "Grain Seed",
            Description = "Seeds to plant in a garden..",
            Image = "farming-seed-wheat.png",
        },
    },
    ['gang-chain'] = {
        ["bakker"] = {
            Label = "Chain: Baker",
            Description = "",
            Image = 'gangchain-bakker.png',
        },
        ["banggang"] = {
            Label = "Chain: Bang Gang",
            Description = "Show that you're a proud member of the Bang Gang!",
            Image = 'gangchain-banggang.png',
        },
        ["cringeboys"] = {
            Label = "Chain: Cringe Boys",
            Description = "Show that you're a proud member of Cringe Boys!",
            Image = 'gangchain-cringeboys.png',
        },
        ["esh"] = {
            Label = "Chain: ESH",
            Description = "Show that you're a proud member of the East Side Hustlers!",
            Image = 'gangchain-esh.png',
        },
        -- ["kings"] = {
        --     Label = "Chain: Kings",
        --     Description = "Show that you're a proud member of Kings!",
        --     Image = 'gangchain-kings.png',
        -- },
    },
    ['identification-badge'] = {
        ["flightschool"] = {
            Label = "Flight License",
            Description = "Champion! You've learned how to fly, and with this pass you can show it to all your friends! (If you have any)",
            Image = "badge-flightschool.png",
        },
        ["doj"] = {
            Label = "Law & Order Pass",
            Description = "With this pass, you can prove that you may represent a suspect.",
            Image = "badge-doj.png",
        },
        ["news"] = {
            Label = "Weazel News Pass",
            Description = "With this pass, you can prove you work at Weazel News!",
            Image = "badge-news.png",
        },
        ["pd"] = {
            Label = "PD Badge",
            Description = "Only real agents have this pass, to show that they are an agent.",
            Image = "badge-pd.png",
        },
        ["ems"] = {
            Label = "EMS Badge",
            Description = "A pass to show you're a medic!",
            Image = "badge-ems.png",
        },
        ["doc"] = {
            Label = "DOC Badge",
            Description = "A pass to show you're part of the Department of Corrections!",
            Image = "badge-doc.png",
        },
    },
    ["goldpan"] = {
        ["small"] = {
            Label = "Gold Pan",
            Description = "A small pan to go gold panning with.",
            Image = "goldpan-small.png",
            Price = 6500,
            Craft = {
                { Item = 'plastic', Amount = 12 },
                { Item = 'metalscrap', Amount = 12 },
                { Item = 'aluminum', Amount = 12 },
            }
        },
        ["medium"] = {
            Label = "Gold Pan",
            Description = "A medium pan to go gold panning with.",
            Image = "goldpan-medium.png",
            Price = 17500,
            Craft = {
                { Item = 'plastic', Amount = 24 },
                { Item = 'metalscrap', Amount = 24 },
                { Item = 'aluminum', Amount = 24 },
            }
        },
        ["large"] = {
            Label = "Gold Pan",
            Description = "A large pan to go gold panning with.",
            Image = "goldpan-large.png",
            Price = 28500,
            Craft = {
                { Item = 'plastic', Amount = 3 },
                { Item = 'metalscrap', Amount = 3 },
                { Item = 'aluminum', Amount = 3 },
            }
        },
    },
    ["generic-mechanic-part"] = {
        ["S"] = {
            Image = "generic-mechanic-part-s.png",
            Label = "Mechanical Part (S)",
            Craft = {
                { Item = 'aluminum', Amount = 18 },
                { Item = 'copper', Amount = 18 },
                { Item = 'plastic', Amount = 18 },
                { Item = 'rubber', Amount = 18 },
                { Item = 'steel', Amount = 18 },
                { Item = 'metalscrap', Amount = 18 },
                { Item = 'electronics', Amount = 18 },
            }
        },
        ["A"] = {
            Image = "generic-mechanic-part-a.png",
            Label = "Mechanical Part (A)",
            Craft = {
                { Item = 'aluminum', Amount = 9 },
                { Item = 'copper', Amount = 9 },
                { Item = 'plastic', Amount = 9 },
                { Item = 'rubber', Amount = 9 },
                { Item = 'steel', Amount = 9 },
                { Item = 'metalscrap', Amount = 9 },
                { Item = 'electronics', Amount = 9 },
            }
        },
        ["B"] = {
            Image = "generic-mechanic-part-b.png",
            Label = "Mechanical Part (B)",
            Craft = {
                { Item = 'aluminum', Amount = 3 },
                { Item = 'copper', Amount = 3 },
                { Item = 'plastic', Amount = 3 },
                { Item = 'rubber', Amount = 3 },
                { Item = 'steel', Amount = 3 },
                { Item = 'metalscrap', Amount = 3 },
                { Item = 'electronics', Amount = 3 },
            }
        },
        ["C"] = {
            Image = "generic-mechanic-part-c.png",
            Label = "Mechanical Part (C)",
            Craft = {
                { Item = 'aluminum', Amount = 3 },
                { Item = 'copper', Amount = 3 },
                { Item = 'plastic', Amount = 3 },
                { Item = 'rubber', Amount = 3 },
                { Item = 'steel', Amount = 3 },
                { Item = 'metalscrap', Amount = 3 },
                { Item = 'electronics', Amount = 3 },
            }
        },
        ["D"] = {
            Image = "generic-mechanic-part-d.png",
            Label = "Mechanical Part (D)",
            Craft = {
                { Item = 'aluminum', Amount = 3 },
                { Item = 'copper', Amount = 3 },
                { Item = 'plastic', Amount = 3 },
                { Item = 'rubber', Amount = 3 },
                { Item = 'steel', Amount = 3 },
                { Item = 'metalscrap', Amount = 3 },
                { Item = 'electronics', Amount = 3 },
            }
        },
        ["E"] = {
            Image = "generic-mechanic-part-e.png",
            Label = "Mechanical Part (E)",
            Craft = {
                { Item = 'aluminum', Amount = 3 },
                { Item = 'copper', Amount = 3 },
                { Item = 'plastic', Amount = 3 },
                { Item = 'rubber', Amount = 3 },
                { Item = 'steel', Amount = 3 },
                { Item = 'metalscrap', Amount = 3 },
                { Item = 'electronics', Amount = 3 },
            }
        },
        ["M"] = {
            Image = "generic-mechanic-part-m.png",
            Label = "Mechanical Part (M)",
            Craft = {
                { Item = 'aluminum', Amount = 3 },
                { Item = 'copper', Amount = 3 },
                { Item = 'plastic', Amount = 3 },
                { Item = 'rubber', Amount = 3 },
                { Item = 'steel', Amount = 3 },
                { Item = 'metalscrap', Amount = 3 },
                { Item = 'electronics', Amount = 3 },
            }
        },
    },
    ["vehicle-clutch"] = {
        ["S"] = {
            Label = "Clutch (S)",
            Image = "clutch-s.png",
            Description = "Clutch Class S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Clutch (A)",
            Image = "clutch-a.png",
            Description = "Clutch Class A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Clutch (B)",
            Image = "clutch-b.png",
            Description = "Clutch Class B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Clutch (C)",
            Image = "clutch-c.png",
            Description = "Clutch Class C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Clutch (D)",
            Image = "clutch-d.png",
            Description = "Clutch Class D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Clutch (E)",
            Image = "clutch-e.png",
            Description = "Clutch Class E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Clutch (M)",
            Image = "clutch-m.png",
            Description = "Clutch Class M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-axle"] = {
        ["S"] = {
            Label = "Axle Shaft (S)",
            Image = "axle-s.png",
            Description = "Axle Shaft Class S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Axle Shaft (A)",
            Image = "axle-a.png",
            Description = "Axle Shaft Class A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Axle Shaft (B)",
            Image = "axle-b.png",
            Description = "Axle Shaft Class B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Axle Shaft (C)",
            Image = "axle-c.png",
            Description = "Axle Shaft Class C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Axle Shaft (D)",
            Image = "axle-d.png",
            Description = "Axle Shaft Class D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Axle Shaft (E)",
            Image = "axle-e.png",
            Description = "Axle Shaft Class E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Axle Shaft (M)",
            Image = "axle-m.png",
            Description = "Axle Shaft Class M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-brakes"] = {
        ["S"] = {
            Label = "Brakes (S)",
            Image = "brakes-s.png",
            Description = "Brakes Class S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Brakes (A)",
            Image = "brakes-a.png",
            Description = "Brakes Class A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Brakes (B)",
            Image = "brakes-b.png",
            Description = "Brakes Class B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Brakes (C)",
            Image = "brakes-c.png",
            Description = "Brakes Class C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Brakes (D)",
            Image = "brakes-d.png",
            Description = "Brakes Class D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Brakes (E)",
            Image = "brakes-e.png",
            Description = "Brakes Class E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Brakes (M)",
            Image = "brakes-m.png",
            Description = "Brakes Class M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-engine"] = {
        ["S"] = {
            Label = "Engine (S)",
            Image = "engine-s.png",
            Description = "Engine Class S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Engine (A)",
            Image = "engine-a.png",
            Description = "Engine Class A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Engine (B)",
            Image = "engine-b.png",
            Description = "Engine Class B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Engine (C)",
            Image = "engine-c.png",
            Description = "Engine Class C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Engine (D)",
            Image = "engine-d.png",
            Description = "Engine Class D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Engine (E)",
            Image = "engine-e.png",
            Description = "Engine Class E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Engine (M)",
            Image = "engine-m.png",
            Description = "Engine Class M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-injectors"] = {
        ["S"] = {
            Label = "Fuel Injectors (S)",
            Image = "injectors-s.png",
            Description = "Fuel Injectors Class S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Fuel Injectors (A)",
            Image = "injectors-a.png",
            Description = "Fuel Injectors Class A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Fuel Injectors (B)",
            Image = "injectors-b.png",
            Description = "Fuel Injectors Class B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Fuel Injectors (C)",
            Image = "injectors-c.png",
            Description = "Fuel Injectors Class C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Fuel Injectors (D)",
            Image = "injectors-d.png",
            Description = "Fuel Injectors Class D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Fuel Injectors (E)",
            Image = "injectors-e.png",
            Description = "Fuel Injectors Class E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Fuel Injectors (M)",
            Image = "injectors-m.png",
            Description = "Fuel Injectors Class M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-transmission"] = {
        ["S"] = {
            Label = "Transmission (S)",
            Image = "transmission-s.png",
            Description = "Transmission Class S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Transmission (A)",
            Image = "transmission-a.png",
            Description = "Transmission Class A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Transmission (B)",
            Image = "transmission-b.png",
            Description = "Transmission Class B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Transmission (C)",
            Image = "transmission-c.png",
            Description = "Transmission Class C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Transmission (D)",
            Image = "transmission-d.png",
            Description = "Transmission Class D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Transmission (E)",
            Image = "transmission-e.png",
            Description = "Transmission Class E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Transmission (M)",
            Image = "transmission-m.png",
            Description = "Transmission Class M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["gang-spray"] = {
        ["bakker"] = {
            Description = "Art.<br/><br/><b>Spray: Baker</b>",
        },
        -- ["bearly_legal_mc"] = {
        --     Description = "Art.<br/><br/><b>Spray: Bearly Legal MC</b>",
        --     Image = "spraycan-bearly_legal_mc.png",
        -- },
        ["flying_dragons"] = {
            Description = "Art.<br/><br/><b>Spray: Flying Dragons</b>",
            Image = "spraycan-flying_dragons.png",
        },
        ["kings"] = {
            Description = "Art.<br/><br/><b>Spray: Kings</b>",
            Image = "spraycan-kings.png",
        },
        ["los_aztecas"] = {
            Description = "Art.<br/><br/><b>Spray: Los Aztecas</b>",
            Image = "spraycan-los_aztecas.png",
        },
        ["los_muertos_mc"] = {
            Description = "Art.<br/><br/><b>Spray: Los Muertos MC</b>",
            Image = "spraycan-los_muertos_mc.png",
        },
        ["lost_holland"] = {
            Description = "Art.<br/><br/><b>Spray: The Lost Holland</b>",
            Image = "spraycan-lost_holland.png",
        },
        ["marabunta_perrera"] = {
            Description = "Art.<br/><br/><b>Spray: Marabunta Perrera</b>",
            Image = "spraycan-marabunta_perrera.png",
        },
        ["dark_wolves"] = {
            Description = "Art.<br/><br/><b>Spray: Dark Wolves MC</b>",
            Image = "spraycan-dark_wolves.png",
        },
        ["crimi_clowns"] = {
            Description = "Art.<br/><br/><b>Spray: Crimi Clowns</b>",
            Image = "spraycan-crimi_clowns.png",
        },
        -- ["ogs"] = {
        --     Description = "Art.<br/><br/><b>Spray: Original Gangsters</b>",
        --     Image = "spraycan-ogs.png",
        -- },
        ["clutch"] = {
            Description = "Art.<br/><br/><b>Spray: Clutch</b>",
            Image = "spraycan-clutch.png",
        },
        ["los_lobos"] = {
            Description = "Art.<br/><br/><b>Spray: Los Lobos</b>",
            Image = "spraycan-los_lobos.png",
        },
        -- ["high_table"] = {
        --     Description = "Art.<br/><br/><b>Spray: The High Table</b>",
        --     Image = "spraycan-high_table.png",
        -- },
        -- ["ant"] = {
        --     Description = "Art.<br/><br/><b>Spray: Ain't No Telling</b>",
        --     Image = "spraycan-ant.png",
        -- },
        ["serpents"] = {
            Description = "Art.<br/><br/><b>Spray: The Serpents</b>",
            Image = "spraycan-serpents.png",
        },
        -- ["wanheda"] = {
        --     Description = "Art.<br/><br/><b>Spray: Wanheda</b>",
        --     Image = "spraycan-wanheda.png",
        -- },
        ["death_sinners"] = {
            Description = "Art.<br/><br/><b>Spray: Death Sinners MC</b>",
            Image = "spraycan-death_sinners.png",
        },
        ["white_widow"] = {
            Description = "Art.<br/><br/><b>Spray: White Widow</b>",
            Image = "spraycan-white_widow.png",
        },
        -- ["skull_gang"] = {
        --     Description = "Art.<br/><br/><b>Spray: Skull Gang</b>",
        --     Image = "spraycan-skull_gang.png",
        -- },
        ["grizzley_gang"] = {
            Description = "Art.<br/><br/><b>Spray: Grizzley Gang</b>",
            Image = "spraycan-grizzley_gang.png",
        },
        ["seoul_street_gang"] = {
            Description = "Art.<br/><br/><b>Spray: Seoul Street Gang</b>",
            Image = "spraycan-seoul_street_gang.png",
        },
        -- ["vdv"] = {
        --     Description = "Art.<br/><br/><b>Spray: Van Der Veer</b>",
        --     Image = "spraycan-vdv.png",
        -- },
        ["bricksquad"] = {
            Description = "Art.<br/><br/><b>Spray: 1017 Bricksquad</b>",
            Image = "spraycan-bricksquad.png",
        },
        ["crips"] = {
            Description = "Art.<br/><br/><b>Spray: Crips</b>",
            Image = "spraycan-crips.png",
        },
        ["crocs"] = {
            Description = "Art.<br/><br/><b>Spray: Crocs</b>",
            Image = "spraycan-crocs.png",
        },
        ["scum"] = {
            Description = "Art.<br/><br/><b>Spray: Scum</b>",
            Image = "spraycan-scum.png",
        },
        ["ballas"] = {
            Description = "Art.<br/><br/><b>Spray: Ballas</b>",
            Image = "spraycan-ballas.png",
        },
        ["wutang"] = {
            Description = "Art.<br/><br/><b>Spray: Wu-Tang</b>",
            Image = "spraycan-wutang.png",
        },
        -- ["nameless"] = {
        --     Description = "Art.<br/><br/><b>Spray: The Nameless</b>",
        --     Image = "spraycan-nameless.png",
        -- },
        -- ["cosanostra"] = {
        --     Description = "Art.<br/><br/><b>Spray: Cosa Nostra</b>",
        --     Image = "spraycan-cosanostra.png",
        -- },
        ["cringeboys"] = {
            Description = "Art.<br/><br/><b>Spray: Cringe Boys</b>",
            Image = "spraycan-cringeboys.png",
        },
        ["21"] = {
            Description = "Art.<br/><br/><b>Spray: 21</b>",
            Image = "spraycan-21.png",
        },
        ["vatoslocos"] = {
            Description = "Art.<br/><br/><b>Spray: Vatos Loco's</b>",
            Image = "spraycan-vatoslocos.png",
        },
        ["bumpergang"] = {
            Description = "Art.<br/><br/><b>Spray: BumperGang</b>",
            Image = "spraycan-bumpergang.png",
        },
        ["getbackgang"] = {
            Description = "Art.<br/><br/><b>Spray: Get Back Gang</b>",
            Image = "spraycan-getbackgang.png",
        },
        ["dimeo"] = {
            Description = "Art.<br/><br/><b>Spray: DiMeo</b>",
            Image = "spraycan-dimeo.png",
        },
        ["blackcobras"] = {
            Description = "Art.<br/><br/><b>Spray: Black Cobras</b>",
            Image = "spraycan-blackcobras.png",
        },
        -- ["nls"] = {
        --     Description = "Art.<br/><br/><b>Spray: No Lost Soldiers</b>",
        --     Image = "spraycan-nls.png",
        -- },
        ["blacklist"] = {
            Description = "Art.<br/><br/><b>Spray: 626 Blacklist</b>",
            Image = "spraycan-blacklist.png",
        },
        ["sopranos"] = {
            Description = "Art.<br/><br/><b>Spray: Sopranos</b>",
            Image = "spraycan-sopranos.png",
        },
        ["s2n"] = {
            Description = "Art.<br/><br/><b>Spray: Second2None</b>",
            Image = "spraycan-s2n.png",
        },
        ["fts"] = {
            Description = "Art.<br/><br/><b>Spray: Fock The System</b>",
        },
        ["tffc"] = {
            Description = "Art.<br/><br/><b>Spray: Thieves & Crooks</b>",
            Image = "spraycan-tffc.png",
        },
    },
    ["evidence-collected"] = {
        ["Blood"] = {
            Description = "Blood lost?",
            Image = "evidence-red.png",
            Label = "Evidence: Blood",
        },
        ["Finger"] = {
            Description = "Whose, oh whose, is this fingerprint?",
            Image = "evidence-green.png",
            Label = "Evidence: Fingerprint",
        },
        ["Bullet"] = {
            Description = "Someone seems to have been shot here..",
            Image = "evidence-orange.png",
            Label = "Evidence: Bullet Casing",
        },
    },
    ["customjoint"] = {
        ["1g"] = {
            Description = "A joint with 1 gram of weed. 1-time use.",
            Label = "1g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 1 },
                { Item = "weed-bag-1g", Amount = 1 },
            }
        },
        ["spacecake"] = {
            Description = "Spacecake, legends say this is Neil Armstrong's dessert.",
            Image = "spacecake.png",
            Label = "Spacecake",
            Craft = {
                { Item = "ingredient", CustomType = "Dairy", Amount = 1 },
                { Item = "ingredient", CustomType = "Wheat", Amount = 1 },
                { Item = "ingredient", CustomType = "Watermelon", Amount = 1 },
                { Item = "weed-bag-1g", Amount = 1 },
            }
        },
        ["hashbrownies"] = {
            Description = "If you're not lazy enough, you don't have to take a puff, eat some food - change your mood.",
            Image = "hashbrownies.png",
            Label = "Hash Brownies",
            Craft = {
                { Item = "ingredient", CustomType = "Dairy", Amount = 1 },
                { Item = "ingredient", CustomType = "Wheat", Amount = 1 },
                { Item = "ingredient", CustomType = "Watermelon", Amount = 1 },
                { Item = "weed-bag-1g", Amount = 1 },
            },
        },
        ["insideout"] = {
            Image = "joint-insideout.png",
            Description = "Tasty little joint, 1-time use.",
            Label = "(Inside Out) 1g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 1 },
                { Item = "weed-bag-1g", Amount = 1 },
            }
        },
        ["cone"] = {
            Image = "joint-cone.png",
            Description = "Tasty little joint, 2-time use.",
            Label = "(Cone) 2g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 3 },
                { Item = "weed-bag-1g", Amount = 3 },
            }
        },
        ["splitter"] = {
            Image = "joint-splitter.png",
            Description = "Tasty little joint, 2-time use.",
            Label = "(Splitter) 2g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 3 },
                { Item = "weed-bag-1g", Amount = 3 },
            }
        },
        ["cross"] = {
            Image = "joint-cross.png",
            Description = "Tasty little joint, 3-time use.",
            Label = "(Cross) 3g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 4 },
                { Item = "weed-bag-1g", Amount = 3 },
            }
        },
        ["tulp"] = {
            Image = "joint-tulp.png",
            Description = "Tasty little joint, 4-time use.",
            Label = "(Tulip) 4g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 5 },
                { Item = "weed-bag-1g", Amount = 4 },
            }
        },
        ["windmill"] = {
            Image = "joint-windmill.png",
            Description = "Tasty little joint, 5-time use.",
            Label = "(Windmill) 5g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 6 },
                { Item = "weed-bag-1g", Amount = 5 },
            }
        },
    },

    ["antique-vase"] = {
        ["vase-1"] = {
            Image = "antique-vase-1.png",
        },
        ["vase-2"] = {
            Image = "antique-vase-2.png",
        },
        ["vase-3"] = {
            Image = "antique-vase-3.png",
        },
        ["vase-4"] = {
            Image = "antique-vase-4.png",
        },
        ["vase-5"] = {
            Image = "antique-vase-5.png",
        },
        ["vase-6"] = {
            Image = "antique-vase-6.png",
        },
    },
    ["painting"] = {
        ["painting-1"] = {
            Image = "painting-1.png",
        },
        ["painting-2"] = {
            Image = "painting-2.png",
        },
        ["painting-3"] = {
            Image = "painting-3.png",
        },
        ["painting-4"] = {
            Image = "painting-4.png",
        },
        ["painting-5"] = {
            Image = "painting-5.png",
        },
        ["painting-6"] = {
            Image = "painting-6.png",
        },
        ["painting-7"] = {
            Image = "painting-7.png",
        },
        ["painting-8"] = {
            Image = "painting-8.png",
        },
        ["painting-9"] = {
            Image = "painting-9.png",
        },
    },
}