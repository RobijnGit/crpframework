<script>
    import { onMount } from "svelte";
    import { LicensesLocale } from "../../../config";
    import { FormatCurrency, SendEvent } from "../../../utils/Utils";
    import { PlayerData } from "../phone.stores";

    import AppWrapper from "../components/AppWrapper.svelte";

    let MyLicenses = [];

    onMount(() => {
        SendEvent("Details/GetLicenses", {}, (Success, Data) => {
            if (!Success) return;
            MyLicenses = Data;
        })
    })
</script>

<AppWrapper>
    <div class="phone-details-list">
        <div data-tooltip="BSN" data-position="top" class="phone-details-list-item">
            <i class="fas fa-id-card" />
            <p>{$PlayerData?.Cid}</p>
        </div>
        <div data-tooltip="Bankrekening" data-position="top" class="phone-details-list-item">
            <i class="fas fa-university" />
            <p>{$PlayerData?.BankId}</p>
        </div>
        <div data-tooltip="Telefoonnummer" data-position="top" class="phone-details-list-item">
            <i class="fas fa-mobile" />
            <p>{$PlayerData?.PhoneNumber}</p>
        </div>
        <div data-tooltip="Cash" data-position="top" class="phone-details-list-item">
            <i class="fas fa-wallet" style="color: #acd680;" />
            <p>{FormatCurrency.format($PlayerData?.Cash)}</p>
        </div>
        <div data-tooltip="Bankbalans" data-position="top" class="phone-details-list-item">
            <i class="fas fa-piggy-bank" style="color: #53cee5;" />
            <p>{FormatCurrency.format($PlayerData?.Bank)}</p>
        </div>
        <div data-tooltip="Casinobalans" data-position="top" class="phone-details-list-item">
            <i class="fas fa-dice-three" style="color: #fd4083;" />
            <p>{FormatCurrency.format($PlayerData?.Casino)}</p>
        </div>
    </div>
    <div class="phone-details-licenses">
        <p>Licenties</p>
        <div class="phone-details-licenses-cards">
            {#each Object.entries(MyLicenses) as Data, Id}
                {#if Data[0] != "weapon" || Data[1] == true}
                    <div class="phone-details-licenses-item">
                        <p>{LicensesLocale[Data[0]]}</p>
                        <i class="fas fa-{Data[1] ? "check-circle" : "times-circle"}" />
                    </div>
                {/if}
            {/each}
        </div>
    </div>
</AppWrapper>

<style>
    .phone-details-list {
        position: relative;
        top: 3.0vh;
        left: 0;
        right: 0;
        margin: 0 auto;
        height: max-content;
        width: 87%
    }

    .phone-details-list > .phone-details-list-item {
        display: flex;
        height: 3vh;
        line-height: 3.3vh;
        margin-bottom: 1.4vh
    }

    .phone-details-list > .phone-details-list-item > i {
        width: 3.5vh;
        text-align: center;
        font-size: 3vh
    }

    .phone-details-list > .phone-details-list-item > p {
        position: relative;
        left: 1.5vh;
        margin: 0;
        color: white;
        font-size: 1.8vh;
        font-weight: bold
    }

    .phone-details-licenses {
        position: relative;
        top: 4vh;
        left: 0;
        right: 0;
        margin: 0 auto;
        width: 87%
    }

    .phone-details-licenses > p {
        text-align: center;
        font-size: 2.2vh;
        margin-bottom: 1.8vh
    }

    .phone-details-licenses-cards {
        position: relative
    }

    .phone-details-licenses-item {
        position: relative;
        clear: both;
        overflow: hidden;
        margin-bottom: 0.5vh
    }

    .phone-details-licenses-item > p {
        float: left;
        margin: 0;
        line-height: 2.15vh;
        font-size: 1.5vh
    }

    .phone-details-licenses-item > i {
        float: right;
        font-size: 2vh;
        color: #95ef77;
        line-height: 2.15vh
    }

    .phone-details-licenses-item > i.fa-times-circle {
        color: #f2a365
    }
</style>