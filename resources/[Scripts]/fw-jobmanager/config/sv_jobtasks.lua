Config.JobTasks = {
    ["fishing"] = {
        Activity = {
            Title = "Vissen",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Ga naar het ontmoetingspunt.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar de vis plaats.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Verzamel vis.",
                Progress = 0,
                RequiredProgress = 30,
            },
            {
                Title = 'Ga terug naar het ontmoetingspunt en vertel dat de plek goed is.',
                Progress = 0,
                RequiredProgress = 1,
            },
        },
    },
    ["chopshop"] = {
        Activity = {
            Title = "Voertuigen Scrappen",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Ga naar de plek waar het voertuig voor het laatst is gezien.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Zoek en steel het voertuig.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar de scrapyard.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Scrap de waardevolle delen.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Verlaat het gebied.",
                Progress = 0,
                RequiredProgress = 1,
            },
        }
    },
    ["sanitation"] = {
        Activity = {
            Title = "Los Santos Vuilsnis",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Ga naar de werkgever.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Stap in de vuilniswagen.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar de toegewezen zone (%s).",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Verzamel afval.",
                Progress = 0,
                RequiredProgress = 15,
            },
            {
                Title = "Ga naar de volgende zone (%s).",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Verzamel afval.",
                Progress = 0,
                RequiredProgress = 15,
            },
            {
                Title = "Breng het voertuig terug.",
                Progress = 0,
                RequiredProgress = 1,
            },
        }
    },
    ["impound"] = {
        Activity = {
            Title = "Los Santos Depot",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Ga in je flatbed.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar het voertuig toe.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Sleep het voertuig op je sleepwagen.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Zet het voertuig af bij het depot.",
                Progress = 0,
                RequiredProgress = 1,
            },
        }
    },
    ["houses"] = {
        Activity = {
            Title = "Huisoverval",
            Timer = (60 * 1000) * 30,
        },
        Tasks = {
            {
                Title = 'De baas heeft je gevraagd om naar het pand te gaan.',
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Maak die deur open.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Laad de goederen en ga daar weg.",
                Progress = 0,
                RequiredProgress = 1,
            },
        }
    },
    ["postop"] = {
        Activity = {
            Title = "Post Op Medewerker",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Ga naar de werkgever.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Stap in het voertuig.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar de toegewezen winkel.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Goederen afgeven.",
                Progress = 0,
                RequiredProgress = 3,
            },
            {
                Title = "Breng het voertuig terug.",
                Progress = 0,
                RequiredProgress = 1,
            },
        }
    },
    ["oxy"] = {
        Activity = {
            Title = "\"Kranten\" Verkoper",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Zoek en steel een voertuig om als transportmiddel te gebruiken.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar de leverancier en vraag om de goederen.",
                Progress = 0,
                RequiredProgress = 10,
            },
            {
                Title = "Rijd met het transportvoertuig naar de locatie toe.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Wacht op de klanten en geef de goederen af.",
                Progress = 0,
                RequiredProgress = 5,
            },
            {
                Title = "Rijd naar de volgende locatie toe.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Wacht op de klanten en geef de goederen af.",
                Progress = 0,
                RequiredProgress = 5,
            },
        }
    },
    ["fooddelivery"] = {
        Activity = {
            Title = "Voedsel Bezorgen",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Ga naar het toegewezen restaurant.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Verzamel de bestelling.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar de aflever locatie toe.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Lever de bestelling in.",
                Progress = 0,
                RequiredProgress = 1,
            },
        }
    },
    ["construction"] = {
        Activity = {
            Title = "Bouwvakker",
            Timer = (60 * 1000) * 50,
        },
        Tasks = {
            {
                Title = "Ga naar de werkgever.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Stap in het voertuig.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Ga naar de bouwplaats.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Voltooi alle bouwtaken.",
                Progress = 0,
                RequiredProgress = 1,
            },
            {
                Title = "Breng het voertuig terug.",
                Progress = 0,
                RequiredProgress = 1,
            },
        }
    }
}
