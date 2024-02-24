$(document).ready(function(){
    $.post("https://fw-inventory/LoadInventory");

    window.addEventListener('message', event => {
        switch (event.data.Action) {
            case "SetItemsList":
                console.log(`[INVENTORY]: ItemsList loaded!`)
                ItemsList = event.data.Items;
                CustomTypes = event.data.CustomTypes;
                break;
            case "SetCustomTypes":
                console.log(`[INVENTORY]: CustomTypes loaded!`)
                CustomTypes = event.data.CustomTypes;
                break;
            case "UpdateSlot":
                MyInventory[event.data.SlotId] = event.data.Data;

                if (event.data.Data) {
                    const QualityData = CalculateQuality(event.data.Data.Item, event.data.Data.CreateDate);
                    const ItemData = GetItemData(event.data.Data.Item, event.data.Data.CustomType);

                    let SlotHtml = '';
                    if (event.data.SlotId <= 5 ) SlotHtml += `<div class="inventory-slot-bind">${event.data.SlotId}</div>`;

                    SlotHtml += `
                        <div class="${QualityData.Class}" style="width: ${QualityData.Percentage}%; background-position: 0% ${100 - QualityData.Percentage}%"></div>
                        <div class="inventory-slot-name">${ItemData.Label}</div>
                        <div class="inventory-slot-image" style="background-image: url(${GetItemImage(event.data.Data.Item, event.data.Data.CustomType, event.data.Data.Info)})"></div>
                        <div class="inventory-slot-info">
                            <span class="inventory-slot-quantity">${event.data.Data.Amount}x</span>
                            <span class="inventory-slot-weight">${(ItemData.Weight * event.data.Data.Amount).toFixed(2)}</span>
                        </div>
                    `;
                    $(`.inventory-box[inventory-name="player"] > .inventory-box-slots > .inventory-box-slot[data-slot="${event.data.SlotId}"]`).html(SlotHtml)
                } else {
                    ClearInventorySlot($('.inventory-box[inventory-name="player"]'), event.data.SlotId)
                };

                UpdateInventoryWeights('player');

                break;
            case "OpenInventory":
                InventoryOpen = true;
                OtherInvData = event.data.OtherData;
                MyInventory = event.data.Inventory;
                HasWeaponsLicense = event.data.HasLicense;

                $('.inventory-box[inventory-name="other"] .inventory-box-header-weight').html(`<span>0</span>/${OtherInvData.Weight}`)

                BuildInventory('player', 'Player', MyInventory, MaxPlayerSlots);
                BuildInventory('other', OtherInvData.Type, OtherInvData.Items, OtherInvData.Slots);

                $('.actions-wrapper > .inventory-actions > #steal-money').remove();
                if (OtherInvData.Type == 'Other Player') {
                    $('.actions-wrapper > .inventory-actions').append(`<button class="inventory-actions-btn" id="steal-money" style="margin: 0.5vh 0;">Geld Stelen</button>`)
                }

                $('.inventory-wrapper').fadeIn(100);
                break;
            case "CloseInventory":
                $('.inventory-wrapper').fadeOut(100);
                break;
            case "InventoryHotbar":
                if (event.data.Visible) {
                    $('.inventory-hotbar').stop(true, true).empty();
                    for (let i = 1; i <= 5; i++) {
                        const Item = event.data.Items[i];
    
                        if (Item && ItemsList[Item.Item]) {
                            const ItemData = GetItemData(Item.Item, Item.CustomType);
                            $('.inventory-hotbar').append(`<div class="inventory-hotbar-slot">
                                <div class="inventory-slot-bind" style="font-size: 6vh">${i}</div>
                                <div class="inventory-slot-name">${ItemData.Label} ${Item.Info && Item.Info.Ammo ? `- ${Item.Info.Ammo}` : ''}</div>
                                <div class="inventory-slot-image" style="background-image: url(${GetItemImage(Item.Item, Item.CustomType, Item.Info)})"></div>
                            </div>`);
                        } else {
                            $('.inventory-hotbar').append(`<div class="inventory-hotbar-slot">
                                <div class="inventory-slot-bind" style="font-size: 6vh">${i}</div>
                                <div class="inventory-slot-name"></div>
                            </div>`);
                        }
                    }

                    $('.inventory-hotbar').show();
                } else {
                    $('.inventory-hotbar').fadeOut(2000);
                };
                break;
            case "InventoryBox":
                InventoryBox(event.data.Text, event.data.Item, event.data.Amount, event.data.CustomType)
                break;
            default:
                console.log(`[INVENTORY]: Invalid Action: '${event.data.Action}'`)
                console.log(`[INVENTORY]: Payload:\n${JSON.stringify(event.data, undefined, 2)}`)
                break;
        };
    });
});

const CloseInventory = () => {
    InventoryOpen = false;

    $.post("https://fw-inventory/CloseInventory")
    $('.inventory-wrapper').fadeOut(100);

    $('.drag-item').empty();
    $('.drag-item').css('opacity', '0.0');
    $('.inventory-slot-hover').css('opacity', '0.0');
    DragData.IsDragging = false;
};

$(document).on("click", '#steal-money', function(e){
    $.post("https://fw-inventory/StealMoney", JSON.stringify({}));
});

$(document).on("keydown", function(e){
    if (window.event.ctrlKey && e.keyCode == 67) {
        CopyToClipboard($(".inventory-slot-hover > .inventory-hover-info").text());
    }
});

$(document).on({
    mouseenter: function(){ $('.inventory-help-menu').fadeIn(150); },
    mouseleave: function(){ $('.inventory-help-menu').fadeOut(150); },
}, '#inventory-action-help');

$(document).on("keydown", 'body', function(e){
    if (!window.event.ctrlKey && e.keyCode == 67) {
        $("#inventory-move-amount").val('');
    }
});

document.onkeyup = function(Data) {
    if (Data.which == 27 && InventoryOpen) {
        CloseInventory()
    };
};

$(document).on('click', '#inventory-close', function(Event) {
    Event.preventDefault();
    CloseInventory()
});

$(document).on('mouseup', '#inventory-use', function(e){
    if (!DragData.IsDragging) return;
    if (DragData.FromInv != 'player') return;

    CloseInventory();
    setTimeout(() => {
        $.post("https://fw-inventory/UseItem", JSON.stringify({ Slot: DragData.FromSlot }));
    }, 250);
});

$(document).on({
    mouseover: function (e){
        var FromInv = $(this).closest('.inventory-box').attr('inventory-name');
        var Text = GenerateItemInfo(FromInv == 'player' ? 'player' : OtherInvData.Name, $(this).attr("data-slot"));
        if (!Text) return;

        $('.inventory-slot-hover').html(Text);
        
        var ItemOffset = $(this).offset();
        var LeftOffset = ItemOffset.left + 92;
        if (LeftOffset + $('.inventory-slot-hover').width() > $(window).width()) LeftOffset = $(window).width() - $('.inventory-slot-hover').width() - 20;

        $('.inventory-slot-hover').css({
            opacity: 1,
            top: ItemOffset.top - $('.inventory-slot-hover').height(),
            left: LeftOffset
        });
    },
    mouseleave: function (e){
        $('.inventory-slot-hover').css({opacity: '0.0'});
    }
}, ".inventory-box-slot");