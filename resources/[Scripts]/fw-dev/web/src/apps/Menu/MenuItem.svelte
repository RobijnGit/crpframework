<script>
    import Ripple from '@smui/ripple';

    import TextField from "../../components/TextField/TextField.svelte";
    import Checkbox from "../../components/Checkbox/Checkbox.svelte";
    import Button from "../../components/Button/Button.svelte";
    import { SendEvent } from "../../utils/Utils";

    export let Id = 'Unspecified';
    export let Title = 'Damage Entity';
    export let Options = [];
    // {
    //     Type: "Text",
    //     Text: "Please select a seat."
    // },
    // {
    //     Id: "Amount",
    //     Type: "TextField",
    //     Data: {
    //         Title: "Seat Index (-1 to 16)",
    //         Icon: false,
    //         Type: "number",
    //     },
    // },

    let IsCompact = true;
    let InputValues = {};

    const ButtonClick = () => {
        if (!Options || Options.length == 0) {
            SendEvent("Menu/ProcessAction", { Id })
            return;
        };

        IsCompact = !IsCompact;
    };

    const Execute = () => {
        SendEvent("Menu/ProcessAction", { Id, Result: InputValues });
    }
</script>

<div class="menu-item-wrapper">
    <div class="item-header" on:keyup on:click={ButtonClick} use:Ripple={{ surface: true, active: true }}>
        <p class="title">{Title}</p>
        {#if !Options || Options.length == 0}
            <i class="fas fa-chevron-right"></i>
        {:else}
            <i class="fas fa-chevron-down"></i>
        {/if}
    </div>

    {#if !IsCompact}
        <div class="item-options-wrapper">
            <div class="item-options">
                {#each Options as Data, Key}
                    {#if Data.Type == "Text"}
                        <p {...Data.Data}>{Data.Text}</p>
                    {:else if Data.Type == "TextField"}
                        <TextField
                            {...Data.Data}
                            bind:Value={InputValues[Data.Id]}
                        />
                    {:else if Data.Type == "Checkbox"}
                        <Checkbox
                            {...Data.Data}
                            bind:Checked={InputValues[Data.Id]}
                        />
                    {/if}
                {/each}

                <Button on:click={Execute} Color="success" style="float: unset; background-color: white; border-radius: 0; padding: .8vh 1.3vh; margin: 0; margin-bottom: 0.5vh;">{Title}</Button>
            </div>
        </div>
    {/if}
</div>

<style lang="scss">
    .menu-item-wrapper {
        width: 100%;
        min-height: 3vh;
        height: max-content;

        border-radius: 0.1vh;

        background-color: white;
        margin-bottom: .2vh;

        .item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;

            height: 3vh;
            width: calc(100% - 3vh);

            padding: 0 1.5vh;

            font-size: 1vh;
            font-family: Roboto;
            color: black;

            &:hover {
                background-color: rgba(90, 90, 90, 0.8);
            }
        }

        .item-options-wrapper {
            width: 100%;
            height: 100%;

            background-color: #222831;

            .item-options {
                width: calc(100% - 2vh);
                margin: 0 auto;
                padding: .5vh 0;
            }
        }

    }
</style>