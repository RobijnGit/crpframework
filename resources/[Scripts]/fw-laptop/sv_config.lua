Config = Config or {}

-- Manual option for a max member size.
-- Always do MINUS ONE on the max, the leader doesn't count as a member.
-- Edit: this is ignored now as max gang size rule is lifted.
Config.GangSizes = {
    -- ['devgang'] = 12,
}

Config.Gangs = {}