<script>
    import { fade } from "svelte/transition";
    import { OnEvent, SendEvent, SetExitHandler } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let FullMenuData = {};
    let InContext = false;
    let WidthOverride = false;
    let ContextItems = [];

    OnEvent("Context", "ShowContext", (Data) => {
        InContext = true;
        ContextItems = Data.MainMenuItems;
        WidthOverride = Data.Width;
        FullMenuData = Data;
    });

    OnEvent("Context", "CloseContext", (Data) => {
        if (Data.Force && FullMenuData.CloseEvent) {
            SendEvent("Context/ProcessClick", { ContextItem: FullMenuData.CloseEvent })
        };

        InContext = false;
        ContextItems = [];
        FullMenuData = {};
        WidthOverride = false;
    });

    SetExitHandler("", "Context/Close", () => InContext, {Force: true})

    const OnContextClick = (Data) => {
        if (Data.Disabled) return;

        if (Data.SecondMenu) {
            ContextItems = [
                {
                    Title: "Terug",
                    GoBack: true,
                },
                ...Data.SecondMenu
            ];
        } else if (Data.GoBack) {
            ContextItems = FullMenuData.MainMenuItems

            if (FullMenuData.ReturnEvent) {
                SendEvent("Context/ProcessClick", { ContextItem: FullMenuData.ReturnEvent })
            };
        };

        if (!Data.Data) return;
        SendEvent("Context/ProcessClick", { ContextItem: Data.Data })

        if (!Data.SecondMenu && Data.CloseMenu != false) {
            SendEvent("Context/Close", {})
        };
    }
</script>

<AppWrapper AppName="Context" Focused={InContext}>
    {#if InContext}
        <div
            class="context-wrapper"
            transition:fade={{duration: 250}}
            style="width: {WidthOverride ? WidthOverride : "16.5vw"}"
        >
            {#each ContextItems as Data, Id}
                <div
                    on:keyup on:click={() => {
                        OnContextClick(Data);
                    }}
                    class="context-item"
                    class:context-disabled={Data.Disabled}
                >
                    {#if Data.Icon}
                        <div class="context-item-icon">
                            <i class="fas fa-{Data.Icon}"/>
                        </div>
                    {/if}

                    <div class="context-item-text">
                        <div style="width: 100%;">
                            <p style="display: inline;">
                                {#if Data.Title == 'Terug' && !Data.Icon}
                                    <i class="fas fa-chevron-left" style="margin-right: .6vh;"></i>
                                {/if}
                                {@html Data.Title}
                            </p>
                            {#if Data.Desc}
                                <p class="context-item-desc" style="word-break: break-word;">{@html Data.Desc}</p>
                            {/if}
                        </div>
                    </div>

                    {#if Data.SecondMenu && Data.SecondMenu.length > 0}
                        <div class="context-item-subicon">
                            <i class="fas fa-chevron-right"/>
                        </div>
                    {/if}
                </div>
            {/each}
        </div>
    {/if}
</AppWrapper>

<style>
    .context-wrapper {
        user-select: none;

        position: absolute;
        top: 20.75vh;
        left: 56.25vw;

        width: 16.5vw;
        height: 70vh;
        overflow-y: auto;
    }

    .context-wrapper::-webkit-scrollbar { display: none; }

    .context-wrapper > .context-item:hover { background-color: #30475e; }
    .context-wrapper > .context-item.context-disabled { background-color: rgb(143, 143, 143) !important; cursor: not-allowed; }

    .context-wrapper > .context-item {
        opacity: 1.0;
        transition: opacity 225ms cubic-bezier(0.4, 0, 0.2, 1) 0ms;

        display: flex;

        position: relative;
        left: 0;
        right: 0;
        
        cursor: pointer;

        overflow: hidden;

        width: 90%;
        height: fit-content;

        padding: .8vh;

        margin: 0 auto;
        margin-top: 0.5vh;
        
        border-radius: .4vh;
        background-color: #222831; 
        box-shadow: 0 0 0.5vh 0vh black;
    }

    .context-wrapper > .context-item > .context-item-icon {
        margin: auto 0;
        width: 10%;
        height: 100%;

        position: relative;
        left: -0.8vh;

        padding-left: 0.8vh;

        text-align: center;
        color: white;

        font-size: 1.6vh;
    }

    .context-wrapper > .context-item > .context-item-text {
        width: 100%;
        margin: 0;
        padding: 0;
    }

    .context-wrapper > .context-item > .context-item-text p {
        margin: 0;
        
        font-size: 1.6vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.5;
        letter-spacing: 0.0015008vh;
        
        color: #fff;
    }

    .context-wrapper > .context-item > .context-item-text .context-item-desc {
        font-size: 1.3vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.0017136vh;
    }

    .context-wrapper > .context-item > .context-item-subicon {
        clear: both;

        margin: auto 0;
        margin-left: auto;
        margin-right: .4vh;

        height: 100%;

        color: white;
        font-size: 1.6vh;
    }
</style>