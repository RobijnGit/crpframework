<script>
    import { DateTime, Duration } from 'luxon';
    import { Delay, OnEvent } from "../../utils/Utils";
    import AppWrapper from '../../components/AppWrapper.svelte';

    let ShowHud = false;
    let ShowPosition = false;

    const NoTimeText = '- - : - - : - -';
    let BestLapTime = NoTimeText;
    let Timers = {
        Current: { Text: NoTimeText, Start: 0, Ms: 0, Interval: null },
        Total: { Text: NoTimeText, Start: 0, Ms: 0, Interval: null }
    };

    let Finished = 0;
    let ShowDNF = false;
    let DNFTime = 0;
    let DNFShowText = '00:00';
    let DidDNF = false;
    let DNFInterval;

    let Checkpoint = 0;
    let Position = 0;
    let Lap = 0;
    
    let TotalPlayers = 0;
    let TotalLaps = 0;
    let TotalCheckpoints = 0;

    let ShowCountdown = false;
    let CountdownText = ""
    let CountdownClass = '';

    const StartTimer = (Type) => {
        Timers[Type].Start = DateTime.now();
        Timers[Type].Interval = setInterval(() => {
            const Time = DateTime.now().diff(Timers[Type].Start).as('milliseconds');
            Timers[Type].Text = DateTime.fromMillis(Time).toFormat('mm:ss.SSS')
        }, 17);
    };

    const ResetTimer = (Type) => {
        Timers[Type].Start = DateTime.now();
    };

    const StopTimer = (Type) => {
        clearInterval(Timers[Type].Interval);
    };

    const StartCountdown = async () => {
        ShowCountdown = true;

        for (let i = 3; i >= 0; i--) {
            if (i == 0) {
                CountdownText = "GO"
                CountdownClass = "green";
                await Delay(1);
                CountdownClass = "fadeup";
                await Delay(1.5);
            } else {
                CountdownText = i
                CountdownClass = "";
                await Delay(0.05);
                CountdownClass = "fadeout";
                await Delay(1);
            };
        };

        ShowCountdown = false;
    };

    OnEvent("Racing", "ResetTimers", (Data) => {
        Timers = {
            Current: { Text: NoTimeText, Start: 0, Ms: 0, Interval: null },
            Total: { Text: NoTimeText, Start: 0, Ms: 0, Interval: null }
        };
    });

    OnEvent("Racing", "StartCountdown", StartCountdown);
    OnEvent("Racing", "StartTimer", StartTimer);
    OnEvent("Racing", "ResetTimer", ResetTimer);
    OnEvent("Racing", "StopTimer", StopTimer);
    OnEvent("Racing", "SetBestLap", (Data) => {
        if (!Data) {
            BestLapTime = NoTimeText;
            return
        };

        BestLapTime = DateTime.fromMillis(Data).toFormat('mm:ss.SSS')
    });

    OnEvent("Racing", "SetAdditionalTime", (Data) => {
        Timers.Total.Start = Timers.Total.Start.minus({ milliseconds: Data.Penalty });
        Timers.Current.Start = Timers.Current.Start.minus({ milliseconds: Data.Penalty });
    });


    OnEvent("Racing", "SetHud", (Data) => {
        ShowHud = Data.Visible;
        ShowPosition = Data.ShowPos;
        Finished = Data.Finished;
        DidDNF = Data.DidDNF;
        Checkpoint = Data.Checkpoint;
        Position = Data.Position;
        Lap = Data.Lap;
        TotalPlayers = Data.TotalPlayers;
        TotalLaps = Data.TotalLaps;
        TotalCheckpoints = Data.TotalCheckpoints;

        if (Data.Finished) {
            StopTimer("Total");
            StopTimer("Current");
        }
    });

    OnEvent("Racing", "SetDNF", (Data) => {
        ShowDNF = Data.Active;
        if (!ShowDNF) {
            clearInterval(DNFInterval);
            return
        }

        DNFTime = DateTime.fromMillis(Data.Timestamp);
        DNFShowText = DNFTime.diff(DateTime.now()).toFormat('mm:ss');
        DNFInterval = setInterval(() => {
            DNFShowText = DNFTime.diff(DateTime.now()).toFormat('mm:ss');
        }, 1000)
    });
</script>

<AppWrapper AppName="Racing" Focused={false}>
    {#if ShowCountdown}
        <div class="racing-circle {CountdownClass}">
            <span>{CountdownText}</span>
        </div>
    {/if}
    
    {#if ShowHud}
        <div class="racing-hud">
            {#if !Finished && ShowDNF}
                <div class="racing-hud-row">
                    <span>DNF</span>
                    <span>{DNFShowText}</span>
                </div>
            {/if}
            
            {#if ShowPosition || Finished || DidDNF}
                <div class="racing-hud-row">
                    <span>Pos</span>
                    {#if DidDNF}
                        <span class="red-text">DNF</span>
                    {:else}
                        <span class="{Finished ? "green-text" : ""}">{Position}/{TotalPlayers}</span>
                    {/if}
                </div>
            {/if}
    
            {#if !Finished}
                <div class="racing-hud-row">
                    <span>Lap</span>
                    <span>{Lap}/{TotalLaps}</span>
                </div>
    
                <div class="racing-hud-row">
                    <span>Checkpoint</span>
                    <span>{Checkpoint}/{TotalCheckpoints}</span>
                </div>
            {/if}
    
            <div class="racing-hud-row small-text">
                <span>Current Lap</span>
                <span>{Timers['Current'].Text}</span>
            </div>
    
            <div class="racing-hud-row small-text">
                <span>Best Lap</span>
                <span>{BestLapTime}</span>
            </div>
    
            <div class="racing-hud-row small-text">
                <span>Total Time</span>
                <span>{Timers['Total'].Text}</span>
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .racing-circle {
        position: absolute;
        left: 0;
        right: 0;

        margin: 0 auto;

        width: 15vh;
        height: 15vh;
        margin-top: 30vh;
        border-radius: 50%;
        background: rgba(192, 31, 53, .75);
        display: flex;
        justify-content: center;
        align-items: center;
        opacity: 1;
        transition: none
    }

    .racing-circle.fadeout:not(.green) {
        background: rgba(192, 31, 53, .2);
        transition: all 1.5s ease-in-out;
    }

    .racing-circle.fadeup {
        opacity: 0;
        margin-top: -60vh;
        transition: all 1s ease-in-out
    }

    .racing-circle.green {
        background: rgba(0, 165, 0, .75);
    }

    .racing-circle > span {
        font-size: 7.2vh;
        font-weight: 700;
        font-family: fantasy, Times New Roman;
        color: #fff;
        text-align: center;
        opacity: 1
    }

    .racing-hud {
        position: absolute;
        bottom: 2.5vh;
        right: 2.5vh;

        background: rgba(0, 0, 0, .3);
        padding: .7vh;
        color: #fff;
        font-family: Roboto, sans-serif;
        width: 28vh
    }

    .racing-hud-row {
        display: flex;
        justify-content: space-between;
        font-size: 2.8vh;
        padding: .3vh
    }

    .small-text {
        font-size: 2vh
    }

    .green-text {
        color: #00c400
    }

    .red-text {
        color: #d70000
    }
</style>