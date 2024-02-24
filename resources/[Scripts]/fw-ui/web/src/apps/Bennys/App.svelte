<script>
    import { OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils/Utils";
    import { MenuItems } from "./bennys.store";

    import AppWrapper from "../../components/AppWrapper.svelte";
    import BennysItem from "./components/BennysItem.svelte";
    import { onMount } from "svelte";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-bennys")
    };

    const MaxItems = 10;

    let Visible = false;
    let CurrentHovering = 0;

    let CurrentPath = [];
    let FilteredItems = [];

    let Header = 'Welcome to Benny\'s Original Motorworks'
    let SubHeader = 'Choose a Category'

    const GetMenuItems = () => {
        let Retval = $MenuItems;

        for (let i = 0; i < CurrentPath.length; i++) {
            Retval = Retval[CurrentPath[i]].Children;
        };

        return Retval;
    }

    const ProcessKeydown = Event => {
        const CurrentItems = GetMenuItems();

        switch (Event.key) {
            case "ArrowUp": 
                if (CurrentHovering == 0) {
                    CurrentHovering = CurrentItems.length - 1;
                    FilteredItems = CurrentItems.slice(-MaxItems);
                } else {
                    CurrentHovering--;

                    if (FilteredItems[0].Id > CurrentHovering) {
                        FilteredItems = CurrentItems.slice(CurrentHovering, CurrentHovering + MaxItems);
                    };
                };

                SendEvent("Bennys/PlaySoundFrontend", {
                    Name: 'NAV_UP_DOWN',
                    Set: 'HUD_FRONTEND_DEFAULT_SOUNDSET',
                });

                if (CurrentItems[CurrentHovering].Data) {
                    SendEvent("Bennys/PreviewUpgrade", {...CurrentItems[CurrentHovering].Data});
                }

                break;
            case "ArrowDown":
                if (CurrentHovering == CurrentItems.length - 1) {
                    CurrentHovering = 0;
                    FilteredItems = CurrentItems.slice(0, MaxItems);
                } else {
                    CurrentHovering++;

                    if (FilteredItems[FilteredItems.length - 1].Id < CurrentHovering) {
                        FilteredItems.shift();
                        FilteredItems = [...FilteredItems, CurrentItems[CurrentHovering]]
                    };
                };

                SendEvent("Bennys/PlaySoundFrontend", {
                    Name: 'NAV_UP_DOWN',
                    Set: 'HUD_FRONTEND_DEFAULT_SOUNDSET',
                });

                if (CurrentItems[CurrentHovering].Data) {
                    SendEvent("Bennys/PreviewUpgrade", {...CurrentItems[CurrentHovering].Data});
                }

                break;
            case "ArrowLeft":
                if (CurrentPath.length > 0) {
                    CurrentHovering = CurrentPath[CurrentPath.length - 1];
                    CurrentPath.pop();
                    FilteredItems = GetMenuItems().slice(0, MaxItems);
                }
                break;
            case "ArrowRight":
                if (CurrentItems[CurrentHovering].Children && CurrentItems[CurrentHovering].Children.length > 0) {
                    FilteredItems = CurrentItems[CurrentHovering].Children.slice(0, MaxItems);
                    CurrentPath.push(CurrentHovering);
                    CurrentHovering = 0;
                }
                break;
        };
    };

    const ProcessKeyup = Event => {
        const CurrentItems = GetMenuItems();

        switch (Event.key) {
            case "Enter":
                if (CurrentItems[CurrentHovering].Children && CurrentItems[CurrentHovering].Children.length > 0) {
                    FilteredItems = CurrentItems[CurrentHovering].Children.slice(0, MaxItems);
                    CurrentPath.push(CurrentHovering);
                    CurrentHovering = 0;
                } else {
                    if (CurrentItems[CurrentHovering].Data) {
                        SendEvent("Bennys/PurchaseUpgrade", {...CurrentItems[CurrentHovering].Data});
                    }
                };

                SendEvent("Bennys/PlaySoundFrontend", {
                    Name: 'SELECT',
                    Set: 'HUD_FRONTEND_DEFAULT_SOUNDSET',
                });

                break;
            case "Backspace":
                if (CurrentPath.length > 0) {
                    CurrentHovering = CurrentPath[CurrentPath.length - 1];
                    CurrentPath.pop();
                    FilteredItems = GetMenuItems().slice(0, MaxItems);
                } else {
                    SendEvent("Bennys/Close");
                }

                SendEvent("Bennys/PlaySoundFrontend", {
                    Name: 'NAV_UP_DOWN',
                    Set: 'HUD_FRONTEND_DEFAULT_SOUNDSET',
                });
                break;
        };
    };

    onMount(() => {
        document.body.addEventListener("keydown", ProcessKeydown);
        document.body.addEventListener("keyup", ProcessKeyup);

        return () => {
            document.body.removeEventListener("keydown", ProcessKeydown);
            document.body.removeEventListener("keyup", ProcessKeyup);
        };
    });

    OnEvent("Bennys", "SetVisibility", (Data) => {
        Visible = Data.Visibility;
    })

    OnEvent("Bennys", "SetMenu", (Data) => {
        CurrentHovering = 0;
        MenuItems.set(Data.Items);
        FilteredItems = $MenuItems.slice(0, MaxItems);
    })

    OnEvent("Bennys", "SetHeader", (Data) => {
        Header = Data.Header;
        SubHeader = Data.SubHeader;
    })

</script>

<AppWrapper AppName="Bennys" Focused={Visible}>
    {#if Visible}
        <div class="bennys-wrapper">
            <div class="menu-logo" style="background-image: url(./images/bennys.png)"></div>
            <p class="menu-header">{Header}</p>
            <p class="menu-subheader">{SubHeader}</p>

            <div class="bennys-items">
                {#each FilteredItems as Data (Data.Id)}
                    <BennysItem
                        IsSelected={CurrentHovering == Data.Id}
                        {...Data}
                    />
                {/each}
            </div>

            <div class="bennys-navigation">
                <i class="fas fa-sort"></i>
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .bennys-wrapper {
        position: absolute;
        top: 1.3vh;
        left: 1.3vh;

        width: 40vh;
        height: max-content;

        color: rgb(236, 240, 241);
        font-family: Oswald, sans-serif;

        border-radius: 0.5vh;

        background-color: #222831be;
    }

    .menu-logo {
        width: 100%;
        height: 9.85vh;

        background-size: cover;

        border-top-left-radius: .5vh;
        border-top-right-radius: .5vh;
    }

    .menu-header {
        font-weight: 400;
        font-style: oblique;
        text-align: center;
        font-size: 2vh;

        margin: 0;
        padding-top: 0.375vh;

        width: 100%;
        background-color: #191e25be;
    }

    .menu-subheader {
        font-weight: 300;
        font-style: oblique;
        text-align: center;
        font-size: 1.5vh;

        margin: 0;
        padding-bottom: 0.375vh;

        width: 100%;
        background-color: #191e25be;
    }

    .bennys-items {
        font-size: 1.2vh;
        font-style: normal;
        font-weight: 300;

        text-align: left;

        width: 100%;

        height: fit-content;
        max-height: 37.6vh;
    }

    .bennys-navigation {
        width: 100%;
        height: 3.25vh;

        display: flex;
        justify-content: center;
        align-items: center;

        font-size: 2.5vh;

        background-color: #191e25be;
        border-bottom-left-radius: .5vh;
        border-bottom-right-radius: .5vh;
    }
</style>