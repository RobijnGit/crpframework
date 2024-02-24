<script>
    import L from "leaflet";
    import "leaflet/dist/leaflet.css";

    import { onMount } from "svelte";
    import { MapMarkers } from "../config";
    import { OnEvent } from "../../../utils/Utils";

    export let Visible = false;

    const CenterX = 117.3;
    const CenterY = 172.8;
    const ScaleX = 0.02072;
    const ScaleY = 0.0205;
    let Map;

    const MarkersByUUID = [];
    const MarkerDivs = {};

    const CUSTOM_CRS = L.extend({}, L.CRS.Simple, {
        projection: L.Projection.LonLat,
        scale: function(zoom) {
            return Math.pow(2, zoom);
        },
        zoom: function(sc) {
            return Math.log(sc) / 0.6931471805599453;
        },
        distance: function(pos1, pos2) {
            var x_difference = pos2.lng - pos1.lng;
            var y_difference = pos2.lat - pos1.lat;
            return Math.sqrt(x_difference * x_difference + y_difference * y_difference);
        },
        transformation: new L.Transformation(ScaleX, CenterX, -ScaleY, CenterY),
        infinite: true
    });

    const AddMarker = (UUID, Job, Type, Text, Coords) => {
        const Index = MarkersByUUID.findIndex(Val => Val.UUID == UUID);
        if (Index > -1) RemoveMarker(UUID);

        const Marker = L.marker([Coords.y, Coords.x], {
            icon: MarkerDivs[Job][Type],
            interactive: false
        });

        MarkersByUUID.push({ UUID, Job, Marker })

        Marker.bindTooltip(Text, {
            direction: "right",
            permanent: true,
            sticky: true,
            offset: [0, 0],
            opacity: 0.9,
            className: 'map-tooltip'
        });

        Marker.addTo(Map);
    };

    const RemoveMarker = (UUID) => {
        const Index = MarkersByUUID.findIndex(Val => Val.UUID == UUID);
        if (Index == -1) return;

        MarkersByUUID[Index].Marker.remove();
        MarkersByUUID.splice(Index, 1);
    };

    const SetMarkerCoords = (UUID, Coords) => {
        const Index = MarkersByUUID.findIndex(Val => Val.UUID == UUID);
        if (Index == -1) return;

        MarkersByUUID[Index].Marker.setLatLng([Coords.y, Coords.x])
    };

    const SetMarkerText = (UUID, Text) => {
        const Index = MarkersByUUID.findIndex(Val => Val.UUID == UUID);
        if (Index == -1) return;

        MarkersByUUID[Index].Marker.setTooltipContent(Text);
    };

    const SetMarkerType = (UUID, Type) => {
        const Index = MarkersByUUID.findIndex(Val => Val.UUID == UUID);
        if (Index == -1) return;

        MarkersByUUID[Index].Marker.setIcon(MarkerDivs[MarkersByUUID[Index].Job][Type])
    };


    OnEvent("Dispatch", "CreateMarker", (Data) => {
        if (!Data.UUID) {
            return console.error("Invalid UUID for marker!");
        };

        if (!MapMarkers[Data.Category]) {
            return console.error("Invalid Marker Type!");
        }

        if (Data.Coords.x == 0.0 && Data.Coords.y == 0.0) return;
        AddMarker(Data.UUID, Data.Category, Data.Type, Data.Text, Data.Coords);
    });

    OnEvent("Dispatch", "RemoveMarker", (Data) => {
        if (!Data.UUID) {
            return console.error("Invalid UUID for marker!");
        };

        RemoveMarker(Data.UUID);
    });

    OnEvent("Dispatch", "SetMarkerCoords", (Data) => {
        if (!Data.UUID) {
            return console.error("Invalid UUID for marker!");
        };

        SetMarkerCoords(Data.UUID, Data.Coords);
    });

    OnEvent("Dispatch", "SetMarkerText", (Data) => {
        if (!Data.UUID) {
            return console.error("Invalid UUID for marker!");
        };

        SetMarkerText(Data.UUID, Data.Text);
    });

    OnEvent("Dispatch", "SetMarkerType", (Data) => {
        if (!Data.UUID) {
            return console.error("Invalid UUID for marker!");
        };

        SetMarkerType(Data.UUID, Data.Type);
    });

    onMount(() => {
        Map = L.map("map", {
            crs: CUSTOM_CRS,
            minZoom: 2,
            maxZoom: 6,
            center: [0, 0],
            noWrap: true,
            continuousWorld: false,
            preferCanvas: true,
            zoom: 3
        });

        const w = 1024;
        const h = 1024;

        const southWest = Map.unproject([0, h], 3 - 1);
        const northEast = Map.unproject([w, 0], 3 - 1);
        const bounds = new L.LatLngBounds(southWest, northEast);

        L.imageOverlay("./images/dispatchmap.png", bounds).addTo(Map);
        Map.setMaxBounds(bounds);

        for (const category in MapMarkers) {
            for (const type in MapMarkers[category]) {
                const { html, iconSize, className, offset } = MapMarkers[category][type];
                if (!MarkerDivs[category]) MarkerDivs[category] = {};
                MarkerDivs[category][type] = L.divIcon({ html, iconSize, className, offset });
            };
        };
    })
</script>

<div class="map-container" style="display: {Visible ? "block": "none"};">
    <div
        id="map"
        style="width: 100%; height: 100%;"
    ></div>
</div>

<style>
    .map-container {
        width: 50%;
        height: 100%;
    }

    :global(.leaflet-control-attribution) {
        display: none;
    }

    :global(.leaflet-container) {
        background: #0fa8d2 !important;
    }

    :global(.leaflet-tooltip-right::before) {
        border: none !important;
    } 

    :global(.map-icon) {
        font-size: 2vh !important;
    }

    :global(.map-icon-pd) {
        color: #0d47a1 !important;
    }

    :global(.map-icon-ems) {
        color: #ec8030 !important;
    }

    :global(.map-tooltip) {
        background-color: unset !important;
        border: unset !important;
        box-shadow: unset !important;
        font-size: 1.4vh !important;
        color: #fff !important;
        font-family: Arial !important;
        letter-spacing: .075vh;
        font-weight: 600 !important;
        text-decoration: none !important;
        font-style: normal !important;
        text-transform: uppercase !important;
        width: 100% !important;
        text-shadow: rgb(55 71 79) -0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh -0.1vh 0, rgb(55 71 79) -0.1vh -0.1vh 0 !important;
    }
</style>