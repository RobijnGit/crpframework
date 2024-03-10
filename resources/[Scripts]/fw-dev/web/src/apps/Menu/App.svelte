<script>
    import { OnEvent } from "../../utils/Utils";
    import { EntityButtons } from "../../config";
    import MenuItem from "./MenuItem.svelte";

    let IsVisible = false;
    let EntityDetails = [];
    let CurrentEntityType = '';

    OnEvent("Menu/ToggleMenu", (Data) => {
        IsVisible = Data.Visibility;
    });

    OnEvent("Menu/SetEntityDetails", (Data) => {
        EntityDetails = Data.EntityDetails;
    });

    OnEvent("Menu/SetEntityType", (Data) => {
        CurrentEntityType = Data.Type;
    });
</script>

{#if IsVisible && EntityButtons[CurrentEntityType]}
    <div class="menu-wrapper">
        <div class="menu-header">
            <p style="text-align: center">{EntityDetails.ModelName || "NULL"}</p>

            <div class="details">
                {#each EntityDetails.Details as Data, Key}
                    <div class="row">
                        <p>{Data[0]}</p>
                        <p>{Data[1]}</p>
                    </div>
                {/each}
            </div>
        </div>
        <div class="menu-seperator" />
        <div class="menu-buttons">
            {#each EntityButtons[CurrentEntityType] as Data, Key}
                <MenuItem {...Data} />
            {/each}
        </div>
    </div>
{/if}


<style lang="scss">
    .menu-wrapper {
        position: absolute;
        right: 42.5vh;
        top: 30%;
        bottom: 0;

        display: flex;
        flex-direction: column;
        align-items: center;

        width: 25vh;
        height: max-content;
        max-height: 60vh;

        overflow: auto;

        padding: 1vh;
        border-radius: 0.5vh;

        background-color: rgba(255, 255, 255, 0.1);

        &::-webkit-scrollbar {
            display: none;
        }

        .menu-seperator {
            width: 100%;
            height: .2vh;
            background-color: rgba(0, 0, 0, 0.75);

            margin: .5vh 0;
        }

        .menu-header {
            font-family: Roboto;
            font-size: 1.25vh;

            text-shadow: black -0.1vh 0.1vh 0, black 0.1vh 0.1vh 0, black 0.1vh -0.1vh 0, black -0.1vh -0.1vh 0;

            color: white;

            width: 100%;

            .details {
                display: none;
                width: 100%;

                margin-top: .5vh;
                padding: .5vh 0;

                background-color: rgba(0, 0, 0, 0.1);

                .row {
                    display: flex;
                    justify-content: space-between;
                    width: 80%;
                    margin: 0 auto;
                }
            }

            &:hover > .details {
                display: block;
            }
        }

        .menu-buttons {
            width: 100%;
        }
    }
</style>