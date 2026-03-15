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
<h2>Transaction overview for home purchase in the county of Los Santos</h2>
<p>&nbsp;</p>
<p>Seller Name: The State of Los Santos</p>
<p>Buyer Name: %s</p>
<p>Sold Adress: %s</p>
<p>Description of real estate: %s</p>
<p>Value of real estate at the time of sale: %s</p>
<p>&nbsp;</p>
<h4>Disclosure &amp; Warranty:</h4>
<p>&nbsp;</p>
<p>The seller declares that the property is in GOOD REPAIR and that it is structurally sound and complies with all legal regulations.</p>
<p>&nbsp;</p>
<p>The buyer agrees to the following:</p>
<p>* Buy the house as is and will not make any claim against the seller for any defects/problems that arise after purchase.</p>
<p>&nbsp;</p>
<p>* Payments on the real estate being sold are due according to the invoice in the form of property tax.</p>
<p>&nbsp;</p>
<p>* The State WILL NOT file a request for foreclosure until either of the following</p>
<p>&nbsp; &nbsp; * Two weeks have passed since the last payment,</p>
<p>&nbsp; &nbsp; * It is confirmed that the buyer no longer resides in the state of Los Santos, or</p>
<p>&nbsp; &nbsp; * Granted by a judge for foreclosure</p>
<p>&nbsp;</p>
<p>* The real estate is an asset and therefore falls under the assets of a specific lending company and the state to take the real estate as collateral.</p>
<p>&nbsp;</p>
<p>The full title and responsibility for all applicable state and local taxes, as well as HOA fees, are solely the responsibility of the buyer.</p>
<p>&nbsp;</p>
<p>State ID: %s</p>
<p>Signature of Buyer: %s</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>Date: %s</p>
]]
Config.ContractText = "<h2>Transaction overview for home purchase in the county of Los Santos</h2><p>&nbsp;</p><p>Seller Name: The State of Los Santos</p><p>Buyer Name: %s</p><p>Sold Adress: %s</p><p>Description of real estate: %s</p><p>Value of real estate at the time of sale: %s</p><p>&nbsp;</p><h4>Disclosure &amp; Warranty:</h4><p>&nbsp;</p><p>The seller declares that the property is in GOOD REPAIR and that it is structurally sound and complies with all legal regulations.</p><p>&nbsp;</p><p>The buyer agrees to the following:</p><p>* Buy the house as is and will not make any claim against the seller for any defects/problems that arise after purchase.</p><p>&nbsp;</p><p>* Payments on the real estate being sold are due according to the invoice in the form of property tax.</p><p>&nbsp;</p><p>* The State WILL NOT file a request for foreclosure until either of the following</p><p>&nbsp; &nbsp; * Two weeks have passed since the last payment,</p><p>&nbsp; &nbsp; * It is confirmed that the buyer no longer resides in the state of Los Santos, or</p><p>&nbsp; &nbsp; * Granted by a judge for foreclosure</p><p>&nbsp;</p><p>* The real estate is an asset and therefore falls under the assets of a specific lending company and the state to take the real estate as collateral.</p><p>&nbsp;</p><p>The full title and responsibility for all applicable state and local taxes, as well as HOA fees, are solely the responsibility of the buyer.</p><p>&nbsp;</p><p>State ID: %s</p><p>Signature of Buyer: %s</p><p>&nbsp;</p><p>&nbsp;</p><p>Date: %s</p>"