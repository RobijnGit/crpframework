var SelectedAdminCat = null;
var CurrentAdminCat = 'all';

const Delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

var AdminOpen = false;
var FocusEnabled = true;
var Loaded = false;
var CurrentTarget = false;

var FavoritedItems = [];
var AdminPlayers = [];
var AdminItems = [];
var BindableItems = 


$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.Action) {
            case 'LoadBindableItems':
                let Options = `<option value="0">None</option>`;
                for (let i = 0; i < event.data.BindableItems.length; i++) {
                    const Value = event.data.BindableItems[i];
                    Options += `<option value="${Value.Key}">${Value.Label}</option>`;
                };

                for (let i = 1; i <= event.data.Binds; i++) {
                    $('.admin-menu-settings').append(`<div class="admin-menu-settings-item settings-bind-${i}">
                        <p>Select option for Bind ${i}</p>
                        <select style="width: 100%" class="ui search selection dropdown">${Options}</select>
                    </div>`);
                };

                $('.admin-menu-settings').append(`<div style="margin-top: 1vh; padding: 1vh !important;" class="save-admin-binds admin-menu-execute">Save</div>`);

                $(`.settings-bind-1 > select`).dropdown({ fullTextSearch: true }).dropdown('set selected', event.data.Values['bind_1']);
                $(`.settings-bind-2 > select`).dropdown({ fullTextSearch: true }).dropdown('set selected', event.data.Values['bind_2']);
                $(`.settings-bind-3 > select`).dropdown({ fullTextSearch: true }).dropdown('set selected', event.data.Values['bind_3']);
                $(`.settings-bind-4 > select`).dropdown({ fullTextSearch: true }).dropdown('set selected', event.data.Values['bind_4']);
                $(`.settings-bind-5 > select`).dropdown({ fullTextSearch: true }).dropdown('set selected', event.data.Values['bind_5']);
                break;
            case 'OpenMenu':
                OpenAdminMenu(event.data.AdminItems, event.data.AllPlayers, event.data.Favorites);
                break;
            case 'CloseMenu':
                if (!AdminOpen) return;
                CloseAdminMenu();
                break;
            case 'CopyClipboard': 
                const el = document.createElement('textarea');
                el.value = event.data.Text;
                document.body.appendChild(el);
                el.select();
                document.execCommand('copy');
                document.body.removeChild(el);
                break;
        }
    });
})

// Functions

NumberWithDots = new Intl.NumberFormat('nl-NL', {
    style: 'currency',
    currency: 'EUR',
});

BuildPlayerList = () => {
    $('.admin-menu-players').empty();

    AdminPlayers.sort(function(a, b) { return a.ServerId - b.ServerId });

    for (let i = 0; i < AdminPlayers.length; i++) {
        const Ply = AdminPlayers[i];

        TeleportToPlayer = (Element) => {
            var ServerId = Element.getAttribute("playerId");
            $.post('https://fw-admin/Trigger/Button', JSON.stringify({
                Event: 'Admin:Teleport',
                EventType: null,
                Result: {
                    player: ServerId,
                    type: 'Goto',
                }
            }));
        }

        SpectatePlayer = (Element) => {
            var ServerId = Element.getAttribute("playerId");
            $.post('https://fw-admin/Spectate/Player', JSON.stringify({
                Player: ServerId
            }));
        }
        
        var PlyCard = `<div class="admin-player-item">
            <div class="admin-player-name">[${Ply.ServerId}] ${Ply.Name}</div>
            <div class="admin-player-steam">${Ply.Steam}</div>
            <div class="admin-player-collapsible">
                <div class="admin-player-collapsible-entry">
                    <p>Character Name</p>
                    <p>${Ply.CharName}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Cid</p>
                    <p>${Ply.Cid}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Server ID</p>
                    <p>${Ply.ServerId}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Steam ID</p>
                    <p>${Ply.Steam}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Cash</p>
                    <p>${NumberWithDots.format(Ply.Cash)}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Bank</p>
                    <p>${NumberWithDots.format(Ply.Bank)}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Job</p>
                    <p>${Ply.Job} / ${Ply.Grade} [${Ply.GradeName}]</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>High Command</p>
                    <p>${Ply.Highcommand ? 'Yes' : 'No'}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Apartment Id</p>
                    <p>${Ply.ApartmentId}</p>
                </div>
                <div class="admin-player-collapsible-entry">
                    <p>Bank / Phone Number</p>
                    <p>${Ply.Account} / ${Ply.Phone}</p>
                </div>
                <div style="background-color: transparent; color: black; margin-top: 2vh;" class="admin-player-collapsible-entry">
                    <div playerId="${Ply.ServerId}" onclick="TeleportToPlayer(this)" class="admin-menu-execute">Teleport to Player</div>
                    <div playerId="${Ply.ServerId}" style="opacity: 0.5" class="admin-menu-execute">Spectate Player (Use TX)</div>
                </div>
            </div>
        </div>`;

        $('.admin-menu-players').append(PlyCard);
    }
}

BuildFavorites = () => {
    $('.admin-menu-item.favorited').remove();
    $('.admin-menu-item').show();

    FavoritedItems.sort(function(a, b) { return b - a });

    for (let i = 0; i < FavoritedItems.length; i++) {
        const Key = FavoritedItems[i];
        const MenuData = $('.admin-menu-item').eq(Key + i).data('MenuData');
        $('.admin-menu-item').eq(Key + i).hide();

        var Collapse = BuildCollapse(MenuData);
        var CollapseOptions = Collapse[0];
        var Dropdowns = Collapse[1];
    
        var AdminOption = `<div data-id="${Key}" data-category="${MenuData.Category}" class="admin-menu-item favorited" id="admin-option-${MenuData.Id}">
            <div class="admin-menu-item-favorited"><i class="fas fa-star"></i></div>
            <div class="admin-menu-item-name">${MenuData.Name}</div>
            ${CollapseOptions}
        </div>`;
    
        $('.admin-menu-items').prepend(AdminOption);
        $(`#admin-option-${MenuData.Id}.favorited`).data('MenuData', MenuData);
    
        if (Dropdowns.length > 0) {
            for (let i = 0; i < Dropdowns.length; i++) {
                const Dropdown = Dropdowns[i];
                $(`[data-option="${Dropdown}"] > select`).dropdown({ allowAdditions: true, fullTextSearch: true });
            };
        };
    };

    RecolorItems();
}

OpenAdminMenu = function(MenuItems, MenuPlayers, Favorited) {
    FavoritedItems = Object.values(Favorited) || [];
    $('.admin-wrapper').css('pointer-events', 'auto');
    $('.admin-menu-container').fadeIn(450);
    AdminPlayers = MenuPlayers;
    AdminItems = MenuItems;
    AdminOpen = true;
    
    if (!Loaded) {
        Loaded = true;
        LoadAdminItems();
    } else {
        var NewPlayerList = ConvertPlayerList();
        $('.admin-option-target').each(function(Elem, Obj) {
            $(this).find('select').html(NewPlayerList);
        })
    };
};

CloseAdminMenu = function() {
    $.post('https://fw-admin/Close', JSON.stringify({}));
    $('.admin-wrapper').css('pointer-events', 'none');
    $('.admin-menu-container').fadeOut(150, function() {
        AdminOpen = false;
    });
};

LoadAdminItems = async function() {
    $('.admin-menu-items').html('');
    $.each(AdminItems, function(Key, Value) {
        BuildAdminMenuItem(Value, Key);
    });
    BuildFavorites();
};

SwitchAdminCategory = function(Button, Type) {
    $('.admin-menu-search input').val('');
    $(SelectedAdminCat).removeClass("active");
    $(Button).addClass("active");
    SelectedAdminCat = Button
    CurrentAdminCat = Type

    $('.admin-menu-item').each(function(Elem, Obj){
        if (FavoritedItems.includes(Number($(this).attr("data-id"))) && !$(this).hasClass("favorited")) return;

        $(this).show();
        if (CurrentAdminCat != 'all' && $(this).attr("data-category") != CurrentAdminCat) {
            $(this).hide();
        }
    });
    RecolorItems();
}

RecolorItems = () => {
    var ItemsAdded = 0;
    $('.admin-menu-item').each(function(Elem, Obj){
        if ($(this).is(":visible")) {
            if(ItemsAdded % 2 == 1) {
                $(this).removeClass('odd').addClass('even');
            } else {
                $(this).removeClass('even').addClass('odd');
            }
            ItemsAdded++;
        }
    });
};

var ConvertPlayerList = () => {
    var PlayerList = '<option value=""></option>';
    for (var i = 0; i < AdminPlayers.length; i++) {
        var Player = AdminPlayers[i];
        PlayerList += `<option value="${Player.ServerId}">(${Player.ServerId}) ${Player.Name} ${Player.Steam}</option>`;
    };
    return PlayerList;
}

var BuildCollapse = (Item) => {
    var CollapseOptions = ``;
    var Dropdowns = [];

    if (Item.Options != undefined && Item.Options.length > 0) {
        CollapseOptions += `<div class="admin-menu-item-options">`
        
        for (let i = 0; i < Item.Options.length; i++) {
            const Option = Item.Options[i];

            var DOMElement = `<div class="admin-menu-items-option-input">
                <div id="${Option.Id}" class="ui-styles-input">
                    <p>${Option.Name}:</p>
                    <input type="text">
                </div>
            </div>`;
            
            if (Option.Type.toLowerCase() == 'input-choice' || Option.Type.toLowerCase() == 'text-choice') {
                var Options = '<option value=""></option>';

                if (Option.Id == 'player') {
                    Options = ConvertPlayerList();
                } else {
                    for (let i = 0; i < Option.Choices.length; i++) {
                        const Choice = Option.Choices[i];
                        Options += `<option value="${Choice.Val}">${Choice.Text}</option>`
                    }
                }

                Dropdowns.push(`${Item.Id}-${Option.Id}`)
                DOMElement = `<div data-option="${Item.Id}-${Option.Id}" id="${Option.Id}" class="ui-styles-collapsible ${Option.Id == 'player' ? 'admin-option-target' : ''}">
                    <p>${Option.Name}</p>
                    <select class="ui search selection dropdown">${Options}</select>
                </div>`;
            }
            
            CollapseOptions += `${DOMElement}`;
        }
        
        CollapseOptions += `<div class="admin-menu-execute">${Item.Name}</div></div>`
    }

    return [CollapseOptions, Dropdowns];
}

var BuildAdminMenuItem = (Item, Key) => {
    var Collapse = BuildCollapse(Item);
    var CollapseOptions = Collapse[0];
    var Dropdowns = Collapse[1];

    var AdminOption = `<div data-id="${Key}" data-category="${Item.Category}" class="admin-menu-item" id="admin-option-${Item['Id']}">
        <div class="admin-menu-item-favorited"><i class="far fa-star"></i></div>
        <div class="admin-menu-item-name">${Item.Name}</div>
        ${CollapseOptions}
    </div>`;

    $('.admin-menu-items').append(AdminOption);
    $(`#admin-option-${Item['Id']}`).data('MenuData', Item);

    if (Dropdowns.length > 0) {
        for (let i = 0; i < Dropdowns.length; i++) {
            const Dropdown = Dropdowns[i];
            $(`[data-option="${Dropdown}"] > select`).dropdown({ allowAdditions: true, fullTextSearch: true });
        }
    }
};

// Click

$(document).on('click', '.admin-menu-navbar-item', function(e) {
    e.preventDefault();
    var Type = $(this).attr('data-Type');
    SwitchAdminCategory($(this), Type)
});

$(document).on('click', '.admin-menu-item', function(e) {
    e.preventDefault();
    var Data = $(this).data('MenuData');
    if ($(this).find('.admin-menu-item-favorited:hover').length != 0) return;

    if (Data != undefined && !Data.Collapse) {
        if (Data.Toggle) {
            $(this).toggleClass('enabled')
        };
        $.post('https://fw-admin/Trigger/Button', JSON.stringify({Event: Data.Event, EventType: Data.EventType, Result: $(this).hasClass('enabled') ? true : false}));
    } else if (Data && Data.Collapse) {
        var OptionsDom = $(this).find('.admin-menu-item-options');

        if (OptionsDom.hasClass('extended')) {
            if (!$(e.target).hasClass('admin-menu-item-name')) return;
            $(this).css({
                height: '3.6vh',
                overflow: 'hidden',
            });
            OptionsDom.removeClass('extended');
        } else {
            $(this).css({
                height: 'max-content',
                overflow: 'visible',
            });
            OptionsDom.addClass('extended');
        };
    };
});

$(document).on('click', '.admin-menu-item-favorited', function(e) {
    e.preventDefault();

    var IsFavorited = $(this).parent().hasClass("favorited");

    if (IsFavorited) {
        var Index = FavoritedItems.indexOf(Number($(this).parent().attr("data-id")));
        FavoritedItems.splice(Index, 1);
    } else {
        FavoritedItems.push(Number($(this).parent().attr("data-id")));
    }

    $.post("https://fw-admin/Favorites", JSON.stringify({
        Favorites: FavoritedItems
    }));

    BuildFavorites();
});

$(document).ready(function(){
    SelectedAdminCat = $('.admin-menu-navbar').find('.active');
})

$(document).on({
    keydown: function(e) {
        if (e.keyCode == 27 && AdminOpen) {
            CloseAdminMenu();
        }
    },
});

$(document).on('click', '.admin-menu-execute', function(e){
    var Data = $(this).parent().parent().data('MenuData')
    if (Data == undefined) return;

    var Result = {};
    
    $(this).parent().find('.ui-styles-input').each(function(Elem, Obj){
        Result[$(this).attr("id")] = $(this).find('input').val();
    });

    $(this).parent().find('.ui-styles-collapsible').each(function(Elem, Obj){
        Result[$(this).attr("id")] = $(this).find('select').val();
    });

    $.post('https://fw-admin/Trigger/Button', JSON.stringify({
        Player: CurrentTarget,
        Event: Data.Event,
        EventType: Data.EventType,
        Result: Result
    }));
})

$(document).on('click', '.save-admin-binds', function(e){
    $.post('https://fw-admin/SaveBinds', JSON.stringify({
        bind_1: $('.settings-bind-1').find('select').val(),
        bind_2: $('.settings-bind-2').find('select').val(),
        bind_3: $('.settings-bind-3').find('select').val(),
        bind_4: $('.settings-bind-4').find('select').val(),
        bind_5: $('.settings-bind-5').find('select').val(),
    }));
})

$(document).on('focus', 'input', function(e){
    if (FocusEnabled) return;

    $('.admin-menu-sidebar-item[data-tooltip="Full Focus"]').addClass('active');
    $.post('https://fw-admin/Trigger/Focus', JSON.stringify({
        Focus: true
    }));
});

$(document).on('focusout', 'input', function(e){
    if (FocusEnabled) return;

    $('.admin-menu-sidebar-item[data-tooltip="Full Focus"]').removeClass('active');
    $.post('https://fw-admin/Trigger/Focus', JSON.stringify({
        Focus: false
    }));
});

$(document).on('input', '.admin-menu-search input', function(e){
    let SearchText = $(this).val().toLowerCase();

    $('.admin-menu-item').each(function(Elem, Obj){
        if (FavoritedItems.includes(Number($(this).attr("data-id"))) && !$(this).hasClass("favorited")) return;

        if ($(this).find('.admin-menu-item-name').html().toLowerCase().includes(SearchText)) {
            $(this).show();
        } else {
            $(this).hide();
        };
    });

    $('.admin-player-item').each(function(Elem, Obj){
        if ($(this).find('.admin-player-name').html().toLowerCase().includes(SearchText) || $(this).find('.admin-player-steam').html().toLowerCase().includes(SearchText)) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });

    RecolorItems();
});

$(document).on('click', '.admin-menu-sidebar-item', function(e){
    var Type = $(this).attr("data-tooltip");

    if (Type == 'Onzichtbaar') {
        $(this).toggleClass('active');
        $.post('https://fw-admin/Trigger/Cloak', JSON.stringify({
            Cloak: $(this).hasClass('active') ? true : false
        }));
    } else if (Type == 'Full Focus') {
        $(this).toggleClass('active');
        FocusEnabled = $(this).hasClass('active') ? true : false;
        $.post('https://fw-admin/Trigger/Focus', JSON.stringify({
            Focus: FocusEnabled
        }));
    } else if (Type == 'Commands') {
        $('.admin-menu-navbar').show();
        $('.admin-menu-search').show();
        $('.admin-menu-items').fadeIn(250);
        $('.admin-menu-settings').hide();
        $('.admin-menu-players').hide();
    } else if (Type == 'Speler Lijst') {
        BuildPlayerList();
        $('.admin-menu-navbar').hide();
        $('.admin-menu-search').show();
        $('.admin-menu-items').hide();
        $('.admin-menu-settings').hide();
        $('.admin-menu-players').fadeIn(250);
    } else if (Type == 'Instellingen') {
        $('.admin-menu-navbar').hide();
        $('.admin-menu-search').hide();
        $('.admin-menu-items').hide();
        $('.admin-menu-settings').fadeIn(250);
        $('.admin-menu-players').hide();
    } else if (Type == "Reset Favorieten") {
        FavoritedItems = [];
        $.post("https://fw-admin/Favorites", JSON.stringify({
            Favorites: []
        }));
        BuildFavorites();
    };
});

$(document).on('click', '.admin-player-item', function(e){
    var OptionsDom = $(this).find('.admin-player-collapsible');
    if ($(e.target).hasClass('admin-menu-execute')) return;

    if (OptionsDom.hasClass('extended')) {
        $(this).css({ height: '3.6vh' });
        OptionsDom.removeClass('extended');
    } else {
        $(this).css({ height: 'max-content' });
        OptionsDom.addClass('extended');
    };
})

$(document).on('change', '.admin-option-target select', function(e){
    CurrentTarget = $(this).val();
    $('.admin-option-target').each(async function(Elem, Obj) {
        $(this).find('select').dropdown('set selected', CurrentTarget);
        await Delay(50);
    })
})