<script>
    import { onMount } from "svelte"
    import { OnEvent, SendEvent, SetExitHandler } from "../../utils/Utils";

    import MenuItem from "./components/MenuItem.svelte";

    let MenuVisible = false;
    let CurrentItem = 1;
    let CurrentPage = 1;
    let FilteredEmotes = [];
    let Emotes = [];
    let AMOUNT_OF_EMOTES_PER_PAGE = 9;
    let CurrentEmotesCategory = "Default";
    let CurrentCategoryEmotes = [];

    const FilterEmotes = () => {
        const FirstIndex = (CurrentPage - 1) * AMOUNT_OF_EMOTES_PER_PAGE;
        const LastIndex = FirstIndex + AMOUNT_OF_EMOTES_PER_PAGE;
        FilteredEmotes = CurrentCategoryEmotes.slice(FirstIndex, LastIndex);

        if (CurrentItem > FilteredEmotes.length + 1) {
            CurrentItem = FilteredEmotes.length + 3;
        };
    };

    const ProcessKeydown = Event => {
        switch (Event.key) {
            case "ArrowUp": 
                SendEvent("Emotes/PlayNavSound");
                if (CurrentItem - 1 <= 0) {
                    CurrentItem = FilteredEmotes.length + 3;
                    return;
                };

                CurrentItem -= 1;
                break;
            case "ArrowDown":
                SendEvent("Emotes/PlayNavSound");
                if (CurrentItem + 1 > FilteredEmotes.length + 3) {
                    CurrentItem = 1;
                    return
                };

                CurrentItem += 1;
                break;
            case "ArrowLeft":
                SendEvent("Emotes/PlayNavSound");
                if (CurrentPage - 1 <= 0) {
                    CurrentPage = Math.ceil(CurrentCategoryEmotes.length / AMOUNT_OF_EMOTES_PER_PAGE)
                } else {
                    CurrentPage -= 1;
                };

                FilterEmotes()
                break;
            case "ArrowRight":
                SendEvent("Emotes/PlayNavSound");
                if (CurrentPage + 1 > Math.ceil(CurrentCategoryEmotes.length / AMOUNT_OF_EMOTES_PER_PAGE)) {
                    CurrentPage = 1;
                } else {
                    CurrentPage += 1;
                };

                FilterEmotes()
                break;
        };
    };

    const ProcessKeyup = Event => {
        switch (Event.key) {
            case "Enter":
                if (CurrentItem == 0) return;
                if (CurrentItem == 1) return ToggleHelp();
                if (CurrentItem == 2) return CancelEmote();
                if (CurrentItem == 3) {
                    SendEvent("Emotes/PlayConfirmSound");
                    CurrentEmotesCategory = CurrentEmotesCategory == "Default" ? "Shared" : "Default"
                    CurrentCategoryEmotes = Emotes.filter(Val => Val.Data.Category == CurrentEmotesCategory);
                    FilterEmotes();
                    CurrentPage = 1; CurrentItem = 3;
                    return
                };

                PlayEmote(FilteredEmotes[CurrentItem - 4].Name)

                break;
        };
    };

    const CancelEmote = () => {
        SendEvent("Emotes/Cancel")
    }

    const ToggleHelp = () => {
        SendEvent("Emotes/ToggleHelp")
    }
    
    const PlayEmote = Emote => {
        SendEvent("Emotes/PlayEmote", {Emote})
    };

    OnEvent("SetMenuVisibility", (Data) => {
        MenuVisible = Data.Visible;
    });

    OnEvent("Emotes/SetEmotes", (Data) => {
        for (var Key in Data.Emotes) {
            if (Data.Emotes.hasOwnProperty(Key) && !Data.Emotes[Key].Hidden) {
                Emotes.push({
                    Name: Key,
                    Data: Data.Emotes[Key]
                });
            }
        }

        Emotes.sort((a, b) => a.Name.localeCompare(b.Name));
        CurrentCategoryEmotes = Emotes.filter(Val => Val.Data.Category == CurrentEmotesCategory);
        FilterEmotes();
    });

    SetExitHandler("", "Emotes/Close", () => MenuVisible)

    onMount(() => {
        document.body.addEventListener("keydown", ProcessKeydown);
        document.body.addEventListener("keyup", ProcessKeyup);

        return () => {
            document.body.removeEventListener("keydown", ProcessKeydown);
            document.body.removeEventListener("keyup", ProcessKeyup);
        };
    });

</script>

{#if MenuVisible}
    <div class="menu-wrapper">
        <div class="menu-header">
            <p>Animaties</p>
        </div>
        <div class="menu-current">
            <p>Emotes List</p>
        </div>

        <div class="menu-items">
            <MenuItem
                Text={["Pagina", `${CurrentPage}/${Math.ceil(CurrentCategoryEmotes.length / AMOUNT_OF_EMOTES_PER_PAGE)}`]}
                Special={true}
            />
            <MenuItem
                Text={["Toggle Help"]}
                Special={true}
                Selected={CurrentItem == 1}
            />
            <MenuItem
                Text={["Stop Emote"]}
                Special={true}
                Selected={CurrentItem == 2}
            />

            <MenuItem
                Text={[ CurrentEmotesCategory == "Default" ? "Gedeelde Animaties" : "Normale Animaties"]}
                Special={true}
                Selected={CurrentItem == 3}
            />

            {#each FilteredEmotes as Data, Key}
                <MenuItem
                    Text={[Data.Name]}
                    Special={Data.Special}
                    Selected={CurrentItem == Key + 4}
                />
            {/each}
        </div>
    </div>
{/if}

<style>
    .menu-wrapper {
        position: absolute;
        top: 1.7vh;
        right: 10.65vh;

        width: 40.96vh;
        height: max-content;
        max-height: 40.3vh;

        user-select: none;
    }

    .menu-header {
        width: 100%;
        height: 6.1vh;

        display: flex;
        justify-content: center;
        align-content: center;

        background-color: rgba(0, 0, 0, 0.6);
    }

    .menu-header > p {
        font-family: SignPainter;
        font-size: 5.5vh;
        color: rgb(93, 182, 229);
    }

    .menu-current {
        display: flex;
        align-items: center;

        width: 100%;
        height: 2.8vh;

        background-color: black;
    }

    .menu-current > p {
        font-family: Helvetica;
        font-size: 1.5vh;

        text-transform: uppercase;
        color: rgb(240, 240, 240);

        padding-left: 1vh;
    }
</style>