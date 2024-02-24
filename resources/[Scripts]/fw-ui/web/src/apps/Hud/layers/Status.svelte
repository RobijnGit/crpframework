<script>
    import { OnEvent } from "../../../utils/Utils";
    import { MyPreferences } from "../../Preferences/preferences.store.js";
    import Circle from "../components/Circle.svelte";

    // Status
    const HudSettings = [ "Health", "Armor", "Food", "Water" ];
    let HudComponents = [];
    let IsHudVisible = true;

    MyPreferences.subscribe(() => {
        HudComponents = HudComponents;
    });

    const ShowHudComponent = (Data) => {
        if (Data.IsEnhancement && !$MyPreferences['Status.ShowBuffs']) return false;

        // Did we disable the hud, or is the hud value beyond the hide value?
        if (HudSettings.includes(Data.Id)) {
            if (!$MyPreferences[`Status.Show${Data.Id}`]) return false;
            if (Data.Value > $MyPreferences[`Status.${Data.Id}Value`]) return false;

            if ($MyPreferences[`Status.${Data.Id}Value`] >= 100) return true;
        };

        if (Data.Id == "Stress" && !$MyPreferences[`Status.ShowStress`]) return false;
        if (Data.Id == "Oxygen" && !$MyPreferences[`Status.ShowOxygen`]) return false;

        return Data.Show;
    };

    OnEvent("Hud", "SetHudComponents", (Data) => {
        HudComponents = Data;
    });

    OnEvent("Hud", "SetVisibility", (Data) => {
        IsHudVisible = Data;
    });

    OnEvent("Hud", "SetHudData", (Data) => {
        const HudIndex = HudComponents.findIndex(Val => Val.Id == Data.Id);
        if (HudIndex > -1) HudComponents[HudIndex] = Data;
    });
</script>

{#if IsHudVisible && !$MyPreferences['BlackBars.Show']}
    <div class="hud-wrapper">
        {#each HudComponents as Data (Data.Id)}
            {#if ShowHudComponent(Data)}
                <Circle
                    Icon={Data.Icon}
                    Value={Data.Value}
                    Color={Data.Color}
                    Buffed={Data.IsEnhancement || Data.Buffed}
                    Danger={Data.ShowDanger}
                    Text={Data.InsideText}
                />
            {/if}
        {/each}
    </div>
{/if}

<style>
    .hud-wrapper {
        display: flex;
        position: absolute;
        left: .2vh;
        bottom: .2vh;
    }
</style>