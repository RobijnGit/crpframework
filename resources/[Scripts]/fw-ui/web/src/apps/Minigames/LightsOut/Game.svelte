<script>
    import { onMount } from "svelte";
    import { PlaySound, StopSound } from "../../Sounds/Utils";
    import { Delay, OnEvent, SendEvent } from "../../../utils/Utils";

    const GameData = {
        Active: false,
        GameId: 0,
        GridSize: 4,
        BaseSize: 14 * 4,
        EnabledBlocks: 0,
        SecondsToFinish: 30,
    }

    let MinigameVisible = false;
    let Blocks = [];
    let GridData = {};

    let ShowMessage = false;
    let MessageIcon;
    let Message;

    const StartMinigame = async (Amount, HasBuff) => {
        if (Amount < 4) Amount = 4;
        if (Amount % 2 == 1) {
            SendEvent("Minigames/LightsOut/Finished", { Success: false })
            MinigameVisible = false;
            return 
        };

        Blocks = [];

        GameData.GridSize = Amount;
        GameData.EnabledBlocks = 0;
        
        var GameId = Math.floor(Math.random() * 1000000);
        GameData.GameId = GameId;
        
        MinigameVisible = true;
        SetMessage('database', 'Gegevens beschadigd, reparatie van controlesom vereist..');
        const Board = GenerateBoard(Amount);
        await Delay(3);
        ClearMessage();

        GridData.Size = GameData.BaseSize / Amount;
        GridData.Margin = GridData.Size / 10;

        // Fill Blocks array.
        for (let i = 0; i < Board.length; i++) {
            const Row = Board[i];
            for (let j = 0; j < Row.length; j++) {
                Blocks.push(Row[j]);
            };
        };

        const SecondsToFinish = HasBuff ? 20 : 10
        GameData.Active = true;

        await Delay(SecondsToFinish * (Amount == 4 ? 1 : 2))

        if (GameData.Active && GameData.GameId == GameId) {
            const HasWon = await CheckForWin();
            if (HasWon) return;

            SetMessage("database", "Gegevensherstel mislukt");
            await Delay(2)
            ClearMessage();
            MinigameVisible = false;

            GameData.Active = false;
            GameData.GameId = 0;

            SendEvent("Minigames/LightsOut/Finished", { Success: false })
        }
    };

    const SetMessage = (Icon, Msg) => {
        MessageIcon = Icon;
        Message = Msg;
        ShowMessage = true;
    };

    const ClearMessage = () => {
        ShowMessage = false;
    };

    const CheckForWin = async () => {
        if (GameData.GridSize ** 2 > GameData.EnabledBlocks) {
            PlaySound("beep-fail", .2)
            return false
        };

        PlaySound("beep-success", .2)

        GameData.Active = false;
        GameData.GameId = 0;

        SetMessage("database", "Gegevensherstel geslaagd");
        await Delay(2)
        ClearMessage();
        MinigameVisible = false;

        SendEvent("Minigames/LightsOut/Finished", { Success: true })
        return true;
    }

    const GenerateBoard = (Amount) => {
        var Board = []
        for (var i = 0; i < Amount; i++) Board.push(new Array(Amount).fill(0));

        return Shuffle(Board, 2 * (Amount * 2) + 1)
    }

    const Shuffle = (Board, AmountsOfShuffle) => {
        do {
            for (let i = 1; i <= AmountsOfShuffle; i++) {
                var a = Math.floor(Math.random() * Board.length);
                var b = Math.floor(Math.random() * Board[0].length);
                Board = ChangeState(Board, a, b);
            }
        } while (IsWin(Board))

        return Board
    }

    const IsWin = Board => {
        return Board.every(line => !line.includes(1))
    }

    const ChangeState = (Board, i, j)  => {
        Board[i][j] = (Board[i][j] + 1) % 2
        if (Board[i + 1] !== undefined) Board[i + 1][j] = (Board[i + 1][j] + 1) % 2;
        if (Board[i - 1] !== undefined) Board[i - 1][j] = (Board[i - 1][j] + 1) % 2;
        if (Board[i][j + 1] !== undefined) Board[i][j + 1] = (Board[i][j + 1] + 1) % 2;
        if (Board[i][j - 1] !== undefined) Board[i][j - 1] = (Board[i][j - 1] + 1) % 2;
        return Board
    };

    const ToggleLights = (BlockIndex) => {
        const BlockIds = [
            BlockIndex,
            BlockIndex + GameData.GridSize,
            BlockIndex - GameData.GridSize,
        ]

        if (BlockIndex % GameData.GridSize != GameData.GridSize - 1) BlockIds.push(BlockIndex + 1);
        if (BlockIndex % GameData.GridSize != 0) BlockIds.push(BlockIndex - 1);

        for (let i = 0; i < BlockIds.length; i++) {
            if (Blocks[BlockIds[i]] != undefined) {
                Blocks[BlockIds[i]] = !Blocks[BlockIds[i]];
            };
        }

        // Reactivity.
        Blocks = [...Blocks];

        GameData.EnabledBlocks = Blocks.filter(Val => Val == true).length;
        CheckForWin();
    };

    OnEvent("Minigames/LightsOut", "StartMinigame", (Data) => {
        StartMinigame(Data.Amount, Data.HasBuff);
    });
</script>

{#if MinigameVisible}
    <div class="lights-out-container">
        {#if ShowMessage}
            <div class="lights-out-container-center">
                <i class="fas fa-{MessageIcon}"></i>
                <p>{Message}</p>
            </div>
        {:else}
            <div
                class="lights-out-grid"
                style="
                    grid-template-columns: repeat({GameData.GridSize}, {GridData.Size}vh);
                    grid-column-gap: {GridData.Margin}vh;
                    grid-template-rows: repeat({GameData.GridSize}, {GridData.Size}vh);
                    grid-row-gap: {GridData.Margin}vh;
                "
            >
                {#each Blocks as IsEnabled, Key}
                    <div
                        class="lights-out-block"
                        class:lights-out-block-enabled={IsEnabled}
                        style="width: {GridData.Size}vh; height: {GridData.Size}vh;"
                        on:keyup on:click={() => ToggleLights(Key)}
                    />
                {/each}
            </div>
        {/if}
    </div>
{/if}

<style>
    .lights-out-container {
        position: absolute;
        top: 50%;
        left: 50%;

        transform: translate(-50%, -50%);

        min-width: 60vh;
        width: max-content;
        min-height: 60vh;
        height: max-content;

        padding: 2vh;

        background-color: #222832;
    }

    .lights-out-container-center {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);

        text-align: center;
        color: white;
        
        font-family: Roboto;
        font-size: 1.3vh;

        width: max-content;
        height: max-content;
    }

    .lights-out-container-center > i {
        font-size: 4.5vh;
        margin-bottom: 1vh;
    }

    .lights-out-grid {
        display: grid;
        grid-template-columns: repeat(4, 14vh);
        grid-template-rows: repeat(4, 14vh);
        grid-column-gap: 1vh;
        grid-row-gap: 1vh;
    }

    .lights-out-row {
        display: flex;
        width: 100%;
        justify-content: space-between;
        height: max-content;
    }

    .lights-out-block {
        cursor: pointer;
        width: 14vh;
        height: 14vh;
        background-color: #094e1c;
        border-radius: 0.2vh;
        transition: background-color ease-in-out 50ms;
    }

    .lights-out-block-enabled {
        background-color: #3cec54;
    }
</style>