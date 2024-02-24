<script>
    import { CopyToClipboard, SendEvent as _SendEvent } from "../../../utils/Utils";
    import { ModalData } from "../financials.store";

    import TextField from "../../../lib/TextField/TextField.svelte";
    import Modal from "../components/Modal.svelte";
    import Button from "../../../lib/Button/Button.svelte";
    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-financials");

    let StartDate;
    let EndDate;
    let Loading = false;

    let ShowExport = false;
    let ExportMsg = '';
    let ExportUrl = '';

    const Export = () => {
        Loading = true; 
        SendEvent("Financials/ExportData", {
            AccountId: $ModalData.AccountId,
            StartDate: StartDate,
            EndDate: EndDate
        }, (Success, Data) => {
            if (!Success) return ModalData.set({});

            ExportMsg = Data.Msg;
            ExportUrl = Data.Url;
            ShowExport = true;
            Loading = false;
        });
    };

    const Close = () => ModalData.set({})
    const CopyUrl = () => {
        CopyToClipboard(ExportUrl)
        Close();
    };
</script>

<Modal>
    {#if ShowExport}
        <div style="width: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; margin: 3vh 0">
            <h1>{ExportMsg}</h1>
            {#if ExportUrl}
                <Button Color="success" on:click={CopyUrl}>Kopieer URL</Button>
            {:else}
                <Button Color="warning" on:click={Close}>Sluiten</Button>
            {/if}
        </div>
    {:else}
        {#if !Loading}
            <div class="financials-input-title">
                <p>Transacties Exporteren</p>
            </div>

            <TextField
                Title="Startdatum"
                bind:RealValue={StartDate}
                Type="date"
            />

            <TextField
                Title="Einddatum"
                bind:RealValue={EndDate}
                Type="date"
            />

            <div class="financials-input-buttons">
                <Button
                    on:click={Close}
                    Color="warning"
                >Annuleren</Button>
                <Button
                    on:click={Export}
                    Color="success"
                >Exporteren</Button>
            </div>
        {:else}
            <div style="display: flex; justify-content: center; align-items: center; height: 20vh; width: 100%;">
                <svg xmlns="http://www.w3.org/2000/svg"
                    xmlns:xlink="http://www.w3.org/1999/xlink" style="margin: auto; background: transparent; display: block; shape-rendering: auto;" width="15vh" height="15vh" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid">
                    <g transform="rotate(0 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.9166666666666666s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(30 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.8333333333333334s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(60 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.75s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(90 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.6666666666666666s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(120 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.5833333333333334s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(150 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.5s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(180 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.4166666666666667s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(210 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.3333333333333333s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(240 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.25s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(270 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.16666666666666666s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(300 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.08333333333333333s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                    <g transform="rotate(330 50 50)">
                        <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                            <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="0s" repeatCount="indefinite"></animate>
                        </rect>
                    </g>
                </svg>
            </div>
        {/if}
    {/if}
</Modal>

<style>
    h1 {
        font-size: 2vh;
        font-weight: bold;
        font-family: Roboto;
        color: white;
        width: 100%;
        text-align: center;
        margin: 1.5vh 0;
    }
</style>