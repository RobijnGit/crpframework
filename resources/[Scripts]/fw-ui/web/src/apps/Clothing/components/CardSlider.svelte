<script>
    import Slider from '@smui/slider';
    import { onMount, tick } from 'svelte';
    import { CurrentSkin } from '../clothing.store';
    import { SendEvent as _SendEvent } from '../../../utils';

    export let minValue = 0;
    export let maxValue = 100;
    export let step = 1;
    export let value = 0;
    export let label = "";

    export let componentId = undefined;
    export let valueId = undefined;

    let loaded = false;

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };

    onMount(async () => {
        if (componentId == undefined) return;

        if (valueId == undefined) {
            value = $CurrentSkin[componentId];
        } else {
            value = $CurrentSkin[componentId][valueId];
        };

        await tick();
        loaded = true;
    });

    const ProcessSliderChange = async () => {
        if (!loaded) return;
        await tick();

        let currentSkinValue;
        if (valueId == undefined) {
            currentSkinValue = $CurrentSkin[componentId];
        } else {
            currentSkinValue = $CurrentSkin[componentId][valueId];
        };

        if (value == currentSkinValue) return;

        SendEvent("Clothing/ProcessSliderChange", { componentId, valueId, value }, (Success, Result) => {
            if (!Success || !Result.Succes) return;

            if (valueId == undefined) {
                $CurrentSkin[componentId] = value;
            } else {
                $CurrentSkin[componentId][valueId] = value;
            };
        });
    };

    $: value, (ProcessSliderChange)();
</script>

<div class="card-value-container" {...$$restProps}>
    <p>{label}</p>
    <div style="width: 100%; display: flex; justify-content: center;">
        <Slider
            min={minValue}
            max={maxValue}
            step={step}
            discrete
            bind:value={value}
            style="width: 100%;"
        />
    </div>
</div>

<style>
    .card-value-container {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-content: center;

        width: auto;
        height: fit-content;
    }

    .card-value-container p {
        margin-left: 1vh;
        margin-bottom: -.5vh;
        font-size: 1.25vh;
        font-weight: 400;
        color: white;
        width: calc(100% - 2vh);
    }
</style>