const MaxTime = (((1000 * 60) * 60) * 24) * 28;

const GetItemData = (ItemName, CustomType, ItemInfo) => {
    var ItemData = {...ItemsList[ItemName]};
    if (CustomType) {
        const CustomItemType = CustomTypes[ItemName] && CustomTypes[ItemName][CustomType] || {}
        if (CustomItemType.Label) ItemData.Label = CustomItemType.Label;
        if (CustomItemType.Image) ItemData.Image = CustomItemType.Image;
        if (CustomItemType.Description) ItemData.Description = CustomItemType.Description;
        if (CustomItemType.IsExternImage) ItemData.IsExternImage = CustomItemType.IsExternImage;
        if (CustomItemType.Price) ItemData.Price = CustomItemType.Price;
        if (CustomItemType.Craft) ItemData.Craft = CustomItemType.Craft;
    }

    if (ItemInfo) {
        if (ItemInfo._Label) ItemData.Label = ItemInfo._Label;
        if (ItemInfo._Description) ItemData.Description = ItemInfo._Description;
        if (ItemInfo._Image) {
            ItemData.Image = ItemInfo._Image
            ItemData.IsExternImage = true;
        };
    }

    return ItemData;
};

const GetItemImage = (ItemName, CustomType, ItemInfo) => {
    const ItemData = GetItemData(ItemName, CustomType, ItemInfo);
    if (ItemData.IsExternImage) return ItemData.Image;
    return `./img/items/${ItemData.Image}`;
};

const CalculateQuality = (ItemName, CreateDate) => {
    var StartDate = new Date(CreateDate).getTime();
    var DecayRate = ItemsList[ItemName].DecayRate;
    var TimeExtra = MaxTime * DecayRate;
    var Quality = 100 - Math.ceil(((Date.now() - StartDate) / TimeExtra) * 100);

    if (DecayRate == 0) Quality = 100;
    if (Quality <= 0) Quality = 0;
    if (Quality >= 99.0) Quality = 100; // because lua uses seconds, and not milliseconds its never 100%, so we'll just pretend it is.

    var QualityClass = 'inventory-slot-quality';
    if (Quality <= 0) QualityClass = 'inventory-slot-quality broken';

    return {
        Percentage: Quality,
        Class: QualityClass,
    };
};

const InventoryLog = (Text) => {
    $('.inventory-wrapper > .logs').prepend(`${Text}<br/>`);
};

const FindSlot = (Items, Slots, SlotData) => {
    for (let i = 1; i <= Slots; i++) {
        const Item = Items[i];
        if (!Item || (Item && Item.Item == SlotData.Item && Item.CustomType == SlotData.CustomType && !ItemsList[SlotData.Item].NonStack)) {
            return i
        };
    };
    return false
}

const CalculateTotalInvWeight = (Items) => {
    let Retval = 0.0;

    Items = Object.values(Items);
    for (let i = 0; i < Items.length; i++) {
        const Item = Items[i]; 
        if (Item) Retval = Retval + (Item.Amount * ItemsList[Item.Item].Weight);
    }

    return Retval;
};

const UpdateInventoryWeights = (InvContainer) => {
    const Inventory = $(`.inventory-box[inventory-name="${InvContainer}"]`);
    if (InvContainer == 'player') {
        const Weight = CalculateTotalInvWeight(MyInventory);
        Inventory.find('.inventory-box-header > .inventory-box-header-weightbar > .weightbar-fill').stop(true, true).animate({ width: `${(Weight * 100) / 250.0}%` }, 250);
        Inventory.find('.inventory-box-header > .inventory-box-header-weight > span').html(Math.ceil(Weight))
    } else {
        const Weight = CalculateTotalInvWeight(OtherInvData.Items);
        Inventory.find('.inventory-box-header > .inventory-box-header-weightbar > .weightbar-fill').stop(true, true).animate({ width: `${(Weight * 100) / OtherInvData.Weight}%` }, 250);
        Inventory.find('.inventory-box-header > .inventory-box-header-weight > span').html(Math.ceil(Weight))
    };
};

const BuildInventory = (InvContainer, InvType, Items, MaxSlots) => {
    const Inventory = $(`.inventory-box[inventory-name="${InvContainer}"]`);
    var _sNewInvType = InvType
    switch(InvType){
        case 'Player':
            _sNewInvType = 'Speler';
            break;
        case 'Store':
            _sNewInvType = 'Winkel';
            break;
        case 'Drop':
            _sNewInvType = 'Grond';
            break;
        
    }
    Inventory.find('.inventory-box-header').find('.inventory-box-header-name').html(_sNewInvType);
    UpdateInventoryWeights(InvContainer);

    if (InvContainer != 'player' && OtherInvData.Type == 'Store') {
        // console.log("[INVENTORY]: Add Cash to spent.")
        Inventory.find('.inventory-box-header > .inventory-box-header-weight').hide();
        Inventory.find('.inventory-box-header > .inventory-box-header-weightbar').hide();
        $.post("https://fw-inventory/FetchMoney", JSON.stringify({}), function(Cash){
            PlayerCash = Cash;
            Inventory.find('.inventory-box-cash > span').text(Cash.toLocaleString('nl-NL', { style: 'currency', currency: 'EUR' })).parent().show();
        });
    } else {
        Inventory.find('.inventory-box-header > .inventory-box-header-weight').show();
        Inventory.find('.inventory-box-header > .inventory-box-header-weightbar').show();
        Inventory.find('.inventory-box-cash').hide();
    };

    if (InvContainer != 'player' && OtherInvData.Type == 'Crafting') {
        Inventory.find('.inventory-box-header > .inventory-box-header-weight').hide();
        Inventory.find('.inventory-box-header > .inventory-box-header-weightbar').hide();
        Inventory.find('.inventory-box-slots').addClass('inventory-craft-slots');
    } else if ($('#secondary-inventory > .inventory-box-slots').hasClass('inventory-craft-slots')) {
        Inventory.find('.inventory-box-slots').removeClass('inventory-craft-slots');
    }

    Inventory.find('.inventory-box-slots').empty();

    for (let i = 1; i <= MaxSlots; i++) {
        var Item = Items[i];
        var HTMLString = ``;
        if (InvContainer == 'player' && i <= 5 ) HTMLString += `<div class="inventory-slot-bind">${i}</div>`;

        if (Item) {
            const ItemData = GetItemData(Item.Item, Item.CustomType);

            if (InvContainer != 'player' && OtherInvData.Type == 'Store') {
                HTMLString += `
                    <div class="inventory-slot-name">${ItemData.Label}</div>
                    <div class="inventory-slot-image" style="background-image: url(${GetItemImage(Item.Item, Item.CustomType, Item.Info)})"></div>
                    <div class="inventory-slot-price">€${ItemData.Price}</div>
                    <div style="margin-bottom: 2.2vh" class="inventory-slot-info">
                        <span class="inventory-slot-quantity">${Item.Amount}x</span>
                        <span class="inventory-slot-weight">${(ItemData.Weight * Item.Amount).toFixed(2)}</span>
                    </div>
                `;
            } else if (InvContainer != 'player' && OtherInvData.Type == 'Crafting') {
                let RequirementsHtml = ``;
                for (let j = 0; j < ItemData.Craft.length; j++) {
                    const Craftable = ItemData.Craft[j];
                    const CraftableItem = GetItemData(Craftable.Item, Craftable.CustomType)

                    RequirementsHtml += `<div class="inventory-craft-slot-requirements">
                        <img src="./img/items/${CraftableItem.Image}" class="inventory-craft-requirement"></img>
                        <span>${CraftableItem.Label}: </span>
                        <span>${Craftable.Amount}</span>
                    </div>`;
                };

                Inventory.find(`.inventory-box-slots`).append(`<div class="inventory-craft-slot">
                    <div data-slot="${i}" class="inventory-box-slot inventory-craft-slot-item">
                        <div class="inventory-slot-name">${ItemData.Label}</div>
                        <div class="inventory-slot-image" style="background-image: url(${GetItemImage(Item.Item, Item.CustomType, Item.Info)})"></div>
                        <div class="inventory-slot-info">
                            <span class="inventory-slot-quantity">${Item.Amount}x</span>
                            <span class="inventory-slot-weight">${(ItemData.Weight * Item.Amount).toFixed(2)}</span>
                        </div>
                    </div>
                    <div class="inventory-craft-requirements">${RequirementsHtml}</div>
                </div>`);
            } else {
                const QualityData = CalculateQuality(Item.Item, Item.CreateDate);
                HTMLString += `
                    <div class="${QualityData.Class}" style="width: ${QualityData.Percentage}%; background-position: 0% ${100 - QualityData.Percentage}%"></div>
                    <div class="inventory-slot-name">${ItemData.Label}</div>
                    <div class="inventory-slot-image" style="background-image: url(${GetItemImage(Item.Item, Item.CustomType, Item.Info)})"></div>
                    <div class="inventory-slot-info">
                        <span class="inventory-slot-quantity">${Item.Amount}x</span>
                        <span class="inventory-slot-weight">${(ItemData.Weight * Item.Amount).toFixed(2)}</span>
                    </div>
                `;
            };
        };

        if (InvContainer == 'player' || (InvContainer != 'player' && OtherInvData.Type != 'Crafting')) {
            Inventory.find(`.inventory-box-slots`).append(`<div data-slot="${i}" class="inventory-box-slot">${HTMLString}</div>`);
        };
    };
};

const ClearInventorySlot = (Inventory, Slot) => {
    const SlotElement = Inventory.find(`.inventory-box-slot[data-slot="${Slot}"]`);

    if (Inventory.attr("inventory-name") == "player" && Slot <= 5) {
        SlotElement.html(`<div class="inventory-slot-bind">${Slot}</div>`)
    } else {
        SlotElement.empty();
    }
};

const UpdateInventorySlot = (FromInv, ToInv, FromSlotId, ToSlotId, FromItem, ToItem, Amount, Type) => {
    const FromSlot = FromInv.find(`.inventory-box-slot[data-slot="${FromSlotId}"]`);
    const FromHtml = FromSlot.html();

    const ToSlot = ToInv.find(`.inventory-box-slot[data-slot="${ToSlotId}"]`);
    const ToHtml = ToSlot.html();

    const ItemData = GetItemData(FromItem.Item, FromItem.CustomType)

    if (Type == "Swap") {
        FromSlot.html(ToHtml);
        ToSlot.html(FromHtml);

        FromSlot.find('.inventory-slot-bind').remove();
        if (ToInv == 'player' && FromSlotId <= 5) FromSlot.prepend(`<div class="inventory-slot-bind">${FromSlotId}</div>`);

        ToSlot.find('.inventory-slot-bind').remove();
        if (ToInv == 'player' && ToSlotId <= 5) ToSlot.prepend(`<div class="inventory-slot-bind">${ToSlotId}</div>`);

        if (FromInv.attr("inventory-name") == "player") {
            MyInventory[FromSlotId] = ToItem
        } else {
            OtherInvData.Items[FromSlotId] = ToItem
        };

        if (ToInv.attr("inventory-name") == "player") {
            MyInventory[ToSlotId] = FromItem
        } else {
            OtherInvData.Items[ToSlotId] = FromItem
        };
    } else {
        if (Amount == FromItem.Amount) {
            if (FromInv.attr("inventory-name") == "player" || (OtherInvData.Type != 'Store' && OtherInvData.Type != 'Crafting')) {
                ClearInventorySlot(FromInv, FromSlotId)
            }

            if (FromInv.attr("inventory-name") == "player") {
                MyInventory[FromSlotId] = null
            } else {
                OtherInvData.Items[FromSlotId] = null
            };
    
            if (ToItem) {
                let NewTotal = 0;
                if (ToInv.attr("inventory-name") == "player") {
                    MyInventory[ToSlotId].Amount = MyInventory[ToSlotId].Amount + FromItem.Amount
                    NewTotal = MyInventory[ToSlotId].Amount;
                } else {
                    OtherInvData.Items[ToSlotId].Amount = OtherInvData.Items[ToSlotId].Amount + FromItem.Amount
                    NewTotal = OtherInvData.Items[ToSlotId].Amount;
                };

                ToSlot.find('.inventory-slot-info > .inventory-slot-quantity').html(`${NewTotal}x`);
                ToSlot.find('.inventory-slot-info > .inventory-slot-weight').html(`${(ItemData.Weight * NewTotal).toFixed(2)}`);
            } else {
                if (ToInv.attr("inventory-name") == "player") {
                    MyInventory[ToSlotId] = FromItem;
                } else {
                    OtherInvData.Items[ToSlotId] = FromItem;
                };

                ToSlot.html(FromHtml);
            };
        } else {
            ToSlot.html(FromHtml);

            FromSlot.find('.inventory-slot-info > .inventory-slot-quantity').html(`${(FromItem.Amount - Amount)}x`);
            FromSlot.find('.inventory-slot-info > .inventory-slot-weight').html(`${(ItemData.Weight * (FromItem.Amount - Amount)).toFixed(2)}`);

            if (FromInv.attr("inventory-name") == "player") {
                MyInventory[FromSlotId].Amount = FromItem.Amount - Amount;
            } else {
                OtherInvData.Items[FromSlotId].Amount = FromItem.Amount - Amount;
            };

            let NewTotal = Amount;
            if (ToItem) {
                if (ToInv.attr("inventory-name") == "player") {
                    MyInventory[ToSlotId].Amount = MyInventory[ToSlotId].Amount + Amount
                    NewTotal = MyInventory[ToSlotId].Amount;
                } else {
                    OtherInvData.Items[ToSlotId].Amount = OtherInvData.Items[ToSlotId].Amount + Amount
                    NewTotal = OtherInvData.Items[ToSlotId].Amount;
                };

            } else {
                if (ToInv.attr("inventory-name") == "player") {
                    MyInventory[ToSlotId] = { ...FromItem, Amount: Amount };
                } else {
                    OtherInvData.Items[ToSlotId] = { ...FromItem, Amount: Amount };
                };
            };

            ToSlot.find('.inventory-slot-info > .inventory-slot-quantity').html(`${NewTotal}x`);
            ToSlot.find('.inventory-slot-info > .inventory-slot-weight').html(`${(ItemData.Weight * NewTotal).toFixed(2)}`);
        };
    };
    
    if (FromInv.attr("inventory-name") != ToInv.attr("inventory-name")) {
        UpdateInventoryWeights(FromInv.attr("inventory-name"));
        UpdateInventoryWeights(ToInv.attr("inventory-name"));
    }
};

const RandomString = (Length) => {
    var Retval = '';
    var Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    for (var i = 0; i < Length; i++) Retval += Chars.charAt(Math.floor(Math.random() * Chars.length));
    return Retval;
};

const InventoryBox = (Text, Item, Amount, CustomType) => {
    var ItemData = ItemsList[Item];
    if (ItemData == undefined) return;

    var Id = RandomString(8);
    var Image = GetItemImage(Item, CustomType);
    ItemData = GetItemData(Item, CustomType);

    $('.inventory-boxbar').append(`<div id="box-${Id}" class="inventory-boxbar-slot">
        <div class="inventory-slot-text">${Text} ${Amount ? `${Amount}x` : ``}</div>
        <div class="inventory-slot-name">${ItemData.Label}</div>
        <div class="inventory-slot-image" style="background-image: url(${Image})"></div>
    </div>`);
    $(`.inventory-boxbar-slot#box-${Id}`).fadeIn(1000);

    setTimeout(() => {
        $(`.inventory-boxbar-slot#box-${Id}`).fadeOut(500, () => {
            $(`.inventory-boxbar-slot#box-${Id}`).remove();
        });
    }, 2500);
};

const GenerateItemInfo = (InvName, SlotId) => {
    const Item = InvName == 'player' ? MyInventory[SlotId] : OtherInvData.Items[SlotId]
    if (!Item) return false;

    const ItemData = GetItemData(Item.Item, Item.CustomType, Item.Info);
    var ItemMetadata = ``;
    var InfoIndex = 0;

    $.each(Item.Info, function(Index, Value){
        if (!HiddenMetadata.includes(Index) && !Index.startsWith('_')) {
            var MetaDataIndex = Index;
            if (ItemI18n[Item.Item] && ItemI18n[Item.Item][Index]) MetaDataIndex = ItemI18n[Item.Item][Index];

            InfoIndex++;
            ItemMetadata += `${InfoIndex > 1 ? '| ' : ``}${MetaDataIndex}: ${Value} `;
        };
    });

    ItemMetadata += `${ItemMetadata.length > 0 ? `<br><br>` : ``}${ItemData.Description} `;

    var Quality = CalculateQuality(Item.Item, Item.CreateDate);
    var QualityColor = `green`;
    if (Quality.Percentage > 75) {
        QualityColor = '#5FF03C';
    } else if (Quality.Percentage > 50) {
        QualityColor = '#74C242';
    } else if (Quality.Percentage > 25) {
        QualityColor = '#DEB837';
    } else if (Quality.Percentage >= 0) {
        QualityColor = '#CC2727';
    };

    return `<h2>${ItemData.Label}</h2><div class="inventory-hover-info">${ItemMetadata}<hr><strong>Weight</strong>: ${ItemData.Weight.toFixed(2)} | <strong>Amount</strong>: ${Item.Amount} | <strong>Quality</strong>: <span style="color: ${QualityColor}">${Quality.Percentage}</span></div>`;
};

const CopyToClipboard = (Text) => {
    var TextArea = document.createElement('textarea');
    TextArea.value = Text
    TextArea.style.top = '0';
    TextArea.style.left = '0';
    TextArea.style.position = 'fixed';
    document.body.appendChild(TextArea);
    TextArea.focus();
    TextArea.select();
    try { document.execCommand('copy'); } catch (err) {}
    document.body.removeChild(TextArea);
};