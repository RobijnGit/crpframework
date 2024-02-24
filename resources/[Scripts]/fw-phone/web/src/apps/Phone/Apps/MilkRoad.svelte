<script>
    import { SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal } from "../phone.stores";

    import AppWrapper from "../components/AppWrapper.svelte";
    import Paper from "../components/Paper.svelte";
    import PaperList from "../components/PaperList.svelte";

    let Products = [];

    const PurchaseItem = (Id) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Bevestig Aankoop",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            OnSubmit: () => {
                LoaderModal.set(true);
                SendEvent("MilkRoad/PurchaseProduct", {Id}, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
    
                    if (Data.Success) {
                        ShowSuccessModal();
                        return;
                    };
    
                    InputModal.set({
                        Visible: true,
                        Inputs: [
                            {
                                Type: "Text",
                                Text: Data.Msg,
                                Data: {
                                    style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                                },
                            },
                        ],
                        Buttons: [
                            {
                                Color: "success",
                                Text: "Okay",
                                Cb: () => {},
                            },
                        ]
                    })
    
                })
            }
        })
    };

    SendEvent("MilkRoad/GetProducts", {}, (Success, Data) => {
        if (!Success) return;
        Products = Data;
    });
</script>

<AppWrapper>
    <PaperList style="top: 3vh; height: 53.5vh;">
        {#each Products as Data, Id}
            <Paper
                HasActions={true}
                Title={Data.Label}
                Description="{Data.Costs.Amount} {Data.Costs.Label}"
                Icon={Data.Icon}
            >
                <i data-tooltip="Kopen" class="fas fa-hand-holding-usd" on:keyup on:click={() => { PurchaseItem(Data.Id) }} />
            </Paper>
        {/each}
    </PaperList>
</AppWrapper>
