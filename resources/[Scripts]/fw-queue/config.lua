Config = Config or {}

Config.MaxPlayers = 0
Config.PriorityList = {}

Config.Emotes = {'🙈','🐠','🐬','🦀','🍆','🍑','🌈','🌪','🦜','👀','🐬','🐢','🍎'}

Config.Card = {
    type = "AdaptiveCard",
    minHeight = "75px",
    version = "1.3",
    body = { 
        {
            type = "TextBlock",
            text = "Clarity Roleplay",
            fontType = "Default",
            weight = "Bolder",
            size = "ExtraLarge",
            color = "Light",
            horizontalAlignment = "Center"
        }, 
        {
            type = "TextBlock",
            text = "",
            fontType = "Default",
            weight = "Bolder",
            color = "Light",
            horizontalAlignment = "Center"
        } 
    }
}