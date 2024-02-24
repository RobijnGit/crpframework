let DragData = {
    IsDragging: false,
    FromInv: false,
    FromSlot: false,
};

const GetInvSpecificItems = (InvName) => {
    for (let i = 0; i < SpecificItemsInv.length; i++) {
        const Data = SpecificItemsInv[i];
        if (InvName.indexOf(Data.Inv) > -1) {
            return Data.Items
        };
    };

    return undefined;
};

const CanBuyWeapon = () => {
    return new Promise(async (Res) => {
        $.post("https://fw-inventory/CanBuyWeapon", JSON.stringify({}), function(CanBuy){
            Res(CanBuy)
        });
    });
};

const HasCraftingItems = (ItemName, CustomType, Amount) => {
    return new Promise(async (Res) => {
        $.post("https://fw-inventory/HasCraftingItems", JSON.stringify({ItemName, CustomType, Amount}), function(Retval){
            Res(Retval)
        });
    });
};

const HasInsertInto = (FromItem, ToItem) => {
    if (FromItem == undefined || FromItem.Item == undefined || ItemsList[FromItem.Item] == undefined) return [ false, false ];
    if (ToItem == undefined || ToItem.Item == undefined || ItemsList[ToItem.Item] == undefined) return [ false, false ];

    const InsertIntoFrom = ItemsList[FromItem.Item].InsertInto
    if (!InsertIntoFrom) return [ false, false ];

    const InsertIntoTo = ItemsList[ToItem.Item].InsertInto
    const IsReversed = InsertIntoTo && InsertIntoTo.includes(FromItem.Item);
    return [InsertIntoFrom.includes(ToItem.Item) || IsReversed, IsReversed]
}

$(document).on('mousemove', 'body', function(e) {
    if (!DragData.IsDragging) return;

    $('.drag-item').css({
        left: e.pageX - $('.drag-item').width() / 2,
        top: e.pageY - $('.drag-item').height() / 2,
    })
});

$(document).on('mousedown', '.inventory-box-slot', function(e) {
    if (e.button === 1 || e.button == 2) return false;

    if (DragData.IsDragging) return;

    const FromInv = $(this).closest('.inventory-box').attr('inventory-name') != 'player' ? OtherInvData.Name : 'player';
    const FromSlot = $(this).attr('data-slot');

    let SlotData = MyInventory[Number(FromSlot)]
    if (FromInv != 'player') SlotData = OtherInvData.Items[Number(FromSlot)];

    if (!SlotData) return;
    if (SlotData.Amount == 0) return;

    if (e.button === 0 && (window.event.ctrlKey || window.event.shiftKey)) {
        const ToInv = FromInv == 'player' ? OtherInvData.Name : 'player'

        if (FromInv == 'Crafting') return;

        if (ToInv != 'player' && (OtherInvData.Type == 'Store' || OtherInvData.Type == 'Crafting')) {
            return InventoryLog("[Error]: Je kan hier geen items naar toe slepen.")
        };

        if (ToInv != 'player' && OtherInvData.Type == 'Bag' && SlotData.IsBag) {
            return InventoryLog("[Error]: Dit is geen Escape from Tarkov.")
        };

        const InvSpecificItems = GetInvSpecificItems(ToInv);
        if (InvSpecificItems && !InvSpecificItems.includes(SlotData.Item)) {
            return InventoryLog('[Error]: Je kan deze item niet in deze inventory plaatsen.')
        };

        const ToSlot = FindSlot(ToInv == 'player' ? MyInventory : OtherInvData.Items, ToInv == 'player' ? MaxPlayerSlots : OtherInvData.Slots, SlotData)

        let MoveAmount = Number($('#inventory-move-amount').val()) || SlotData.Amount;
        if (window.event.shiftKey) MoveAmount = Math.ceil(SlotData.Amount / 2);
        if (MoveAmount > SlotData.Amount) MoveAmount = SlotData.Amount;
        if (MoveAmount <= 0 || MoveAmount == undefined) return InventoryLog("[Error]: Je moet een aantal invullen.");

        const ToInvWeight = CalculateTotalInvWeight(ToInv == 'player' ? MyInventory : OtherInvData.Items);
        const FromItemData = GetItemData(SlotData.Item, SlotData.CustomType);

        // Check if inventory can hold the items.
        if (FromInv != 'player' && ToInv == 'player') {
            if ((FromItemData.Weight * MoveAmount) + ToInvWeight > MaxPlayerWeight) {
                return InventoryLog("[Error]: Je bent te overgewicht.");
            };
        } else if (FromInv == 'player' && ToInv != 'player') {
            if ((FromItemData.Weight * MoveAmount) + ToInvWeight > OtherInvData.Weight) {
                return InventoryLog("[Error]: Inventory is vol.");
            };
        };

        // Slot check
        if (ToSlot == 0 || ToSlot > (ToInv == 'player' ? MaxPlayerSlots : OtherInvData.Slots)) return InventoryLog("[Error]: Inventory is vol.");

        const ToItem = ToInv == 'player' ? MyInventory[ToSlot] : OtherInvData.Items[ToSlot];
        UpdateInventorySlot(FromInv == 'player' ? $(`.inventory-box[inventory-name="player"]`) : $(`.inventory-box[inventory-name="other"]`), ToInv == 'player' ? $(`.inventory-box[inventory-name="player"]`) : $(`.inventory-box[inventory-name="other"]`), FromSlot, ToSlot, SlotData, ToItem, MoveAmount, "Move")

        $.post(`https://fw-inventory/MoveItem`, JSON.stringify({
            FromInv: FromInv != 'player' && OtherInvData.Type == 'Store' ? 'Store' : FromInv,
            ToInv: ToInv,
            FromSlot: Number(FromSlot),
            ToSlot: Number(ToSlot),
            Amount: MoveAmount,
            FromItem: SlotData.Item,
            ToItem: ToItem?.Item,
            FromType: SlotData.CustomType,
            ToType: ToItem?.CustomType,
            Store: OtherInvData.Store,
            Crafting: OtherInvData.Crafting,
        }));

        return;
    };

    DragData.IsDragging = true;
    DragData.FromInv = FromInv != 'player' && OtherInvData.Type == 'Store' ? 'Store' : FromInv;
    DragData.FromSlot = Number(FromSlot);

    $('.drag-item').html($(this).html());
    $('.drag-item').find('.inventory-slot-bind').remove();

    const MoveAmount = $('#inventory-move-amount').val();

    if (MoveAmount > 0 && MoveAmount <= SlotData.Amount) {
        $('.drag-item').find(".inventory-slot-info > .inventory-slot-quantity").text(`${MoveAmount}x`);
        $('.drag-item').find(".inventory-slot-info > .inventory-slot-weight").text(`${(ItemsList[SlotData.Item].Weight * MoveAmount).toFixed(2)}`);
    };

    $('.drag-item').css('opacity', '0.5');

    $('.drag-item').css({
        left: e.pageX - $('.drag-item').width() / 2,
        top: e.pageY - $('.drag-item').height() / 2,
    });
});

$(document).on('mouseup', 'body', async function(e) {
    // Quick use
    if (!$(e.target).hasClass('inventory-box-slot')) {
        $('.drag-item').css('opacity', '0.0');
        $('.drag-item').empty();

        DragData.IsDragging = false;
        return
    };

    const ToInv = $(e.target).closest('.inventory-box').attr('inventory-name') != 'player' ? OtherInvData.Name : 'player';
    const ToSlot = Number($(e.target).attr('data-slot'));

    if (e.button == 1 && ToInv == 'player') {
        const ItemData = MyInventory[ToSlot];
        if (ItemData == undefined) return;

        CloseInventory()
        $.post("https://fw-inventory/UseItem", JSON.stringify({ Slot: ToSlot }));

        return;
    };

    if (!DragData.IsDragging) return;

    $('.drag-item').css('opacity', '0.0');
    $('.drag-item').empty();

    DragData.IsDragging = false;

    if (ToInv != 'player' && IgnoredIntoInvDrag.includes(OtherInvData.Name)) return;
    if (DragData.FromSlot == ToSlot && DragData.FromInv == ToInv) return;

    const FromItem = DragData.FromInv == 'player' ? MyInventory[DragData.FromSlot] : OtherInvData.Items[DragData.FromSlot];
    if (!FromItem) return;

    const ToItem = ToInv == 'player' ? MyInventory[ToSlot] : OtherInvData.Items[ToSlot];

    const FromItemData = GetItemData(FromItem.Item, FromItem.CustomType);

    if (ToInv != 'player' && OtherInvData.Type == 'Bag' && FromItemData.IsBag) {
        return InventoryLog("[Error]: Dit is geen Escape from Tarkov.")
    };

    const InvSpecificItems = GetInvSpecificItems(ToInv);
    if (InvSpecificItems && !InvSpecificItems.includes(FromItem.Item)) {
        return InventoryLog('[Error]: Je kan deze item niet in deze inventory plaatsen.')
    }

    var MoveAmount = Number($("#inventory-move-amount").val());
    var MoveType = "Move";

    if (DragData.FromInv != 'player' && (DragData.FromInv == 'Store' || DragData.FromInv == 'Crafting') && (MoveAmount <= 0 || MoveAmount == undefined)) return InventoryLog("[Error]: Je moet een aantal invullen.");

    if (MoveAmount <= 0 || MoveAmount > FromItem.Amount) MoveAmount = FromItem.Amount;
    if (ToItem && FromItem.Item != ToItem.Item) MoveType = "Swap"; // If not the same item, swap.
    if (ToItem && FromItem.CustomType && FromItem.CustomType != ToItem.CustomType) MoveType = "Swap"; // If not the same custom type, swap.
    if (ToItem && FromItem.Item == ToItem.Item && FromItemData.NonStack) MoveType = "Swap"; // If the same item, but not stackable, swap.

    // const FromInvWeight = CalculateTotalInvWeight(DragData.FromInv == 'player' ? MyInventory : OtherInvData.Items);
    const ToInvWeight = CalculateTotalInvWeight(ToInv == 'player' ? MyInventory : OtherInvData.Items);

    // Weight check.
    if (DragData.FromInv != 'player' && ToInv == 'player') {
        if ((FromItemData.Weight * MoveAmount) + ToInvWeight > MaxPlayerWeight) {
            return InventoryLog("[Error]: Je bent te overgewicht.");
        };
    } else if (DragData.FromInv == 'player' && ToInv != 'player') {
        if ((FromItemData.Weight * MoveAmount) + ToInvWeight > OtherInvData.Weight) {
            return InventoryLog("[Error]: Inventory is vol.");
        };
    };

    // Slot check
    if (ToSlot == 0 || ToSlot > (ToInv == 'player' ? MaxPlayerSlots : OtherInvData.Slots)) return InventoryLog("[Error]: Inventory is vol.");

    if (DragData.FromInv == 'Store' && FromItemData.Price * MoveAmount > PlayerCash) return InventoryLog("[Error]: Je hebt niet genoeg cash..");
    // if (DragData.FromInv == 'Store' && OtherInvData.Store == 'Ammunation' && FromItemData.Weapon && (!HasWeaponsLicense || !await CanBuyWeapon())) {
    //     return InventoryLog("[Error]: Je hebt geen wapenvergunning, of je hebt vandaag al een wapen gekocht!")
    // };

    if (DragData.FromInv == 'Crafting' && !await HasCraftingItems(FromItem.Item, FromItem.CustomType, MoveAmount)) {
        return InventoryLog("[Error]: Je hebt niet alle materialen om dit te maken.")
    };

    if (ToInv != 'player' && (OtherInvData.Type == 'Store' || OtherInvData.Type == 'Crafting')) return;
    if (DragData.FromInv != 'player' && (OtherInvData.Type == 'Store' || OtherInvData.Type == 'Crafting') && MoveType == 'Swap') return;

    const [ HasInsert, IsReversed ] = HasInsertInto(FromItem, ToItem)
    if (DragData.FromInv == 'player' && ToInv == 'player' && HasInsert) {
        $.post(`https://fw-inventory/InsertItem`, JSON.stringify({
            FromItem: FromItem,
            ToItem: ToItem,
            IsReversed
        }));

        CloseInventory();
        return;
    }

    if (DragData.FromInv == 'player' && ToInv == 'player' && ToItem?.Item && FromItem.Item == "repairhammer") {
        $.post(`https://fw-inventory/InsertItem`, JSON.stringify({
            FromItem: FromItem,
            ToItem: ToItem,
            IsReversed: false,
        }));
        return;
    }

    UpdateInventorySlot(DragData.FromInv == 'player' ? $(`.inventory-box[inventory-name="player"]`) : $(`.inventory-box[inventory-name="other"]`), ToInv == 'player' ? $(`.inventory-box[inventory-name="player"]`) : $(`.inventory-box[inventory-name="other"]`), DragData.FromSlot, ToSlot, FromItem, ToItem, MoveAmount, MoveType)

    $.post(`https://fw-inventory/${MoveType}Item`, JSON.stringify({
        FromInv: DragData.FromInv,
        ToInv: ToInv,
        FromSlot: DragData.FromSlot,
        ToSlot: ToSlot,
        Amount: MoveAmount,
        FromItem: FromItem.Item,
        ToItem: ToItem?.Item,
        FromType: FromItem.CustomType,
        ToType: ToItem?.CustomType,
        Store: OtherInvData.Store,
        Crafting: OtherInvData.Crafting,
        FromAmount: FromItem.Amount,
        ToAmount: ToItem?.Amount
    }));

    if (DragData.FromInv == 'Store') {
        setTimeout(() => {
            $.post("https://fw-inventory/FetchMoney", JSON.stringify({}), function(Cash){
                PlayerCash = Cash;
                $(`.inventory-box[inventory-name="other"]`).find('.inventory-box-cash > span').text(Cash.toLocaleString('nl-NL', { style: 'currency', currency: 'EUR' })).parent().show();
            });
        }, 500);
    }

    // console.log(`FromInv -> ${DragData.FromInv} / FromSlot -> ${DragData.FromSlot}\nToInv -> ${ToInv} / ToSlot -> ${ToSlot}\nAmount -> ${MoveAmount}\nFromItem -> ${JSON.stringify(FromItem)}\nToItem: ${JSON.stringify(ToItem)}\nFromShop: ${OtherInvData.Store}`)
});

$(document).on('wheel', (e) => {
    if ($(e.target).attr("id") != "inventory-move-amount") return;

    var Amount = $("#inventory-move-amount").val();
    if (e.originalEvent.deltaY < 0) {
        Amount++;
        if (Amount > 9999) Amount = 9999;
    } else {
        Amount--;
        if (Amount < 0) Amount = 0;
    }

    $("#inventory-move-amount").val(Amount);
    if (!DragData.IsDragging) return;


    const FromItem = DragData.FromInv == 'player' ? MyInventory[DragData.FromSlot] : OtherInvData.Items[DragData.FromSlot]
    if (!FromItem) return;


    const ItemData = GetItemData(FromItem.Item, FromItem.CustomType);
    if (ItemData == undefined) return;
    if (Amount == 0) Amount = FromItem.Amount;

    if (Amount <= FromItem.Amount) {
        $('.drag-item').find(".inventory-slot-info > .inventory-slot-quantity").text(`${Amount}x`);
        $('.drag-item').find(".inventory-slot-info > .inventory-slot-weight").text(`${(ItemData.Weight * Amount).toFixed(2)}`);
    }
});