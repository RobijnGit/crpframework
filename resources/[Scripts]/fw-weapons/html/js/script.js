window.addEventListener('message', function(event) {
    switch(event.data.Action) {
        case "ToggleDot":
            console.log(event.data.Visible);
            $(".dot-container").css("display", event.data.Visible ? "block" : "none");
            break;
    };
});