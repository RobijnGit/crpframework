Config = Config or {}

--[[
    housing = "fas fa-house-user"
    warehouse = "fas fa-warehouse"
    store = "fas fa-store-alt"
    office = "fas fa-building"
]]

Config.TierCategory = {
    [1]  = "housing",
    [2]  = "housing",
    [3]  = "housing",
    [4]  = "housing",
    [5]  = "housing",
    [6]  = "housing",
    [7]  = "housing",
    [8]  = "housing",
    [9]  = "housing",
    [10] = "housing",
    [11] = "warehouse",
    [12] = "warehouse",
    [13] = "warehouse",
    [14] = "store",
    [15] = "office",
    [16] = "warehouse",
    [17] = "store",
}


-- Must be 'minified' cuz documents editor requires it to load text..
--[[
<h2>Transactieoverzicht voor woningaankoop voor het graafschap Los Santos</h2>
<p>&nbsp;</p>
<p>Verkoper Naam: De Staat van Los Santos</p>
<p>Koper Naam: %s</p>
<p>Verkocht adres: %s</p>
<p>Beschrijving van onroerend goed: %s</p>
<p>Waarde van onroerend goed op het moment van verkoop: %s</p>
<p>&nbsp;</p>
<h4>Openbaarmaking &amp; Garantie:</h4>
<p>&nbsp;</p>
<p>De verkoper verklaart dat het huis in GOEDE REPARATIE verkeert en dat het structureel gezond is en voldoet aan alle wettelijke voorschriften.</p>
<p>&nbsp;</p>
<p>Koper stemt in met het volgende:</p>
<p>* Koop het huis zoals het is en zal geen aanspraak maken op de verkoper voor eventuele gebreken/problemen die zich voordoen na aankoop.</p>
<p>&nbsp;</p>
<p>* Betalingen op het onroerend goed dat wordt verkocht, zijn verschuldigd volgens de factuur in de vorm van onroerendgoedbelasting.</p>
<p>&nbsp;</p>
<p>* De staat ZAL GEEN aanvraag tot afscherming indienen tot een van beide</p>
<p>&nbsp; &nbsp; * Twee weken zijn verstreken sinds de laatste betaling,</p>
<p>&nbsp; &nbsp; * Bevestigd wordt dat de koper niet langer in de staat van Los Santos woont, of</p>
<p>&nbsp; &nbsp; * Toegekend door een rechter voor afscherming</p>
<p>&nbsp;</p>
<p>* Het onroerend goed is een bezit en valt daarom onder het vermogen van een bepaalde leningmaatschappij en de staat om het onroerend goed als onderpand te nemen.</p>
<p>&nbsp;</p>
<p>De volledige titel en verantwoordelijkheid voor alle van toepassing zijnde staats- en lokale belastingen, evenals VvE-kosten, zijn uitsluitend de verantwoordelijkheid van de koper.</p>
<p>&nbsp;</p>
<p>BSN: %s</p>
<p>Handtekening van Koper: %s</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>Datum: %s</p>
]]
Config.ContractText = "<h2>Transactieoverzicht voor woningaankoop voor het graafschap Los Santos</h2><p>&nbsp;</p><p>Verkoper Naam: De Staat van Los Santos</p><p>Koper Naam: %s</p><p>Verkocht adres: %s</p><p>Beschrijving van onroerend goed: %s</p><p>Waarde van onroerend goed op het moment van verkoop: %s</p><p>&nbsp;</p><h4>Openbaarmaking &amp; Garantie:</h4><p>&nbsp;</p><p>De verkoper verklaart dat het huis in GOEDE REPARATIE verkeert en dat het structureel gezond is en voldoet aan alle wettelijke voorschriften.</p><p>&nbsp;</p><p>Koper stemt in met het volgende:</p><p>* Koop het huis zoals het is en zal geen aanspraak maken op de verkoper voor eventuele gebreken/problemen die zich voordoen na aankoop.</p><p>&nbsp;</p><p>* Betalingen op het onroerend goed dat wordt verkocht, zijn verschuldigd volgens de factuur in de vorm van onroerendgoedbelasting.</p><p>&nbsp;</p><p>* De staat ZAL GEEN aanvraag tot afscherming indienen tot een van beide</p><p>&nbsp; &nbsp; * Twee weken zijn verstreken sinds de laatste betaling,</p><p>&nbsp; &nbsp; * Bevestigd wordt dat de koper niet langer in de staat van Los Santos woont, of</p><p>&nbsp; &nbsp; * Toegekend door een rechter voor afscherming</p><p>&nbsp;</p><p>* Het onroerend goed is een bezit en valt daarom onder het vermogen van een bepaalde leningmaatschappij en de staat om het onroerend goed als onderpand te nemen.</p><p>&nbsp;</p><p>De volledige titel en verantwoordelijkheid voor alle van toepassing zijnde staats- en lokale belastingen, evenals VvE-kosten, zijn uitsluitend de verantwoordelijkheid van de koper.</p><p>&nbsp;</p><p>BSN: %s</p><p>Handtekening van Koper: %s</p><p>&nbsp;</p><p>&nbsp;</p><p>Datum: %s</p>"