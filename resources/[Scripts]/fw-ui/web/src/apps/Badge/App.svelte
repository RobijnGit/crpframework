<script>
    import { fade } from "svelte/transition";
    import { OnEvent } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    const Subtypes = {
        "pd": {
            "Unified PD": "UPD",
            "Los Santos PD": "LSPD",
            "Blaine County Sheriffs Office": "BCSO",
            "State Troopers": "SASP",
            "State Parks": "RANGER",
        },
    };

    const TitleColors = {
        "pd": {
            "Unified PD": ["#c1ba4d", "black"],
            "Los Santos PD": ["#18151e", "white"],
            "Blaine County Sheriff": ["#a17925", "white"],
            "State Troopers": ["#bbb8ae", "black"],
            "State Parks": ["#313723", "white"],
        }
    }

    let ShowBadge = false;
    let BadgeTimeout;

    let BadgeType = 'LSPD';
    let BadgeTitleColor = ['#18151e', 'white'];
    let BadgeData = {
        Department: 'Los Santos PD',
        Rank: 'Chief of Police',
        Name: 'John Doe',
        Callsign: '#420',
        Image: "https://media.tenor.com/N0aZdbie0N8AAAAd/cute-cute-cat.gif"
    };

    OnEvent("Badge", "ShowBadge", (Data) => {
        if (BadgeTimeout) clearTimeout(BadgeTimeout);
        ShowBadge = false;

        BadgeType = Data.Type.toUpperCase();
        BadgeData = Data.Badge;

        if (Data.Type == 'pd') {
            BadgeType = Subtypes['pd'][BadgeData.Department];
        };

        BadgeTitleColor = ["#18151e", "white"];
        if (Data.Type == 'pd') {
            BadgeTitleColor = TitleColors['pd'][BadgeData.Department] || ["#18151e", "white"];
        };

        ShowBadge = true;
        BadgeTimeout = setTimeout(() => {
            ShowBadge = false;
        }, 3000);
    });

</script>

<AppWrapper AppName="Badge" Focused={false}>
    {#if ShowBadge}
        <div
            class="badge-wrapper"
            transition:fade={{duration: 250}}
        >
            <div class="police-badge">
                <div class="police-badge-mugshot">
                    <img
                        src={BadgeData.Image}
                        alt=""
                    />
                </div>
    
                <div class="police-badge-logo">
                    <img
                        src="./images/badge/{BadgeType}Logo.png"
                        alt=""
                    />
                </div>
    
                <div
                    style="background-color: {BadgeTitleColor[0]}; color: {BadgeTitleColor[1]}"
                    class="police-badge-department"
                >
                    <p>{BadgeData.Department}</p>
                </div>
    
                {#if BadgeData.Rank}
                    <div class="police-badge-rank">
                        <p>{BadgeData.Rank}</p>
                    </div>
                {/if}
    
                <div class="police-badge-name">
                    <p>{BadgeData.Name}</p>
                </div>
    
                {#if BadgeData.Callsign}
                    <div class="police-badge-callsign">
                        <p>#{BadgeData.Callsign}</p>
                    </div>
                {/if}
            </div>
        </div>
    {/if}
</AppWrapper>

<!-- css is dogshit, don't look. -->
<style>
    .badge-wrapper {
        position: absolute;

        top: 34vh;
        left: 2.5vh;

        height: 42vh;
        width: 44.44vh;

        font-style: normal;
        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        font-variant: small-caps;

        color: white;
        text-align: center;
    }

    .police-badge {
        position: absolute;

        height: 100%;
        width: 100%;

        background-size: 44.44vh;
        background-repeat: no-repeat;
        background-image: url('.././images/badge/badge.png');
    }

    .police-badge-mugshot {
        position: absolute;
        display: flex;

        align-items: center;
        justify-content: center;

        top: 4vh;
        left: 2.2vh;

        margin: 0;
        padding: 0;

        height: 11.4vh;
        width: 18.4vh;
    }

    .police-badge-mugshot > img { width: 12vh; }

    .police-badge-logo {
        position: absolute;
        display: flex;

        align-items: center;
        justify-content: center;

        top: 1vh;
        left: 23vh;

        margin: 0;
        padding: 0;

        height: 32.5vh;
        width: 20.8vh;
    }

    .police-badge-logo > img { width: 19vh; }

    .police-badge-department {
        position: absolute;
        display: flex;

        justify-content: center;
        align-items: center;

        top: 17.2vh;
        left: 2.2vh;

        height: 3.3vh;
        width: 41.5%;

        margin: auto 0;

        font-size: 1.3vh;
        font-weight: 600;
        text-transform: uppercase;

        background-color: #18151e;
    }

    .police-badge-rank {
        position: absolute;
        display: flex;

        justify-content: center;
        align-items: center;

        top: 21vh;
        left: 2.2vh;

        height: 3.3vh;
        width: 41.5%;

        margin: auto 0;

        color: black;
        font-size: 1.7vh;
        font-weight: 600;
    }

    .police-badge-name {
        position: absolute;
        display: flex;

        justify-content: center;
        align-items: center;

        top: 24.3vh;
        left: 2.2vh;

        height: 3.3vh;
        width: 41.5%;

        margin: auto 0;

        color: black;
        font-size: 1.7vh;
        font-weight: 600;
    }

    .police-badge-callsign {
        position: absolute;
        display: flex;

        justify-content: center;
        align-items: center;

        top: 28vh;
        left: 2.2vh;

        height: 3.3vh;
        width: 41.5%;

        margin: auto 0;

        color: black;
        font-size: 1.7vh;
        font-weight: 600;
    }
</style>