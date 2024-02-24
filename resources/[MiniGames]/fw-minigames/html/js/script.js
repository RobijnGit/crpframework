function Delay(ms) { return new Promise(resolve => setTimeout(resolve, ms)); }

// Keystroke
Keystroke = {
    Active: false, 
    GameDifficulty: 0,
    Difficulty: [
        [ 'w', 'a', 's', 'd' ],
        [ 'w', 'a', 's', 'd', 'j', 'k', 'l' ],
        [ 'w', 'a', 's', 'd', 'j', 'k', 'l', 'i', 'g' ],
    ],
    Speeds: [ 2.0, 1.5, 1.2 ],
    Intervals: [ 1000, 750, 500 ],
    Interval: undefined,
    Keys: [],
    Stats: { Success: 0, Fail: 0 },
    SuccessQuantity: 0,
    FailQuantity: 0,
};

Keystroke.StartMinigame = async Settings => {
    Keystroke.Active = true;
    $('.keystroke-container').show();

    var Difficulty = Keystroke.Difficulty[Settings.Difficulty];
    var Speed = Keystroke.Speeds[Settings.Difficulty];
    var Interval = Keystroke.Intervals[Settings.Difficulty];

    Keystroke.GameDifficulty = Difficulty;
    Keystroke.FailQuantity = Settings.Fail;
    Keystroke.SuccessQuantity = Settings.Success;
    Keystroke.Stats = { Success: 0, Fail: 0 };
    Keystroke.Keys = [];

    Keystroke.SetMessage('keyboard', 'Patroonherkenning vereist..');
    await Delay(2000);
    Keystroke.ClearMessage();

    $('.keystroke-container').html(`<div class="keystroke-bar"></div>
    <div class="keystroke-rows">
        <div class="keystroke-rows-row"></div>
        <div class="keystroke-rows-row"></div>
        <div class="keystroke-rows-row"></div>
        <div class="keystroke-rows-row"></div>
        <div class="keystroke-rows-row"></div>
    </div>`);

    Keystroke.Interval = setInterval(() => {
        const Row = Math.floor(Math.random() * 5) + 1;
        var RowElement = $('.keystroke-rows-row').eq(Row - 1);
        var RandomKey = Difficulty[Math.floor(Math.random() * Difficulty.length)];
        var Key = $(`<span>${RandomKey}</span>`);
        RowElement.append(Key);

        Keystroke.StartKeyLoop(Key, Speed);
    }, Interval);

    $(document).focus();
};

Keystroke.StartKeyLoop = async (Key, Speed) => {
    Keystroke.Keys.push({ Element: Key, Anim: undefined });
    
    Keystroke.Keys[Keystroke.Keys.length - 1].Anim = Key.animate({
        top: '-0.5vh',
    }, Speed * 1000, 'linear', function() {
        Key.css('color', 'red').fadeOut(500, () => { $(this).remove() });
        Keystroke.Keys.splice(Keystroke.Keys.indexOf(Keystroke.Keys.find(k => k.Element == Key)), 1);
        Keystroke.Stats.Fail++;
        Keystroke.CheckForWin();
    });
};

Keystroke.CheckForWin = async () => {
    if (Keystroke.Stats.Fail >= Keystroke.FailQuantity) {
        for (let i = 0; i < Keystroke.Keys.length; i++) { Keystroke.Keys[i].Anim.stop(); }
        Keystroke.Active = false;
        clearInterval(Keystroke.Interval)

        Keystroke.SetMessage('keyboard', 'Toegang Geweigerd');
        await Delay(2000);
        Keystroke.ClearMessage();
        $('.keystroke-container').hide();

        $.post("https://fw-minigames/Minigames/Keystroke/Won", JSON.stringify({ Won: false }));
        return;
    }

    if (Keystroke.Stats.Success >= Keystroke.SuccessQuantity) {
        for (let i = 0; i < Keystroke.Keys.length; i++) { Keystroke.Keys[i].Anim.stop(); }
        Keystroke.Active = false;
        clearInterval(Keystroke.Interval)

        Keystroke.SetMessage('keyboard', 'Toegang Verleend');
        await Delay(2000);
        Keystroke.ClearMessage();
        $('.keystroke-container').hide();

        $.post("https://fw-minigames/Minigames/Keystroke/Won", JSON.stringify({ Won: true }));
        return;
    }
}

Keystroke.SetMessage = (Icon, Msg) => {
    $('.keystroke-container').html(`<div class="keystroke-container-center">
        <i class="fas fa-${Icon}"></i>
        <p>${Msg}</p>
    </div>`);
};

Keystroke.ClearMessage = () => { $('.keystroke-container > .keystroke-container-center').remove(); }

$(document).on('keydown', function(e){
    if (Keystroke.Active) {
        var Key = Keystroke.Keys[0];
        if (!Key) return;
        if (Keystroke.GameDifficulty.indexOf(e.key) == -1) return;
        
        if (Keystroke.Keys.length > 0 && Key.Element.text() != e.key) {
            Key.Anim.stop();
            Key.Element.css('color', 'red').fadeOut(500, () => { $(this).remove() });
            Keystroke.Keys.splice(Keystroke.Keys.indexOf(Keystroke.Keys.find(k => k.Element == Key.Element)), 1);
            Keystroke.Stats.Fail++;
            Keystroke.CheckForWin();
            return;
        }

        var BarTop = $('.keystroke-bar').offset().top - 15;
        var BarBottom = BarTop + $('.keystroke-bar').height() + 30;

        var KeyTop = Key.Element.offset().top;
        var KeyBottom = KeyTop + Key.Element.height();

        if (KeyTop >= BarTop && KeyBottom <= BarBottom) {
            Key.Anim.stop();
            Key.Element.css('color', '#3cec59').fadeOut(500, () => { $(this).remove() });
            Keystroke.Keys.splice(Keystroke.Keys.indexOf(Keystroke.Keys.find(k => k.Element == Key.Element)), 1);
            Keystroke.Stats.Success++;
            Keystroke.CheckForWin();
        } else {
            Key.Anim.stop();
            Key.Element.css('color', 'red').fadeOut(500, () => { $(this).remove() });
            Keystroke.Keys.splice(Keystroke.Keys.indexOf(Keystroke.Keys.find(k => k.Element == Key.Element)), 1);
            Keystroke.Stats.Fail++;
            Keystroke.CheckForWin();
        }
    }
});

// Slider
var IsCtrlPressed = false;
var IgnoreNextValueSlide = false;

const StartRangeSlideMinigame = (Sliders) => {
    $('.slider-container .slider-container-sliders').empty();

    for (let i = 0; i < Sliders.length; i++) {
        const Slider = Sliders[i];
        $('.slider-container .slider-container-sliders').append(`<input type="range" class="slider-minigame-${i}" step="${Slider.step || 1}" min="${Slider.min || 0}" max="${Slider.max || 100}" value="${Slider.value || 0}" data-orientation="vertical">`)
        $(`.slider-minigame-${i}`).val(Slider.value).change();
        $(`.slider-container .slider-container-sliders .slider-minigame-${i}`).rangeslider({
            polyfill: false,
            onSlide: function(pos, value){
                if (IsCtrlPressed && !IgnoreNextValueSlide) {
                    IgnoreNextValueSlide = true;
                    if (value > 0 && LastValue > value) {
                        value = value - 9;
                        $(`.slider-minigame-${i}`).val(value).change();
                    } else {
                        value = value + 9;
                        $(`.slider-minigame-${i}`).val(value).change();
                    }
                };

                LastValue = value;
                IgnoreNextValueSlide = false;
            }
        });
    }

    $('.slider-container').show();
};

$(document).on('click', '.slider-container .ui-button', function(e){
    let Result = [];

    $('.slider-container .slider-container-sliders input').each(function(Elem, Obj){
        Result.push(Number($(this).val()))
    })

    $('.slider-container').hide();
    $.post("https://fw-minigames/Minigames/Slider/Submit", JSON.stringify({ Result }))
});

// Events
window.addEventListener('message', function(event) {
    switch (event.data.action) {
        case "StartKeystrokeMinigame":
            Keystroke.StartMinigame({ Difficulty: event.data.Difficulty, Success: event.data.Success, Fail: event.data.Fail })
            break;
        case "StartSliderMinigame":
            StartRangeSlideMinigame(event.data.Sliders);
            break;
    };
});

// Check whether control button is pressed
$(document).keydown(function(event) {
    if (event.which == 17) {
        IsCtrlPressed = true;
    }
});

$(document).keyup(function(event) {
    if (event.which == 17) {
        IsCtrlPressed = false;
    }
});