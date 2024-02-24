Config = Config or {}

Config.LicensesLocales = {
    ['driver'] = 'Rijbewijs',
    ['hunting'] = 'Jaag Vergunning',
    ['weapon'] = 'Wapen Vergunning',
    ['fishing'] = 'Vis Vergunning',
    ['flying'] = 'Vliegbrevet',
    ['business'] = 'Bedrijfs Vergunning',
}

Config.LicenseTemplate = '<p><strong>Uitgegeven aan</strong></p><figure class="table"><table><tbody><tr><th>Naam</th><td>%s</td></tr><tr><th>BSN nummer</th><td>%s</td></tr><tr><th>Geslacht</th><td>%s</td></tr></tbody></table></figure><p><strong>Uitgegeven door</strong></p><figure class="table"><table><tbody><tr><th>Naam</th><td>%s</td></tr><tr><th>Datum</th><td>%s</td></tr></tbody></table></figure><p>&nbsp;</p>'
exports("GetLicenseTemplate", function()
    return Config.LicenseTemplate
end)

Config.ConfiscateMessage = "Beste %s, we betreuren het u te moeten informeren dat uw eigendom in beslag is genomen door de staat vanwege openstaande schulden. Het spijt ons te moeten zeggen dat als er binnen een bepaalde termijn geen contact wordt opgenomen met het gerechtshof van Los Santos, de staat het ingenomen eigendom mag verkopen om de openstaande schulden te dekken. Neem dus alstublieft zo snel mogelijk contact op met het gerechtshof van Los Santos om verdere stappen te bespreken. Met vriendelijke groet, de Staat van Los Santos."