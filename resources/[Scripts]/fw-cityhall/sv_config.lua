Config = Config or {}

Config.LicensesLocales = {
    ['driver'] = 'Drivers License',
    ['hunting'] = 'Hunting License',
    ['weapon'] = 'Weapons License',
    ['fishing'] = 'Fishing License',
    ['flying'] = 'Flight Certificate',
    ['business'] = 'Business License',
}

Config.LicenseTemplate = '<p><strong>Issued to</strong></p><figure class="table"><table><tbody><tr><th>Name</th><td>%s</td></tr><tr><th>State ID</th><td>%s</td></tr><tr><th>Sex</th><td>%s</td></tr></tbody></table></figure><p><strong>Issued by</strong></p><figure class="table"><table><tbody><tr><th>Name</th><td>%s</td></tr><tr><th>Date</th><td>%s</td></tr></tbody></table></figure><p>&nbsp;</p>'
exports("GetLicenseTemplate", function()
    return Config.LicenseTemplate
end)

Config.ConfiscateMessage = "Dear %s, we regret to inform you that your property has been seized due to outstanding debts. If the Los Santos Court is not contacted soon, the State may sell the seized property to cover the outstanding debts. Sincerely, The State of San Andreas"