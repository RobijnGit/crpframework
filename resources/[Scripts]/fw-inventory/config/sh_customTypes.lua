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
            Label = "Sneeuwbal Ammo x3",
            Image = "ammo-snowball.png",
            Price = 45,
        }
    },
    ["business-bag"] = {
        ["pizzeria"] = {
            Label = "Pizza Doos",
            Image = "pizzeria-box.png",
            Description = "Een doos, met pizza?",
        },
        ["duffel"] = {
            Label = "Duffel Tas",
            Image = "duffel-bag.png",
            Description = "Hier past wel wat in mag ik hopen..",
        },
        ["policeduffel"] = {
            Label = "(PD) Duffel Tas",
            Image = "duffel-bag.png",
            Description = "Door de overheid (POLITIE/AMBULANCE) uitgegeven apparatuur",
            Price = 1000,
        },
        ["uwucafe"] = {
            Label = "Bento Box",
            Image = "uwu-bentobox.png",
            Description = "Zit hier een kat in?",
        },
        ["burgershot"] = {
            Label = "Burger Zak",
            Image = "burger-box.png",
            Description = "Hier zitten lekkere spulletjes in.",
        },
        ["dragonsden"] = {
            Label = "Take-away Box",
            Image = "dragonsden-box.png",
            Description = "Ik zou hem snel openen als ik jou was..",
        },
        ["petitcroissant"] = {
            Label = "Take-away Box",
            Image = "petitcroissant-box.png",
            Description = "De petit croissant, de echte bakker.",
        },
        ["cassettebox"] = {
            Label = "Cassettedoosjes",
            Image = "cassettebox.png",
            Description = "Een doos met muziek...",
            Craft = {
                { Item = "plastic", Amount = 23 } 
            }
        },
    },
    ["heist-usb"] = {
        ["green"] = {
            Label = "Groene USB",
            Image = "heist-usb-green.png",
        },
        ["blue"] = {
            Label = "Blauwe USB",
            Image = "heist-usb-blue.png",
        },
        ["red"] = {
            Label = "Rode USB",
            Image = "heist-usb-red.png",
        },
        ["yellow"] = {
            Label = "Gele USB",
            Image = "heist-usb-yellow.png",
        },
        ["black"] = {
            Label = "Zwarte USB",
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
            Label = "Traceerbare Waardevolle Goederen",
            Image = "tracked-valuable-goods.png",
            Description = "Ziet hier een GPS-tracker in?"
        },
    },
    ["fish"] = {
        ["Bass"] = {
            Label = "Baars",
            Image = "fish-bass.png",
            Description = "Een visje uit het water..",
        },
        ["Blue"] = {
            Label = "Blauwe Vis",
            Image = "fish-bluefish.png",
            Description = "Degene die deze naam bedacht, was een genie!",
        },
        ["Cod"] = {
            Label = "Kabeljauw",
            Image = "fish-cod.png",
            Description = "Lekker kabeljauwtje hoor.",
        },
        ["Flounder"] = {
            Label = "Flounder",
            Image = "fish-flounder.png",
            Description = "Ik ging vissen en het enige wat ik kreeg was deze waardeloze vis.",
        },
        ["Mackerel"] = {
            Label = "Makreel",
            Image = "fish-mackerel.png",
            Description = "Soms heilig.",
        },
        ["Shark"] = {
            Label = "Baby Haai",
            Image = "fish-shark.png",
            Description = "Een verdomde haai! Is er misschien iemand die hem wil kopen? Haha grapje. Gooi het terug. Tenzij..?",
        },
        ["Whale"] = {
            Label = "Baby Walvis",
            Image = "fish-whale.png",
            Description = "Een verdomde walvis! Is er misschien iemand die hem wil kopen? Haha grapje. Gooi het terug. Tenzij..?",
        },
    },
    ["ingredient"] = {
        ["Cream"] = {
            Label = "Slagroom",
            Image = "ingredients_icecream.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Slagroom</b>",
        },
        ["Beans"] = {
            Label = "Koffiebonen",
            Image = "ingredient-beans.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Koffiebonen</b>",
        },
        ["Beef"] = {
            Label = "Beef",
            Image = "ingredient-beef.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Vlees</b>",
        },
        ["Dairy"] = {
            Label = "Melk",
            Image = "ingredient-dairy.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Zuivel</b>",
        },
        ["Cabbage"] = {
            Label = "Kool",
            Image = "ingredients_cabbage.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["Carrot"] = {
            Label = "Wortel",
            Image = "ingredients_carrot.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["Corn"] = {
            Label = "Maïs",
            Image = "ingredients_corn.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Graan</b>",
        },
        ["Cucumber"] = {
            Label = "Komkommer",
            Image = "ingredients_cucumber.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["Garlic"] = {
            Label = "Knoflook",
            Image = "ingredients_garlic.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Kruiden</b>",
        },
        ["Onion"] = {
            Label = "Ui",
            Image = "ingredients_onion.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["Potato"] = {
            Label = "Aardappel",
            Image = "ingredient-potato.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["Pumpkin"] = {
            Label = "Pompoen",
            Image = "ingredients_pumpkin.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Suiker</b>",
        },
        ["Radish"] = {
            Label = "Radijs",
            Image = "ingredients_radish.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["RedBeet"] = {
            Label = "Rode Biet",
            Image = "ingredients_redbeet.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["Sunflower"] = {
            Label = "Zonnebloem Olie",
            Image = "ingredient-sunflower.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Olie</b>",
        },
        ["Tomato"] = {
            Label = "Tomaat",
            Image = "ingredients_tomato.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Groenten</b>",
        },
        ["Watermelon"] = {
            Label = "Watermeloen",
            Image = "ingredient-watermelon.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Suiker</b>",
        },
        ["Wheat"] = {
            Label = "Graan",
            Image = "ingredient-grain.png",
            Description = "Wordt gebruikt om voedsel te maken.<br/><br/><b>Voedsel categorie: Graan</b>",
        },
        ["Honey"] = {
            Label = "Honing",
            Image = "bee-honey.png",
            Description = "Dit ruikt lekker.. Ik krijg trek in pannekoeken!<br/><br/><b>Voedsel categorie: Suiker</b>",
        },
    },
    ["cryptostick"] = {
        ["GNE5"] = {
            Label = "GNE Stick",
            Description = "Een USB met 5 GNE erop."
        },
        ["GNE10"] = {
            Label = "GNE Stick",
            Description = "Een USB met 10 GNE erop."
        },
        ["GNE25"] = {
            Label = "GNE Stick",
            Description = "Een USB met 25 GNE erop."
        },
        ["GNE50"] = {
            Label = "GNE Stick",
            Description = "Een USB met 50 GNE erop."
        },
        ["GNE100"] = {
            Label = "GNE Stick",
            Description = "Een USB met 100 GNE erop."
        },
        ["GNE250"] = {
            Label = "GNE Stick",
            Description = "Een USB met 250 GNE erop."
        },
    },
    ["farming-seed"] = {
        ["Cabbage"] = {
            Label = "Kool Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-cabbage.png",
        },
        ["Carrot"] = {
            Label = "Wortel Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-carrot.png",
        },
        ["Corn"] = {
            Label = "Maïs Kernel",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-corn.png",
        },
        ["Cucumber"] = {
            Label = "Komkommer Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-cucumber.png",
        },
        ["Garlic"] = {
            Label = "Knoflook Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "weed-seeds.png",
        },
        ["Onion"] = {
            Label = "Ui Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-onion.png",
        },
        ["Potato"] = {
            Label = "Aardappel Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-potato.png",
        },
        ["Pumpkin"] = {
            Label = "Pompoen Zaadje",
            Description = "Wat zaadjes om te planten in een tuin, voor halloween..",
            Image = "farming-seed-pumpkin.png",
        },
        ["Radish"] = {
            Label = "Radijs Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-radish.png",
        },
        ["RedBeet"] = {
            Label = "Rode Biet Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-beetroot.png",
        },
        ["Sunflower"] = {
            Label = "Zonnebloem Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-sunflower.png",
        },
        ["Tomato"] = {
            Label = "Tomaat Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-tomato.png",
        },
        ["Watermelon"] = {
            Label = "Watermeloen Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-watermelon.png",
        },
        ["Wheat"] = {
            Label = "Graan Zaadje",
            Description = "Wat zaadjes om te planten in een tuin..",
            Image = "farming-seed-wheat.png",
        },
    },
    ['gang-chain'] = {
        ["bakker"] = {
            Label = "Ketting: Bakker",
            Description = "",
            Image = 'gangchain-bakker.png',
        },
        ["banggang"] = {
            Label = "Ketting: Bang Gang",
            Description = "Laat zien dat je een trotse member bent van de Bang Gang!",
            Image = 'gangchain-banggang.png',
        },
        ["cringeboys"] = {
            Label = "Ketting: Cringe Boys",
            Description = "Laat zien dat je een trotse member bent van Cringe Boys!",
            Image = 'gangchain-cringeboys.png',
        },
        ["esh"] = {
            Label = "Ketting: ESH",
            Description = "Laat zien dat je een trotse member bent van de East Side Hustlers!",
            Image = 'gangchain-esh.png',
        },
        -- ["kings"] = {
        --     Label = "Ketting: Kings",
        --     Description = "Laat zien dat je een trotse member bent van Kings!",
        --     Image = 'gangchain-kings.png',
        -- },
    },
    ['identification-badge'] = {
        ["flightschool"] = {
            Label = "Vliegbrevet",
            Description = "Kanjer! Je hebt geleerd hoe je moet vliegen, en met dit pasje kan je dat aan al je vrienden laten zien! (Als je die hebt)",
            Image = "badge-flightschool.png",
        },
        ["doj"] = {
            Label = "Wet & Recht Pas",
            Description = "Met deze pas kan jij bewijzen dat je een verdachte mag vertegenwoordigen.",
            Image = "badge-doj.png",
        },
        ["news"] = {
            Label = "Weazel News Pas",
            Description = "Met deze pas kan jij bewijzen dat je bij Weazel News werkt!",
            Image = "badge-news.png",
        },
        ["pd"] = {
            Label = "PD Badge",
            Description = "Alleen échte agenten hebben deze pas, om te laten zien dat ze een agent zijn.",
            Image = "badge-pd.png",
        },
        ["ems"] = {
            Label = "EMS Badge",
            Description = "Een pas om te laten zien dat je een medicus bent!",
            Image = "badge-ems.png",
        },
        ["doc"] = {
            Label = "DOC Badge",
            Description = "Een pas om te laten zien dat je in de Department of Corrections zit!",
            Image = "badge-doc.png",
        },
    },
    ["goldpan"] = {
        ["small"] = {
            Label = "Pan voor Goud",
            Description = "Een kleine pan om mee te gaan goud-vissen.",
            Image = "goldpan-small.png",
            Price = 6500,
            Craft = {
                { Item = 'plastic', Amount = 12 },
                { Item = 'metalscrap', Amount = 12 },
                { Item = 'aluminum', Amount = 12 },
            }
        },
        ["medium"] = {
            Label = "Pan voor Goud",
            Description = "Een middelmatige pan om mee te gaan goud-vissen.",
            Image = "goldpan-medium.png",
            Price = 17500,
            Craft = {
                { Item = 'plastic', Amount = 24 },
                { Item = 'metalscrap', Amount = 24 },
                { Item = 'aluminum', Amount = 24 },
            }
        },
        ["large"] = {
            Label = "Pan voor Goud",
            Description = "Een grote pan om mee te gaan goud-vissen.",
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
            Label = "Mechanisch Deel (S)",
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
            Label = "Mechanisch Deel (A)",
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
            Label = "Mechanisch Deel (B)",
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
            Label = "Mechanisch Deel (C)",
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
            Label = "Mechanisch Deel (D)",
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
            Label = "Mechanisch Deel (E)",
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
            Label = "Mechanisch Deel (M)",
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
            Label = "Koppeling (S)",
            Image = "clutch-s.png",
            Description = "Koppeling Klasse S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Koppeling (A)",
            Image = "clutch-a.png",
            Description = "Koppeling Klasse A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Koppeling (B)",
            Image = "clutch-b.png",
            Description = "Koppeling Klasse B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Koppeling (C)",
            Image = "clutch-c.png",
            Description = "Koppeling Klasse C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Koppeling (D)",
            Image = "clutch-d.png",
            Description = "Koppeling Klasse D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Koppeling (E)",
            Image = "clutch-e.png",
            Description = "Koppeling Klasse E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Koppeling (M)",
            Image = "clutch-m.png",
            Description = "Koppeling Klasse M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-axle"] = {
        ["S"] = {
            Label = "Aandrijfas (S)",
            Image = "axle-s.png",
            Description = "Aandrijfas Klasse S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Aandrijfas (A)",
            Image = "axle-a.png",
            Description = "Aandrijfas Klasse A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Aandrijfas (B)",
            Image = "axle-b.png",
            Description = "Aandrijfas Klasse B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Aandrijfas (C)",
            Image = "axle-c.png",
            Description = "Aandrijfas Klasse C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Aandrijfas (D)",
            Image = "axle-d.png",
            Description = "Aandrijfas Klasse D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Aandrijfas (E)",
            Image = "axle-e.png",
            Description = "Aandrijfas Klasse E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Aandrijfas (M)",
            Image = "axle-m.png",
            Description = "Aandrijfas Klasse M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-brakes"] = {
        ["S"] = {
            Label = "Remmen (S)",
            Image = "brakes-s.png",
            Description = "Remmen Klasse S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Remmen (A)",
            Image = "brakes-a.png",
            Description = "Remmen Klasse A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Remmen (B)",
            Image = "brakes-b.png",
            Description = "Remmen Klasse B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Remmen (C)",
            Image = "brakes-c.png",
            Description = "Remmen Klasse C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Remmen (D)",
            Image = "brakes-d.png",
            Description = "Remmen Klasse D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Remmen (E)",
            Image = "brakes-e.png",
            Description = "Remmen Klasse E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Remmen (M)",
            Image = "brakes-m.png",
            Description = "Remmen Klasse M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-engine"] = {
        ["S"] = {
            Label = "Motor (S)",
            Image = "engine-s.png",
            Description = "Motor Klasse S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Motor (A)",
            Image = "engine-a.png",
            Description = "Motor Klasse A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Motor (B)",
            Image = "engine-b.png",
            Description = "Motor Klasse B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Motor (C)",
            Image = "engine-c.png",
            Description = "Motor Klasse C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Motor (D)",
            Image = "engine-d.png",
            Description = "Motor Klasse D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Motor (E)",
            Image = "engine-e.png",
            Description = "Motor Klasse E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Motor (M)",
            Image = "engine-m.png",
            Description = "Motor Klasse M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-injectors"] = {
        ["S"] = {
            Label = "Brandstof Injectoren (S)",
            Image = "injectors-s.png",
            Description = "Brandstof Injectoren Klasse S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Brandstof Injectoren (A)",
            Image = "injectors-a.png",
            Description = "Brandstof Injectoren Klasse A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Brandstof Injectoren (B)",
            Image = "injectors-b.png",
            Description = "Brandstof Injectoren Klasse B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Brandstof Injectoren (C)",
            Image = "injectors-c.png",
            Description = "Brandstof Injectoren Klasse C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Brandstof Injectoren (D)",
            Image = "injectors-d.png",
            Description = "Brandstof Injectoren Klasse D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Brandstof Injectoren (E)",
            Image = "injectors-e.png",
            Description = "Brandstof Injectoren Klasse E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Brandstof Injectoren (M)",
            Image = "injectors-m.png",
            Description = "Brandstof Injectoren Klasse M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["vehicle-transmission"] = {
        ["S"] = {
            Label = "Transmissie (S)",
            Image = "transmission-s.png",
            Description = "Transmissie Klasse S",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "S", Amount = 3 },
            }
        },
        ["A"] = {
            Label = "Transmissie (A)",
            Image = "transmission-a.png",
            Description = "Transmissie Klasse A",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "A", Amount = 2 },
            }
        },
        ["B"] = {
            Label = "Transmissie (B)",
            Image = "transmission-b.png",
            Description = "Transmissie Klasse B",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "B", Amount = 4 },
            }
        },
        ["C"] = {
            Label = "Transmissie (C)",
            Image = "transmission-c.png",
            Description = "Transmissie Klasse C",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "C", Amount = 3 },
            }
        },
        ["D"] = {
            Label = "Transmissie (D)",
            Image = "transmission-d.png",
            Description = "Transmissie Klasse D",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "D", Amount = 2 },
            }
        },
        ["E"] = {
            Label = "Transmissie (E)",
            Image = "transmission-e.png",
            Description = "Transmissie Klasse E",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "E", Amount = 3 },
            }
        },
        ["M"] = {
            Label = "Transmissie (M)",
            Image = "transmission-m.png",
            Description = "Transmissie Klasse M",
            Craft = {
                { Item = "generic-mechanic-part", CustomType = "M", Amount = 4 },
            }
        },
    },
    ["gang-spray"] = {
        ["bakker"] = {
            Description = "Kunst.<br/><br/><b>Spray: Bakker</b>",
        },
        -- ["bearly_legal_mc"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: Bearly Legal MC</b>",
        --     Image = "spraycan-bearly_legal_mc.png",
        -- },
        ["flying_dragons"] = {
            Description = "Kunst.<br/><br/><b>Spray: Flying Dragons</b>",
            Image = "spraycan-flying_dragons.png",
        },
        ["kings"] = {
            Description = "Kunst.<br/><br/><b>Spray: Kings</b>",
            Image = "spraycan-kings.png",
        },
        ["los_aztecas"] = {
            Description = "Kunst.<br/><br/><b>Spray: Los Aztecas</b>",
            Image = "spraycan-los_aztecas.png",
        },
        ["los_muertos_mc"] = {
            Description = "Kunst.<br/><br/><b>Spray: Los Muertos MC</b>",
            Image = "spraycan-los_muertos_mc.png",
        },
        ["lost_holland"] = {
            Description = "Kunst.<br/><br/><b>Spray: The Lost Holland</b>",
            Image = "spraycan-lost_holland.png",
        },
        ["marabunta_perrera"] = {
            Description = "Kunst.<br/><br/><b>Spray: Marabunta Perrera</b>",
            Image = "spraycan-marabunta_perrera.png",
        },
        ["dark_wolves"] = {
            Description = "Kunst.<br/><br/><b>Spray: Dark Wolves MC</b>",
            Image = "spraycan-dark_wolves.png",
        },
        ["crimi_clowns"] = {
            Description = "Kunst.<br/><br/><b>Spray: Crimi Clowns</b>",
            Image = "spraycan-crimi_clowns.png",
        },
        -- ["ogs"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: Original Gangsters</b>",
        --     Image = "spraycan-ogs.png",
        -- },
        ["clutch"] = {
            Description = "Kunst.<br/><br/><b>Spray: Clutch</b>",
            Image = "spraycan-clutch.png",
        },
        ["los_lobos"] = {
            Description = "Kunst.<br/><br/><b>Spray: Los Lobos</b>",
            Image = "spraycan-los_lobos.png",
        },
        -- ["high_table"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: The High Table</b>",
        --     Image = "spraycan-high_table.png",
        -- },
        -- ["ant"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: Ain't No Telling</b>",
        --     Image = "spraycan-ant.png",
        -- },
        ["serpents"] = {
            Description = "Kunst.<br/><br/><b>Spray: The Serpents</b>",
            Image = "spraycan-serpents.png",
        },
        -- ["wanheda"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: Wanheda</b>",
        --     Image = "spraycan-wanheda.png",
        -- },
        ["death_sinners"] = {
            Description = "Kunst.<br/><br/><b>Spray: Death Sinners MC</b>",
            Image = "spraycan-death_sinners.png",
        },
        ["white_widow"] = {
            Description = "Kunst.<br/><br/><b>Spray: White Widow</b>",
            Image = "spraycan-white_widow.png",
        },
        -- ["skull_gang"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: Skull Gang</b>",
        --     Image = "spraycan-skull_gang.png",
        -- },
        ["grizzley_gang"] = {
            Description = "Kunst.<br/><br/><b>Spray: Grizzley Gang</b>",
            Image = "spraycan-grizzley_gang.png",
        },
        ["seoul_street_gang"] = {
            Description = "Kunst.<br/><br/><b>Spray: Seoul Street Gang</b>",
            Image = "spraycan-seoul_street_gang.png",
        },
        -- ["vdv"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: Van Der Veer</b>",
        --     Image = "spraycan-vdv.png",
        -- },
        ["bricksquad"] = {
            Description = "Kunst.<br/><br/><b>Spray: 1017 Bricksquad</b>",
            Image = "spraycan-bricksquad.png",
        },
        ["crips"] = {
            Description = "Kunst.<br/><br/><b>Spray: Crips</b>",
            Image = "spraycan-crips.png",
        },
        ["crocs"] = {
            Description = "Kunst.<br/><br/><b>Spray: Crocs</b>",
            Image = "spraycan-crocs.png",
        },
        ["scum"] = {
            Description = "Kunst.<br/><br/><b>Spray: Scum</b>",
            Image = "spraycan-scum.png",
        },
        ["ballas"] = {
            Description = "Kunst.<br/><br/><b>Spray: Ballas</b>",
            Image = "spraycan-ballas.png",
        },
        ["wutang"] = {
            Description = "Kunst.<br/><br/><b>Spray: Wu-Tang</b>",
            Image = "spraycan-wutang.png",
        },
        -- ["nameless"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: The Nameless</b>",
        --     Image = "spraycan-nameless.png",
        -- },
        -- ["cosanostra"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: Cosa Nostra</b>",
        --     Image = "spraycan-cosanostra.png",
        -- },
        ["cringeboys"] = {
            Description = "Kunst.<br/><br/><b>Spray: Cringe Boys</b>",
            Image = "spraycan-cringeboys.png",
        },
        ["21"] = {
            Description = "Kunst.<br/><br/><b>Spray: 21</b>",
            Image = "spraycan-21.png",
        },
        ["vatoslocos"] = {
            Description = "Kunst.<br/><br/><b>Spray: Vatos Loco's</b>",
            Image = "spraycan-vatoslocos.png",
        },
        ["bumpergang"] = {
            Description = "Kunst.<br/><br/><b>Spray: BumperGang</b>",
            Image = "spraycan-bumpergang.png",
        },
        ["getbackgang"] = {
            Description = "Kunst.<br/><br/><b>Spray: Get Back Gang</b>",
            Image = "spraycan-getbackgang.png",
        },
        ["dimeo"] = {
            Description = "Kunst.<br/><br/><b>Spray: DiMeo</b>",
            Image = "spraycan-dimeo.png",
        },
        ["blackcobras"] = {
            Description = "Kunst.<br/><br/><b>Spray: Black Cobras</b>",
            Image = "spraycan-blackcobras.png",
        },
        -- ["nls"] = {
        --     Description = "Kunst.<br/><br/><b>Spray: No Lost Soldiers</b>",
        --     Image = "spraycan-nls.png",
        -- },
        ["blacklist"] = {
            Description = "Kunst.<br/><br/><b>Spray: 626 Blacklist</b>",
            Image = "spraycan-blacklist.png",
        },
        ["sopranos"] = {
            Description = "Kunst.<br/><br/><b>Spray: Sopranos</b>",
            Image = "spraycan-sopranos.png",
        },
        ["s2n"] = {
            Description = "Kunst.<br/><br/><b>Spray: Second2None</b>",
            Image = "spraycan-s2n.png",
        },
        ["fts"] = {
            Description = "Kunst.<br/><br/><b>Spray: Fock The System</b>",
        },
        ["tffc"] = {
            Description = "Kunst.<br/><br/><b>Spray: Thieves & Crooks</b>",
            Image = "spraycan-tffc.png",
        },
    },
    ["evidence-collected"] = {
        ["Blood"] = {
            Description = "Bloed verloren?",
            Image = "evidence-red.png",
            Label = "Bewijs: Bloed",
        },
        ["Finger"] = {
            Description = "Van wie o wie is deze vingerafdruk?",
            Image = "evidence-green.png",
            Label = "Bewijs: Vingerafdruk",
        },
        ["Bullet"] = {
            Description = "Iemand lijkt hier geschoten te hebben..",
            Image = "evidence-orange.png",
            Label = "Bewijs: Kogelhuls",
        },
    },
    ["customjoint"] = {
        ["1g"] = {
            Description = "Een joint met 1 gram wiet. 1-time use.",
            Label = "1g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 1 },
                { Item = "weed-bag-1g", Amount = 1 },
            }
        },
        ["spacecake"] = {
            Description = "Spacecakje, legends zeggen dat dit het toetje is van Neil Armstrong.",
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
            Description = "Lekkere jointje, 1-time use.",
            Label = "(Binnestebuiten) 1g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 1 },
                { Item = "weed-bag-1g", Amount = 1 },
            }
        },
        ["cone"] = {
            Image = "joint-cone.png",
            Description = "Lekkere jointje, 2-time use.",
            Label = "(Cone) 2g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 3 },
                { Item = "weed-bag-1g", Amount = 3 },
            }
        },
        ["splitter"] = {
            Image = "joint-splitter.png",
            Description = "Lekkere jointje, 2-time use.",
            Label = "(Splitter) 2g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 3 },
                { Item = "weed-bag-1g", Amount = 3 },
            }
        },
        ["cross"] = {
            Image = "joint-cross.png",
            Description = "Lekkere jointje, 3-time use.",
            Label = "(Cross) 3g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 4 },
                { Item = "weed-bag-1g", Amount = 3 },
            }
        },
        ["tulp"] = {
            Image = "joint-tulp.png",
            Description = "Lekkere jointje, 4-time use.",
            Label = "(Tulp) 4g Joint",
            Craft = {
                { Item = 'rolling-paper', Amount = 5 },
                { Item = "weed-bag-1g", Amount = 4 },
            }
        },
        ["windmill"] = {
            Image = "joint-windmill.png",
            Description = "Lekkere jointje, 5-time use.",
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