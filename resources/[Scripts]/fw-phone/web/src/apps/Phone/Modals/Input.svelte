<script>
    import Button from "../../../components/Button/Button.svelte";
    import TextArea from "../../../components/TextArea/TextArea.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import Checkbox from "../../../components/Checkbox/Checkbox.svelte";
    import { InputModal } from "../phone.stores";
    import { FormatCurrency, FormatPhone } from "../../../utils/Utils";

    let InputValues = {};

    const Buttons = $InputModal.Buttons || [
        {
            Color: "warning",
            Text: "Terug",
            Cb: (Result) => {
                if ($InputModal.OnCancel) $InputModal.OnCancel(Result);
            },
        },
        {
            Color: "success",
            Text: "Bevestigen",
            Cb: (Result) => {
                if ($InputModal.OnSubmit) $InputModal.OnSubmit(Result);
            },
        },
    ];

    const Inputs = $InputModal.Inputs || [
        {
            Type: "Text",
            Text: "No inputs defined.",
            Data: {
                style: "text-align: center; margin-bottom: 1vh; font-size: 1.5vh;"
            }
        }
    ];

    const SubmitInput = Data => {
        Data.Cb(InputValues);
        InputModal.set({Visible: false});
    };

    // Set InputValues default values.
    // Because its binded it will already set it.
    // Just to be sure tho, in case if it breaks or it doesn't work how I want it we can enable this.
    // onMount(() => {
    //     for (let i = 0; i < $InputModal.Inputs.length; i++) {
    //         const Data = $InputModal.Inputs[i];
    //         if (Data.Data.Value || Data.Data.Checked) {
    //             InputValues[Data.Id] = Data.Data.Value || Data.Data.Checked;
    //         };
    //     };
    // });

</script>

<div class="phone-input-wrapper">
    <div class="phone-input-container">
        {#each Inputs as Data, Id}
            {#if Data.Type == "Text"}
                <p {...Data.Data}>{Data.Text}</p>
            {:else if Data.Type == "TextField"}
                <TextField
                    {...Data.Data}
                    bind:Value={InputValues[Data.Id]}
                    SubSet={(Val) => {
                        // InputValues[Data.Id] = Val;
                        // I put it here, probs for a reason - but value is bound so this shouldn't be needed.
                        // Either way; this will break some things because 'Val' is the shown value.
                        // Dropdowns may have a different value than shown, e.g the networks.
                        // Uncommented it when I was working on the networks, we will find out soon enough if this breaks shit. lmfao

                        if (Data.IsPhone) {
                            if (Val.length == 0) return " ";
                            return FormatPhone(Val);
                        };
                        
                        if (Data.IsCurrency) {
                            if (Val.length == 0) return "€ 0,00";
                            return FormatCurrency.format(Val);
                        };

                        const SubSetValue = Data.Data.SubSet ? Data.Data.SubSet(Val) : "";

                        for (let i = 0; i < Inputs.length; i++) {
                            if (Inputs[i].OnChange) InputValues[Inputs[i].Id] = Inputs[i].OnChange(Data.Id, Val, Inputs[i]);
                        };

                        return SubSetValue;
                    }}
                />
            {:else if Data.Type == "TextArea"}
                <TextArea {...Data.Data} bind:Value={InputValues[Data.Id]} />
            {:else if Data.Type == "Checkbox"}
                <Checkbox {...Data.Data} bind:Checked={InputValues[Data.Id]} />
            {/if}
        {/each}

        <div class="phone-input-buttons" style="{Buttons.length < 2 ? "justify-content: space-around;" : ""}">
            {#each Buttons as Data, Id}
                <Button Color={Data.Color} on:click={() => { SubmitInput(Data) }}>{Data.Text}</Button>
            {/each}
        </div>
    </div>
</div>

<style>
    .phone-input-wrapper {
        position: absolute;
        width: 100%;
        height: 100%;
        z-index: 100;
        background-color: rgba(0, 0, 0, 0.5);
    }

    .phone-input-container {
        position: relative;
        top: 50%;
        left: 0;
        right: 0;
        transform: translateY(-50%);
        clear: both;
        overflow-y: auto;
        margin: 0 auto;
        width: 66%;
        height: max-content;
        max-height: 70%;
        padding: 1.5vh;
        background-color: #30475d;
    }

    .phone-input-container::-webkit-scrollbar {
        display: none;
    }

    .phone-input-container > .phone-input-buttons {
        display: flex;
        justify-content: space-between;
        height: 4vh;
        width: 100%;
    }
</style>
