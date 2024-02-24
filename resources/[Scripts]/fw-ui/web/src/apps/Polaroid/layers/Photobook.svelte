<script>
    import { OnEvent } from "../../../utils/Utils";
    import PhotobookEdit from "../modals/Photobook.Edit.svelte";
    import { IsEditingPhoto } from "../polaroid.store";
    import PolaroidPhoto from "./PolaroidPhoto.svelte";

    export let Photos = [];

    let EditingPolaroidData;

    OnEvent("Polaroid", "SetBinderPhotos", (Data) => {
        Photos = Data.Photos;

        if ($IsEditingPhoto) {
            const NewEditingPolaroid = Data.Photos[EditingPolaroidData.PhotoId];
            EditingPolaroidData = { ...NewEditingPolaroid, PhotoId: EditingPolaroidData.PhotoId };
        };
    });
</script>

<div class="polaroid-binder">
    <div class="polaroid-binder-photos">
        {#each Photos as Data, Key}
            <PolaroidPhoto
                ShowTape={true}
                RotateText={true}
                on:click={() => {
                    EditingPolaroidData = {...Data, PhotoId: Key};
                    IsEditingPhoto.set(true);
                }}
                {...Data}
            >
                {#if Data.Description}
                    {Data.Description}
                {/if}
            </PolaroidPhoto>
        {/each}
    </div>
</div>

{#if $IsEditingPhoto}
    <PhotobookEdit
        bind:PolaroidData={EditingPolaroidData}
    />
{/if}

<style>
    .polaroid-binder {
        position: absolute;
        top: 50%;
        left: 50%;

        width: 133.34vh;
        height: 90vh;

        border-radius: 1vh;

        background-color: rgba(255, 255, 255, 0.5);

        transform: translate(-50%, -50%);
    }

    .polaroid-binder-photos {
        position: absolute;
        top: 50%;
        left: 50%;

        padding: 3vh;

        width: 90%;
        height: 86%;

        display: grid;
        grid-column-gap: 10vh;
        grid-row-gap: 4vh;
        grid-template-columns: 18% 18% 18% 18%;

        overflow-y: auto;
        overflow-x: hidden;

        transform: translate(-50%, -50%);
    }

    .polaroid-binder-photos::-webkit-scrollbar { display: none }

    :global(.polaroid-binder-photos > .polaroid-photo) {
        position: relative !important;

        border-radius: 0 !important;

        width: 24.89vh !important;
        min-height: 33vh !important;
        height: max-content !important;

        float: left !important;
    }

    :global(.polaroid-binder-photos > .polaroid-photo > .polaroid-image) {
        max-height: 22vh !important;
    }

    :global(.polaroid-binder-photos > .polaroid-photo > .polaroid-text) {
        font-size: 1.3vh !important;
    }
</style>