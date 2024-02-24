<script>
    import { PlayerData } from "../../stores";
    import { DispatchAlerts, DispatchCalls, DispatchUnits } from "./dispatch.store";

    import DispatchMap from "./components/DispatchMap.svelte";
    import DispatchCall from "./components/DispatchCall.svelte";
    import DispatchUnitsList from "./components/DispatchUnitsList.svelte";

    import AppWrapper from "../../components/AppWrapper.svelte";
    import Button from "../../lib/Button/Button.svelte";
    import { OnEvent, SetExitHandler } from "../../utils/Utils";

    let DispatchVisible = false;
    let MapVisible = false;
    let RecentAlerts = [];
    let ShowingAlertsAmount = 100;

    OnEvent("Dispatch", "SetVisibility", Data => {
        DispatchVisible = Data.Show;
        MapVisible = DispatchVisible && !Data.Compact;
        ShowingAlertsAmount = 100;

        if (Data.Show) {
            for (let i = 0; i < RecentAlerts.length; i++) {
                const Alert = RecentAlerts[i];
                Alert.Animation = false;
            };
        };
    });

    OnEvent("Dispatch", "SetUnits", Data => {
        DispatchUnits.set(Data);
    });

    OnEvent("Dispatch", "SetAlerts", Data => {
        DispatchAlerts.set(Data.Alerts);
        DispatchCalls.set(Data.Calls);
    });

    OnEvent("Dispatch", "AddAlert", Data => {
        DispatchAlerts.set([...$DispatchAlerts, {...Data}]);

        Data.Animation = 'in';
        RecentAlerts = [...RecentAlerts, Data];
        setTimeout(() => {
            let AlertId = RecentAlerts.findIndex(Val => Val.Id == Data.Id);
            RecentAlerts[AlertId].Animation = 'out';

            setTimeout(() => {
                let AlertId = RecentAlerts.findIndex(Val => Val.Id == Data.Id);
                RecentAlerts.splice(AlertId, 1);
            }, 300);
        }, 5000);
    });

    SetExitHandler("", "Mdw/Close", () => DispatchVisible, {__resource: "fw-mdw"});
</script>

<AppWrapper AppName="Dispatch" Focused={DispatchVisible}>
    <div class="dispatch-wrapper" style="pointer-events: {DispatchVisible ? "unset" : "none"}">
        <DispatchMap
            bind:Visible={MapVisible}
        />

        <!-- Recent Pings -->
        {#if !DispatchVisible}
            <div class="dispatch-alerts">
                {#each [...RecentAlerts].reverse() as Data (Data.Id)}
                    <DispatchCall {...Data} Id={Data.Id} />
                {/each}
            </div>
        {:else}
            <!-- Active Pings -->
            <div class="dispatch-active-calls">
                {#each [...$DispatchCalls].reverse() as Data (Data.Id)}
                    <DispatchCall {...Data} Id={Data.Id} Color="Active" />
                {/each}
            </div>

            <div class="dispatch-alerts">
                {#each [...$DispatchAlerts].reverse().slice(0, ShowingAlertsAmount) as Data (Data.Id)}
                    <DispatchCall {...Data} Id={Data.Id} />
                {/each}

                {#if $DispatchAlerts.length > 30 && $DispatchAlerts[ShowingAlertsAmount + 1] != undefined}
                    <div style="width: 100%; display: flex; justify-content: center;">
                        <Button
                            on:click={() => { ShowingAlertsAmount = ShowingAlertsAmount + 100 }}
                            Color="success"
                        >Laad Meer</Button>
                    </div>
                {/if}
            </div>

            <div class="dispatch-units">
                <div class="dispatch-units-container">
                    <div style="width: 49.5%; height: 100%; overflow-y: auto;" class="dispatch-container-units-left">
                        <DispatchUnitsList Job='Police' Label="Politie" Units={[...$DispatchUnits['Police']]} style="width: 100%; height: max-content; overflow: unset;" />
                        <DispatchUnitsList Job='DOC' Label="DOC" Units={[...$DispatchUnits['DOC']]} style="width: 100%; height: max-content; overflow: unset;" />
                    </div>
                    <DispatchUnitsList Job='EMS' Label="Ambulance" Units={[...$DispatchUnits['EMS']]} />
                </div> 
            </div>
        {/if}
    </div>
</AppWrapper>

<style>
    .dispatch-wrapper {
        position: absolute;
        top: 0;
        left: 0;

        width: 100vw;
        height: 100vh;
    }

    .dispatch-active-calls,
    .dispatch-alerts {
        position: absolute;
        top: 1.4vh;
        right: 1.4vh;

        width: 44vh;
        height: 68vh;

        overflow-y: auto
    }

    .dispatch-active-calls {
        right: 46.8vh;
        width: 40.5vh;
        height: calc(100vh - 2.8vh)
    }

    .dispatch-active-calls::-webkit-scrollbar,
    .dispatch-alerts::-webkit-scrollbar { display: none }

    .dispatch-units {
        position: absolute;
        bottom: 1.4vh;
        right: 1.4vh;
        width: 44vh;
        height: 28.5vh;
        border-top: .5vh solid #1e7aca;
        background-color: #222832
    }

    .dispatch-units-container {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        width: 96%;
        height: 100%
    }

    .dispatch-container-units-left::-webkit-scrollbar {
        display: none;
    }
</style>