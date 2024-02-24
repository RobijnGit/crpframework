<script>
    import { tick } from 'svelte';

    import Button from "../../lib/Button/Button.svelte";
    import Checkbox from "../../lib/Checkbox/Checkbox.svelte";
    import TextField from "../../lib/TextField/TextField.svelte";
    import { OnEvent, SendEvent, SetExitHandler } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let ShowInput = false;
    let Inputs = [];
    let Values = {};

    OnEvent("Input", "Build", (Data) => {
        ShowInput = true;
        Inputs = Data;
        Values = {};

        for (let i = 0; i < Inputs.length; i++) {
            const Element = Inputs[i];
            Element.OrgLabel = Element.Label;
            Values[Element.Name] = Element.Value || ""

            if (Element.ShowLength) {
                Element.Label = `${Element.OrgLabel} (${Element.MaxLength} karakters)`
            }

            if (!Element.Sub) {
                Element.Sub = '';
            }
        };
    });

    OnEvent("Input", "Hide", (Data) => {
        ShowInput = false;
        Inputs = [];
    });

    const OnCancel = () => {
        SendEvent("Input/OnButtonClick", {
            Button: "Cancel",
            Result: Values,
        });
    };

    const OnSubmit = () => {
        SendEvent("Input/OnButtonClick", {
            Button: "Submit",
            Result: Values,
        })
    };

    SetExitHandler("", "Input/Close", () => ShowInput, {})

    // Image List Handlers
    let ImageHandlerRefs = {};

    const AreImagesApproxSameSize = (ImageOne, ImageTwo) => {
        const DiffRatioW = Math.abs(ImageOne.naturalWidth / ImageTwo.naturalWidth);
        const DiffRatioH = Math.abs(ImageOne.naturalHeight / ImageTwo.naturalHeight);
        return DiffRatioW < 1.1 && DiffRatioW > 0.9 && DiffRatioH < 1.1 && DiffRatioH > 0.9;
    };

    const GetImageMeta = (Url) => {
        return new Promise((res, rej) => {
            let img = new Image();
            img.onload = () => res(img);
            img.onerror = () => rej(error);
            img.src = Url;
        });
    };

    const AddUrl = async (Data, Id) => {
        if (Data._urlValue.trim().length == 0) return;

        const Image = await GetImageMeta(Data._urlValue);
        if (Data._MinWidth && Image.naturalWidth < Data._MinWidth) {
            Inputs[Id].Sub = `Je pagina's moeten minstens ${Data._MinWidth}x${Data._MinHeight} zijn!`
            return;
        };

        if (Data._MinHeight && Image.naturalHeight < Data._MinHeight) {
            Inputs[Id].Sub = `Je pagina's moeten minstens ${Data._MinWidth}x${Data._MinHeight} zijn!`
            return;
        };

        if (Values[Data.Name] && Values[Data.Name].length > 0 && !AreImagesApproxSameSize(await GetImageMeta(Values[Data.Name][0]), Image)) {
            Inputs[Id].Sub = `Je pagina's moeten allemaal ongeveer even groot zijn!`
            return;
        };

        Inputs[Id].Sub = "";

        Values[Data.Name] = [...Values[Data.Name], Image.src];

        // Wait for the next tick, on next tick the image is added onto the dom.
        await tick();

        ImageHandlerRefs[Data.Name].scroll({
            top:ImageHandlerRefs[Data.Name].scrollHeight,
            behavior: "smooth"
        })
    };
</script>

<AppWrapper AppName="Input" Focused={ShowInput}>
    {#if ShowInput}
        <div class="input-container">

            {#each Inputs as Data, Id}
                {#if Data._Type == "ImageList"}
                    <div style="display: flex; width: 100%;">
                        <TextField
                            Title={Data.Label}
                            Sub={Data.Sub}
                            IsSubError={true}
                            Icon={Data.Icon}
                            Type={Data.Type}
                            Select={Data.Choices}
                            SearchSelect={Data.SearchSelect}
                            MaxLength={Data.MaxLength || 999}
                            SubSet={(Value) => {
                                if (Data.ShowLength) {
                                    Data.Label = `${Data.OrgLabel} (${Data.MaxLength - Value.length} karakters)`
                                }
    
                                return '';
                            }}
                            bind:Value={Data._urlValue}
                            style="width: 87.3%"
                        >
                            <div class="imagelist-container" bind:this={ImageHandlerRefs[Data.Name]}>
                                {#each Values[Data.Name] as Img, Key}
                                    <div style="display: flex; width: 100%; justify-content: space-between">
                                        <img src={Img} alt="page">
                                        <Button
                                            Color="warning"
                                            style="margin-right: 0; width: 1vh; text-align: center;"
                                            on:click={() => {
                                                Values[Data.Name].splice(Key, 1);
                                                Values[Data.Name] = [...Values[Data.Name]];
                                            }}
                                        >-</Button>
                                    </div>
                                {/each}
                            </div>
                        </TextField>

                        <Button
                            Color="success"
                            style="margin-right: 0; width: 1vh; text-align: center; margin-top: auto; margin-bottom: {Data.Sub ? 3 : 1.5}vh;"
                            on:click={() => AddUrl(Data, Id)}
                        >+</Button>
                    </div>
                {:else if Data._Type == "Checkbox"}
                    <Checkbox
                        Label={Data.Label}
                        bind:Checked={Values[Data.Name]}
                    />
                {:else}
                    <TextField
                        Title={Data.Label}
                        Sub={Data.Sub}
                        Icon={Data.Icon}
                        Type={Data.Type}
                        Select={Data.Choices}
                        SearchSelect={Data.SearchSelect}
                        MaxLength={Data.MaxLength || 999}
                        SubSet={(Value) => {
                            if (Data.ShowLength) {
                                Data.Label = `${Data.OrgLabel} (${Data.MaxLength - Value.length} karakters)`
                            }

                            return '';
                        }}
                        bind:Value={Values[Data.Name]}
                    />
                {/if}
            {/each}


            <div class="input-buttons">
                <!-- <Button
                    Color="warning"
                    on:click={OnCancel}
                >Annuleren</Button> -->
                <Button
                    Color="success"
                    on:click={OnSubmit}
                >Bevestigen</Button>
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .input-container {
        position: absolute;
        top: 50%;
        left: 50%;

        transform: translate(-50%, -50%);

        width: 30vh;
        height: max-content;
        min-height: 10.4vh;
        max-height: 70vh;

        overflow-y: auto;
        overflow-x: hidden;

        padding: 1.5vh;

        background-color: #222831;
    }

    .imagelist-container::-webkit-scrollbar,
    .input-container::-webkit-scrollbar {
        display: none;
    }

    .imagelist-container {
        margin: .5vh 0;
        max-height: 35.5vh;

        overflow-y: auto;
        overflow-x: hidden;

        display: flex;
        flex-direction: column;
        gap: .8vh;

        width: 112.7%;
    }

    .imagelist-container img {
        max-width: 70%;
        height: auto;
    }

    .input-buttons {
        margin: 1vh auto 0 auto;
        width: max-content;
    }
</style>
