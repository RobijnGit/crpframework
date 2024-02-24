<script lang="ts">
    import Ripple from "@smui/ripple";
    import { addResultNotification, FetchNui } from "../../../../utils/TypedUtils";

    let AuctioningStartBid: number;
    let TransferingPlayer: number;
    let modalLoading = false;

    export let Data = {
        Id: 42,
        Started: false, // IF CONTRACT IS IN PROGRESS THIS MUST BE TRUE!!!!
        Vin: false,
        Class: "A",
        Contractor: "StarCunt",
        Vehicle: "kanjo",
        VehicleLabel: "Kanjo",
        Crypto: "GNE",
        BuyIn: 20,
        ScratchAllowed: true,
        ScratchPrice: 10,
        Expire: new Date().getTime() + 5799000, // new Date().getTime(),
    };

    // 7 days
    const scratchLimitPeriod = 1000 * 60 * 60 * 24 * 7;

    export let UserData = {
        Cid: "1001",
        ContractsDone: 0,
        LastVinScratch: new Date().getTime(),
    };

    const CalculateTime = (timestamp: number, alwaysDays?: boolean) => {
        const Total = Math.max(0, timestamp - new Date().getTime());
        const Minutes = Math.floor((Total / 1000 / 60) % 60);
        const Hours = Math.floor((Total / (1000 * 60 * 60)) % 24);
        const Days = Math.floor(Total / (1000 * 60 * 60 * 24));

        if (Days > 0) return `${Days} dagen, ${Hours} uren, ${Minutes} minuten`;
        return `${Hours} uren, ${Minutes} minuten`
    };

    const TimeUntilTimestamp = (timestamp) => {
        let total = timestamp - new Date().getTime();
        const done = total < 0;

        total = Math.max(0, total);

        return { time: CalculateTime(timestamp, true), done };
    };

    const GetTimeColor = () => {
        const Total = Data.Expire - new Date().getTime();
        const Minutes = Math.floor((Total / 1000 / 60) % 60);
        const Hours = Math.floor((Total / (1000 * 60 * 60)) % 24);

        if (Hours > 1 || (Hours == 1 && Minutes > 30)) {
            // if more than 1 hour and 30 min = greed
            return "green";
        } else if (Hours == 1 && Minutes <= 30) {
            // if less then 1,5 hours = orange
            return "orange";
        } else if (Minutes < 45) {
            // if less than 45 min = red
            return "red";
        }

        return "orange";
    };

    function getTimeValues() {
        return { time: CalculateTime(Data.Expire), color: GetTimeColor() };
    }

    let expires = getTimeValues();
    let scratchTime = TimeUntilTimestamp(UserData.LastVinScratch + scratchLimitPeriod);

    setInterval(() => {
        expires = getTimeValues();
        scratchTime = TimeUntilTimestamp(UserData.LastVinScratch + scratchLimitPeriod);
    }, 1000);

    let currentModal: "vin" | "start" | "decline" | "cancel" | "auction" | "transfer";

    interface Modal {
        title: string;
        confirmText?: string;
        cancelText?: string;
        nextModal?: typeof currentModal;
        onConfirm: () => Promise<boolean>;
        onCancel?: () => Promise<void>;
    }

    let modals: Record<typeof currentModal, Modal>;
    $: {
        modals = {
            vin: {
                title: "Selecteer type",
                confirmText: scratchTime.done
                    ? "Vin scratch"
                    : `Vin scratch beschikbaar over: <div>${scratchTime.time}</div>`,
                cancelText: "Normale aflevering",
                nextModal: "start",
                onConfirm: async () => {
                    Data.Vin = true;
                    return true;
                },
            },
            start: {
                title: "Contract starten?",
                onConfirm: async () => {
                    const result = await FetchNui<{ success: boolean; message: string }>(
                        "fw-laptop",
                        "Boosting/StartContract",
                        { contract: Data, user: UserData },
                        { success: true, message: "Contract gestart, instructies zijn naar je telefoon gestuurd." }
                    );
                    Data.Started = result.success;
                    addResultNotification("Boostin", result);

                    // "Boostin" "Contract started, you should be email/pinged instructions."
                    // "Boostin" "Need to wait before you can do this contract type again!" (if failed to start contract)
                    return true;
                },
                onCancel: async () => {
                    Data.Vin = false;
                    return true;
                },
            },
            decline: {
                title: "Contract weigeren?",
                onConfirm: async () => {
                    const result = await FetchNui(
                        "fw-laptop",
                        "Boosting/DeclineContract",
                        { contract: Data },
                        { success: true, message: "Contract geweigerd!" }
                    );
                    addResultNotification("Boostin", result);
                    return true;
                },
            },
            cancel: {
                title: "Contract annuleren?",
                onConfirm: async () => {
                    // "Boostin" "Succesfully canceled contract" (if no GNE buy-in)
                    // "Boostin" "You have been refunded your GNE buy in." (if GNE buy-in)
                    const result = await FetchNui<{ success: boolean; message: string }>(
                        "fw-laptop",
                        "Boosting/CancelContract",
                        { contract: Data },
                        { success: true, message: "Contract geannuleerd, je buy in wordt gerefund." }
                    );
                    Data.Started = !result.success;
                    addResultNotification("Boostin", result);
                    return true;
                },
            },
            auction: {
                title: "Veiling contract",
                onConfirm: async () => {
                    if (!AuctioningStartBid || AuctioningStartBid < 1) {
                        addResultNotification("Boostin", {
                            success: false,
                            message: "Geef een geldig startbod op!",
                        });
                        return false;
                    }
                    const result = await FetchNui<{ success: boolean; message: string; dumb?: boolean }>(
                        "fw-laptop",
                        "Boosting/AuctionContract",
                        {
                            bid: AuctioningStartBid,
                            contract: Data,
                        },
                        {
                            success: true,
                            message: "Contract succesvol geveild!",
                        }
                    );
                    addResultNotification("Boostin", result);
                    return true;
                },
            },
            transfer: {
                title: "Contract overdragen",
                onConfirm: async () => {
                    if (!TransferingPlayer || TransferingPlayer < 1) {
                        addResultNotification("Boostin", {
                            success: false,
                            message: "Geef een geldig ID op!",
                        });
                        return false;
                    }
                    const result = await FetchNui<{ success: boolean; message: string; dumb?: boolean }>(
                        "fw-laptop",
                        "Boosting/TransferContract",
                        {
                            target: TransferingPlayer,
                            contract: Data,
                        },
                        {
                            success: true,
                            message: "Contract succesvol overgedragen!",
                        }
                    );
                    addResultNotification("Boostin", result);
                    return result.success;
                },
            },
        };
    }

    function openModal(t: typeof currentModal) {
        currentModal = t;
    }

    async function onConfirm() {
        if (!currentModal) return;
        modalLoading = true;
        if (await modals[currentModal].onConfirm()) {
            currentModal = modals[currentModal].nextModal ?? undefined;
        }
        modalLoading = false;
    }

    async function onCancel() {
        if (modals[currentModal].onCancel) {
            await modals[currentModal].onCancel();
        }
        currentModal = modals[currentModal].nextModal ?? undefined;
    }
</script>

<div class="boosting-card-container">
    {#if !currentModal}
        <div class="boosting-card-class">
            <p>{Data.Class}</p>
        </div>

        <p class="boosting-card-text" style="margin-top: 1.4vh;">
            {Data.Contractor}
        </p>
        <p class="boosting-card-text boosting-card-vehicle">
            {Data.VehicleLabel}
        </p>
        <p class="boosting-card-text">
            Inkoop:
            {#if UserData.ContractsDone > 0}
                {Data.BuyIn} {Data.Crypto}
            {:else}
                <span style="color: green;">GRATIS</span>
            {/if}
        </p>
        <p class="boosting-card-text boosting-card-expire">
            Verloopt over:
            <span style="display: block; color: {expires.color};">{expires.time}</span>
        </p>

        <div class="boosting-card-buttons">
            <div
                use:Ripple={{ surface: true, active: true }}
                on:keyup
                on:click={() => {
                    openModal(Data.ScratchAllowed ? "vin" : "start");
                }}
                class="boosting-card-buttons__btn {Data.Started && 'disabled'}"
            >
                <p>
                    {Data.Started ? "Contract actief" : "Contract starten"}
                </p>
            </div>
            <div
                use:Ripple={{ surface: true, active: true }}
                on:keyup
                on:click={() => {
                    openModal("transfer");
                }}
                class="boosting-card-buttons__btn {Data.Started && 'disabled'}"
            >
                <p>Contract overdragen</p>
            </div>
            <div
                use:Ripple={{ surface: true, active: true }}
                on:keyup
                on:click={() => {
                    openModal("auction");
                }}
                class="boosting-card-buttons__btn {Data.Started && 'disabled'}"
            >
                <p>Contract veilen</p>
            </div>
            {#if !Data.Started}
                <div
                    use:Ripple={{ surface: true, active: true }}
                    on:keyup
                    on:click={() => {
                        openModal("decline");
                    }}
                    class="boosting-card-buttons__btn"
                >
                    <p>Contract weigeren</p>
                </div>
            {:else}
                <div
                    use:Ripple={{ surface: true, active: true }}
                    on:keyup
                    on:click={() => {
                        openModal("cancel");
                    }}
                    class="boosting-card-buttons__btn"
                >
                    <p>Contract annuleren</p>
                </div>
            {/if}
        </div>
    {:else}
        {#if modalLoading}
            <div class="boosting-card-overlay">
                <i class="fas fa-spinner fa-3x" />
            </div>
        {/if}
        <div class="boosting-card-modal">
            <h1>{modals[currentModal].title}</h1>
            {#if currentModal == "vin"}
                <p>Als je ervoor kiest om te vin scratchen, kost dit {Data.ScratchPrice} {Data.Crypto} extra om het voertuig op naam te zetten.</p>
            {:else if currentModal == "start" && !Data.ScratchAllowed}
                <p>Dit voertuig kan momenteel niet gescratched worden.</p>
            {/if}

            <div class="boosting-card-buttons">
                {#if currentModal == "auction"}
                    <div class="boosting-card-buttons__btn">
                        <input
                            bind:value={AuctioningStartBid}
                            placeholder="Start bod {Data.Crypto}"
                            type="number"
                            min="1"
                        />
                    </div>
                {:else if currentModal == "transfer"}
                    <div class="boosting-card-buttons__btn">
                        <input
                            bind:value={TransferingPlayer}
                            placeholder="PayPal-ID"
                            type="number"
                            min="1"
                        />
                    </div>
                {/if}

                <div
                    use:Ripple={{ surface: true, active: true }}
                    on:keyup
                    on:click={onConfirm}
                    class="boosting-card-buttons__btn {currentModal == 'vin' && !scratchTime.done && 'disabled'}"
                >
                    <p>
                        {#if modals[currentModal].confirmText}
                            {@html modals[currentModal].confirmText}
                        {:else}
                            Doorgaan
                        {/if}
                    </p>
                </div>
                <div
                    use:Ripple={{ surface: true, active: true }}
                    on:keyup
                    on:click={onCancel}
                    class="boosting-card-buttons__btn"
                >
                    <p>{modals[currentModal].cancelText ?? "Annuleren"}</p>
                </div>
            </div>
        </div>
    {/if}
</div>

<style>
    .boosting-card-container {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;

        width: 100%;
        height: 39vh;

        background-color: #22212a;
        border-radius: 0.5vh;
    }

    .boosting-card-container > .boosting-card-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 1;
    }

    .boosting-card-overlay > .fa-spinner {
        animation: fa-spin 1s linear infinite;
        color: white;
    }

    .boosting-card-class {
        display: flex;
        justify-content: center;
        align-items: center;

        margin-top: 3.1vh;

        color: white;
        font-family: Roboto;
        font-size: 1.5vh;
        font-weight: bold;

        width: 4.8vh;
        height: 4.8vh;

        background-color: #191922;
        border-radius: 50%;

        border: 0.2vh solid rgba(46, 215, 182, 1);
    }

    .boosting-card-text {
        margin-top: 0.4vh;
        max-width: 79%;

        font-family: Roboto;
        font-size: 1.4vh;

        text-align: center;
        color: rgb(220, 220, 220);
    }

    .boosting-card-vehicle {
        font-weight: 600;
        font-size: 1.5vh;
    }

    .boosting-card-expire > span {
        font-size: 1.5vh;
        color: green;
    }

    .boosting-card-buttons {
        margin-top: 1.4vh;
        width: 85%;
    }

    .boosting-card-buttons__btn {
        width: 100%;
        display: flex;
        justify-content: center;
        align-items: center;

        min-height: 3.6vh;

        font-family: Roboto;
        font-size: 1.3vh;

        color: rgba(200, 200, 200, 1);

        cursor: pointer;

        background-color: #1a1922;
        margin-bottom: 0.8vh;
    }

    /* Chrome, Safari, Edge, Opera */
    input::-webkit-outer-spin-button,
    input::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* Firefox */
    input[type="number"] {
        -moz-appearance: textfield;
        appearance: textfield;
    }

    input {
        text-align: center;
    }

    .boosting-card-buttons__btn.disabled {
        background-color: #3d3c45;
        pointer-events: none;
        cursor: not-allowed;
    }

    .boosting-card-buttons__btn > input {
        border: none;
        outline: none;
        background-color: transparent;

        color: white;
        font-family: Roboto;
        font-size: 1.3vh;

        width: 90%;
    }

    .boosting-card-modal {
        margin: auto;

        max-height: 70%;
        height: max-content;
        width: 85%;

        text-align: center;
        color: white;
    }

    .boosting-card-modal > .boosting-card-buttons {
        width: 100%;
    }

    .boosting-card-modal > h1 {
        font-size: 2.2vh;
        font-family: Roboto;
        font-weight: unset;
        margin-bottom: 1.2vh;
    }

    .boosting-card-modal > p {
        color: rgba(200, 200, 200, 1);
        font-family: Roboto;
        font-size: 1.5vh;
        margin-bottom: 0.5vh;
    }
</style>
