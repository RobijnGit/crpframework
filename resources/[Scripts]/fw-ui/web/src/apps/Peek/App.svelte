<script lang="ts">
    import { OnEvent, SendEvent, SetExitHandler } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    interface PeekEntry {
        Name: string;
        Label: string;
        Icon: string;
        Parent: string;
    }  

    let PeekVisible: boolean = false;
    let PeekEntries: PeekEntry[] = [];

    OnEvent("Peek", "SetVisibility", (Data: {Visible: boolean}) => {
        PeekVisible = Data.Visible;
        PeekEntries = [];
    });

    OnEvent("Peek", "SetEntries", (Data: {Entries: PeekEntry[]}) => {
        PeekEntries = Data.Entries;
    });

    const PeekAction = ({Parent, Name}: PeekEntry) => {
        SendEvent("Peek/Click", { Parent, Name });
        PeekEntries = [];
    };

    SetExitHandler("", "Peek/Close", () => PeekVisible, {});
</script>

<AppWrapper AppName="Peek" Focused={PeekVisible}>
    {#if PeekVisible}
        <div class="eye-wrapper">
            {#if PeekEntries.length == 0}
                <img class="eye-img" src="./images/eye.png" alt="" />
            {:else}
                <img class="eye-img" src="./images/eye-on.png" alt="" />
            {/if}
    
            <div class="eye-options">
                {#each PeekEntries as Data, Id}
                    <div class="option" on:keyup on:click={() => { PeekAction(Data); }}>
                        <i class={Data.Icon || 'fas fa-circle'}></i>
                        {Data.Label}
                    </div>
                {/each}
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .eye-wrapper {
        user-select: none;

        position: absolute;
        top: 0;
        left: 0;

        width: 100vw;
        height: 100vh;
    }

    .eye-img {
        position: absolute;
        top: 50%;
        left: 50%;

        transform: translate(-50%, -50%);

        width: 4.5vh;
        height: 4.5vh;
    }

    .eye-options {
        position: absolute;
        top: 51.6vh;
        left: 48.8vw;
    }

    .eye-options > .option {
        cursor: pointer;
        margin-bottom: 0.45vh;

        font-size: 1.9vh;
        font-style: normal;
        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        font-variant: small-caps;

        color: white;
        letter-spacing: 0px;
        text-transform: none;
        text-decoration: none;

        text-shadow: rgb(55 71 79) -0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh -0.1vh 0, rgb(55 71 79) -0.1vh -0.1vh 0;
    }

    .eye-options > .option:hover {
        color: rgb(0, 248, 185);
    }

    .eye-options > .option > i {
        filter: drop-shadow(black 0.2vh 0.2vh 0.2vh);
        color: rgb(0, 248, 185);
        text-align: center;
        width: 2vh;
        margin-right: 0.4vh;
    }
</style>
