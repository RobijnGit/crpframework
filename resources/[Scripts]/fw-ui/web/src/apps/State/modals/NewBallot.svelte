<script>
    import { CurrentModal } from "../state.store";
    import Modal from "./Modal.svelte";

    import Button from "../../../lib/Button/Button.svelte";
    import TextField from "../../../lib/TextField/TextField.svelte";
    import Checkbox from "../../../lib/Checkbox/Checkbox.svelte";

    let IsMultipleChoice = false;
    let Nominees = [
        {Name: "", Party: ""},
        {Name: "", Party: ""}
    ];

    let BallotTitle = ''
    let StartDate;
    let EndDate;

    const Cancel = () => {
        CurrentModal.set(false);
    };

    const IsValidDate = (Timestamp, Min, Hours) => {
        const _Date = new Date(Timestamp);
        _Date.setHours(Hours, Min, 1);

        return _Date.getTime() > new Date().getTime()
    }

    const Submit = () => {
        if (BallotTitle.trim().length == 0) return;
        // if (!IsValidDate(StartDate, 0, 1)) return;
        if (!IsValidDate(EndDate, 23, 59)) return;

        // At least 2 nominees?
        if (Nominees[0].Name.trim().length == 0) return;
        if (Nominees[1].Name.trim().length == 0) return;

        const Cb = $CurrentModal?.Cb;
        CurrentModal.set({Type: "Loading"});

        Cb({
            Label: BallotTitle,
            MultipleChoice: IsMultipleChoice,
            StartDate, EndDate,
            Nominees
        });
    };
</script>

<Modal style="width: 70%;">
    <TextField
        Title="Stemming Titel"
        Icon="pencil-alt"
        style="width: 100%;"
        bind:RealValue={BallotTitle}
    />

    <div style="width: 100%; display: flex; justify-content: space-between;">
        <TextField
            Title="Startdatum"
            Icon="calendar-alt"
            Type="date"
            style="width: 49.5%;"
            bind:RealValue={StartDate}
        />
    
        <TextField
            Title="Verloopdatum"
            Icon="calendar-alt"
            Type="date"
            style="width: 49.5%;"
            bind:RealValue={EndDate}
        />
    </div>

    <Checkbox bind:Checked={IsMultipleChoice} Label="Meerkeuze"/>

    <div style="width: 100%; display: flex; justify-content: space-between; align-items: center;">
        <p class="preferences-header">Kandidaten</p>
        <div>
            {#if Nominees.length > 2}
                <Button
                    Color="warning"
                    on:click={() => {
                        Nominees.pop();
                        Nominees = [...Nominees]
                    }}
                >-</Button>
            {/if}

            <Button
                Color="success"
                on:click={() => {
                    Nominees = [...Nominees, {Name: "", Party: ""}]
                }}
            >+</Button>
        </div>
    </div>

    {#each Nominees as Data, Key}
        <div style="margin-bottom: 1vh; width: 100%; display: flex; justify-content: space-between; border-bottom: 0.1vh solid white;">
            <TextField
                Title="Kandidaat"
                Icon="user-graduate"
                MaxLength={50}
                style="width: 49.5%;"
                bind:RealValue={Data.Name}
            />

            <TextField
                Title="Slogan"
                Icon="text"
                MaxLength={255}
                style="width: 49.5%;"
                bind:RealValue={Data.Party}
            />
        </div>
    {/each}

    <div style="margin-top: 2vh; width: 100%; display: flex; justify-content: space-between;">
        <Button
            Color="warning"
            style="margin: 0;"
            on:click={Cancel}
        >Annuleren</Button>
        <Button
            Color="success"
            style="margin: 0;"
            on:click={Submit}
        >Opslaan</Button>
    </div>
</Modal>