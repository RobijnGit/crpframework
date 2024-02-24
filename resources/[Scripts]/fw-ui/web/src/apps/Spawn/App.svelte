<script>
    import { Delay, OnEvent, SendEvent as _SendEvent } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-characters")
    }

    let Visible = false;
    let AllSpawns = [];
    let SpawnsClose = [];
    let HoverData = {Show: false};
    let SelectedSpawn = false;
    let SpawnDots = [];
    let DrawnParents = {};

    let MapCorner;
    let SpawnHover;

    const ConvertCoords = (X, Y) => {
        let TopRight = { X: 3780, Y: 4740 }

        let MapCornerOffsets = MapCorner.getBoundingClientRect();
        let MapParentOffsets = MapCorner.parentElement.getBoundingClientRect();

        let Offsets = {
            Top: MapCornerOffsets.top - MapParentOffsets.top,
            Left: MapCornerOffsets.left - MapParentOffsets.left
        }

        const mapElement = document.querySelector(".map");
        let MaxY = mapElement.clientWidth - Offsets.Left;
        let MaxX = mapElement.clientHeight - Offsets.Top;

        let RetvalX = Offsets.Top -  ScaleBetween(X, MaxX, TopRight.X)
        let RetvalY =  Offsets.Left - ScaleBetween(Y, MaxY, TopRight.Y)

        return [RetvalX, RetvalY]
    };

    
    const ScaleBetween = (UnscaledNum, MaxAllowed, Max) => {
        return MaxAllowed * (UnscaledNum) / (Max);
    };

    const IsNearPoint = (Spawns, Index) => {
        let Spawn = Spawns[Index];
        let Dist = 30;
        let NearList = [];

        for (let i = Spawns.length - 1; i >= 0; i--) {
            const Elem = Spawns[i];

            if (i != Index) {
                if ((Spawn.CoordsX >= Elem.CoordsX - Dist && Spawn.CoordsX <= Elem.CoordsX + Dist) && (Spawn.CoordsY >= Elem.CoordsY - Dist && Spawn.CoordsY <= Elem.CoordsY + Dist)) {
                    NearList.push(i)
                };
            };
        };

        return NearList;
    };

    const ObtainParent = (Spawns, Index) => {
        let Retval = Index

        for (let i = SpawnsClose[Index].length - 1; i >= 0; i--) {
            let Pos = SpawnsClose[Index][i]
            let ClosestTable = Spawns[Pos]
            if (ClosestTable.Parent != null) Retval = ClosestTable.Parent;
        }

        return Retval
    };

    const GetSpawnsFromGroup = (Spawns, Group) => {
        let Retval = [];
        for (let i = 0; i < Spawns.length; i++) {
            const Elem = Spawns[i];
            if (Elem.Parent == Group) Retval.push(Elem);
        }
        return Retval;
    }

    const SetupSpawns = async (Spawns) => {
        Visible = true;

        while (MapCorner == undefined) {
            await Delay(0.05)
        }

        SpawnsClose = [];
        DrawnParents = {};
        HoverData = { Show: false };
        SelectedSpawn = false;

        for (let i = 0; i < Spawns.length; i++) {
            const Spawn = Spawns[i];
            let Coords = ConvertCoords(Spawn.Coords.X, Spawn.Coords.Y)

            Spawns[i].CoordsX = Coords[0];
            Spawns[i].CoordsY = Coords[1];
            Spawns[i].SpawnIndex = i;
        }

        for (let i = Spawns.length - 1; i >= 0; i--) {
            let IsNear = IsNearPoint(Spawns, i)
            SpawnsClose[i] = IsNear
        }

        for (let i = 0; i <= Spawns.length - 1; i++) {
            if (SpawnsClose[i].length >= 1 ) {
                let Parent = ObtainParent(Spawns, i)
                Spawns[i].Parent = Parent
                Spawns[i].Stacked = true;
                Spawns[i].Spawns = {}
            } else {
                Spawns[i].Parent = i
            }
        }

        AllSpawns = Spawns;
        SpawnDots = [];

        for (let i = 0; i < Spawns.length; i++) {
            const Spawn = Spawns[i];

            if (Spawn.Stacked && DrawnParents[Spawn.Parent] == undefined) {
                DrawnParents[Spawn.Parent] = true
                SpawnDots = [...SpawnDots, {
                    Parent: Spawn.Parent,
                    Id: Spawn.Id,
                    Top: Spawn.CoordsX,
                    Left: Spawn.CoordsY,
                    Icon: "chevron-circle-right",
                    Color: "#ff4444",
                }]
            } else if (!Spawn.Stacked) {
                SpawnDots = [...SpawnDots, {
                    Parent: false,
                    Id: Spawn.Id,
                    Top: Spawn.CoordsX,
                    Left: Spawn.CoordsY,
                    Icon: Spawn.Icon,
                    Color: Spawn.Color,
                }]
            }
        };
    };

    const SelectSpawn = (Data) => {
        if (Data.Parent === false) {
            SendEvent("Spawn/SelectSpawn", {Id: Data.Id});
            return;
        };

        SelectedSpawn = true;
    };

    const HoverSpawn = (Element, Data) => {
        if (Data.Parent !== false) {
            const Spawns = GetSpawnsFromGroup(AllSpawns, Data.Parent);
            HoverData = {
                Show: true,
                Pos: { Top: Element.pageY - 20, Left: Element.pageX + 30 },
                Spawns: []
            };

            for (let i = 0; i < Spawns.length; i++) {
                const Spawn = Spawns[i];
                HoverData.Spawns = [...HoverData.Spawns, {Id: Spawn.Id, Name: Spawn.Name}]
            }
        } else {
            const Spawn = AllSpawns.find(Val => Val.Id == Data.Id);
            HoverData = {
                Show: true,
                Pos: { Top: Element.pageY - 20, Left: Element.pageX + 30 },
                Spawns: [{ Id: Spawn.Id, Name: Spawn.Name }]
            };
        };
    };

    const UnhoverSpawn = (Data) => {
        if (Data.Parent === false) {
            HoverData = { Show: false }
            SelectedSpawn = false;
            return;
        };

        setTimeout(() => {
            const IsSpawnHoverHovered = document.querySelector('.spawn-hover:hover');
            const IsMapMarkerHovered = document.querySelector('.map-marker:hover');
            if (!IsSpawnHoverHovered && !IsMapMarkerHovered) {
                HoverData = { Show: false }
                SelectedSpawn = false;
            };
        }, 500);
    };

    const TrackSpawn = (Element) => {
        if (!HoverData.Show || SelectedSpawn) return;
        HoverData.Pos.Top = Element.pageY - 20;
        HoverData.Pos.Left = Element.pageX + 30;
    };

    OnEvent("Spawn", "SetupSpawns", (Data) => {
        SetupSpawns(Data.Spawns);
    })

    OnEvent("Spawn", "HideSpawn", () => {
        Visible = false;
    })
</script>

<AppWrapper AppName="Spawn" Focused={Visible}>
    {#if Visible}
        <div class="spawn-wrapper">
    
            <!-- Hover Popup -->
            {#if HoverData.Show}
                <div
                    style="top: {HoverData.Pos.Top}px; left: {HoverData.Pos.Left}px; pointer-events: {SelectedSpawn ? "unset" : "none"}"
                    class="spawn-hover"
                    bind:this={SpawnHover}
                >
                    {#if HoverData.Spawns.length == 1}
                        <p>{HoverData.Spawns[0].Name}</p>
                    {:else}
                        {#each HoverData.Spawns as Data, Key}
                            <div
                                on:keyup on:click={() => SendEvent("Spawn/SelectSpawn", {Id: Data.Id})}
                                class="spawn-button"
                            >{Data.Name}</div>
                        {/each}
                    {/if} 
                </div>
            {/if}
    
            <!-- Corner for Position Calculation -->
            <div
                class="map-corner"
                bind:this={MapCorner}
            ></div>
    
            <!-- Icons -->
            <div class="map">
                {#each SpawnDots as Data (Data.Id)}
                    <div
                        class="map-marker"
                        style="top: {Data.Top}px; left: {Data.Left}px; color: {Data.Color};"
                        on:keyup on:click={() => SelectSpawn(Data)}
                        on:mouseenter={(e) => HoverSpawn(e, Data)}
                        on:mouseleave={() => UnhoverSpawn(Data)}
                        on:mousemove={(e) => TrackSpawn(e, Data)}
                    >
                        <i class="fas fa-{Data.Icon}"></i>
                    </div>
                {/each}
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .spawn-wrapper {
        user-select: none;
    }

    .map {
        position: absolute;
        top: 2vh;
        left: 18vh;

        width: 80%;
        height: 95vh;
    }

    .map-marker {
        position: absolute;
        top: -2.2vh;
        left: -0.7vh;

        cursor: pointer;

        color: #ff4444;
        text-shadow: 0 0 3px #000, 0 0 3px #000, 0 0 3px #000, 0 0 3px #000;

        font-size: 2.5vh;
    }

    .map-marker:hover {
        transform: scale(1.1);
    }

    .map-corner {
        position: absolute;
        margin-left: 50.8%;
        margin-top: 30.2%;

        width: 0;
        height: 0;
    }

    .spawn-hover {
        position: absolute;
        top: 0;
        left: 0;

        z-index: 999;

        color: white;

        font-size: 1.2vh;
        font-family: 'Roboto';

        padding: .7vh 1vh;
        border-radius: 1vh;

        background-color: #222831e8;

        width: max-content;
        height: max-content;
    }

    .spawn-hover > p {
        width: 20vh;
        padding: .3vh 0;
    }

    .spawn-hover > .spawn-button {
        padding: 0.3vh;
        margin-top: 0.4vh;

        border-radius: 1vh;

        width: 20vh;
        height: 1.5;
        
        line-height: 1.5;
        text-align: center;

        background-color: rgba(46, 46, 46, 0.8);
    }

    .spawn-hover > .spawn-button:hover {
        background-color: #3f4a5a;
    }
</style>