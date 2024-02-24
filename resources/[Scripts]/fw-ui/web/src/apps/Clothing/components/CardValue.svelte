<script>
    import Ripple from "@smui/ripple";
    import { AsyncSendEvent, SendEvent as _SendEvent } from "../../../utils";
    import { ClothingPrice, ComponentsValues, CurrentSkin } from "../clothing.store";
    import { onMount } from "svelte";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };

    export let componentId = "Hair";
    export let valueType = "Drawable";
    export let minValue = 0;
    export let value = 0;
    export let ignoreAutoValue = false;

    onMount(() => {
        if (ignoreAutoValue) return;

        const valueId = valueType == "Drawable" ? 0 : 1
        value = valueType != "Layer" ? $CurrentSkin[componentId][valueId] : 0;

        if (valueType == "Texture") {
            CurrentSkin.subscribe((NewValue) => {
                value = NewValue[componentId][1]
            });
        };
    });

    let maxValue = (valueType == "Drawable" ? $ComponentsValues[componentId].MaxComps : $ComponentsValues[componentId].MaxTxts) || 0;
    ComponentsValues.subscribe((newValues) => {
        maxValue = (valueType == "Drawable" ? newValues[componentId].MaxComps : newValues[componentId].MaxTxts) || 0;
    });

    const ValidateValue = async (overwriteValue) => {
        let newValue = overwriteValue != undefined ? overwriteValue : value;

        if (newValue > maxValue) {
            value = minValue;
            newValue = minValue;
        };

        if (newValue < minValue) {
            value = maxValue;
            newValue = maxValue;
        };

        SendEvent("Clothing/ProcessComponentChange", { componentId, value: newValue, type: valueType }, async (Success, Result) => {
            if (!Success || !Result.Success) return;
            if (valueType == "Layer") return;

            if (Result.Values != undefined) $ComponentsValues[componentId] = Result.Values;
            $CurrentSkin[componentId][valueType == "Drawable" ? 0 : 1] = value;
            if (valueType == "Drawable") {
                $CurrentSkin[componentId][1] = 0;
            };

            if (valueType == "Drawable") {
                const [Success, NewPrice] = await AsyncSendEvent("Clothing", "GetClothesPrice", {__resource: "fw-clothes"});
                if (Success) ClothingPrice.set(NewPrice);
            };
        });
    };

</script>

<div class="card-value-container">

    <div
        use:Ripple={{ surface: true, active: true }}
        class="card-value-button minus"
        on:keyup on:click={() => { value -= 1; ValidateValue() } }
    >&lt;</div>

    <input
        class="card-value-number"
        type="number"
        min={minValue}
        max={maxValue}
        on:input={(element) => { ValidateValue(Number(element.target.value)) }}
        bind:value
    />

    <div
        use:Ripple={{ surface: true, active: true }}
        class="card-value-button plus"
        on:keyup on:click={() => { value += 1; ValidateValue() } }
    >&gt;</div>

</div>

<style>
    .card-value-container {
        display: flex;
        width: 48.5%;
        height: 3.4vh;
    }

    .card-value-button.minus {
        border-top-left-radius: .3vh;
        border-bottom-left-radius: .3vh;
    }

    .card-value-button.plus {
        border-top-right-radius: .3vh;
        border-bottom-right-radius: .3vh;
    }

    .card-value-button {
        display: flex;
        justify-content: center;
        align-items: center;

        width: 3.4vh;
        height: 3.4vh;

        font-size: 1.4vh;
        font-weight: 500;

        color: black;
        background-color: #dfdfdf;
        cursor: pointer;
    }

    .card-value-number {
        border: none;
        outline: none;
        background: transparent;

        width: calc(100% - 6.8vh);
        height: 3.35vh;

        font-size: 1.7vh;
        font-weight: 500;
        color: white;
        text-align: center;

        border-bottom: 0.15vh solid #dfdfdf;
    }

    .card-value-number::-webkit-outer-spin-button,
    .card-value-number::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }
</style>