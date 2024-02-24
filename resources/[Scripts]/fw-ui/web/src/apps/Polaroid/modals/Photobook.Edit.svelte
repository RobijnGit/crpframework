<script>
    import Button from "../../../lib/Button/Button.svelte";
    import TextArea from "../../../lib/TextArea/TextArea.svelte";
    import { SendEvent as _SendEvent } from "../../../utils/Utils";
    import PolaroidPhoto from "../layers/PolaroidPhoto.svelte";
    import { IsEditingPhoto } from "../polaroid.store";
    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-polaroid");

    export let PolaroidData = {};

    let EditDescription = false;
    let Description = '';

    const SaveDescription = () => {
        SendEvent("Polaroid/SetPhotoDescription", {
            PhotoId: PolaroidData.PhotoId,
            Description: Description,
        }, () => {
            EditDescription = false;
        });
    };

    const Share = () => {
        SendEvent("Polaroid/SharePhoto", {PhotoId: PolaroidData.PhotoId}, () => {});
    };

    const MoveToInventory = () => {
        SendEvent("Polaroid/MoveToInventory", {PhotoId: PolaroidData.PhotoId}, () => {});
        IsEditingPhoto.set(false);
    };

    const Delete = () => {
        SendEvent("Polaroid/Delete", {PhotoId: PolaroidData.PhotoId}, () => {});
        IsEditingPhoto.set(false);
    };
</script>

<div class="polaroid-binder-edit-container">
    <div class="polaroid-binder-edit">

        {#if EditDescription}
            <div class="polaroid-edit-description">
                <div class="polaroid-edit-description-header">Foto Beschrijving</div>
                <div class="polaroid-edit-description-subheader">Beschrijving is permanent en kan niet aangepast worden.</div>

                <TextArea
                    Title="Beschrijving"
                    MaxLength={200}
                    Rows={2}
                    bind:Value={Description}
                />

                <div class="polaroid-edit-description-buttons">
                    <Button
                        Color="warning"
                        on:click={() => EditDescription = false}
                    >Annuleren</Button>
                    <Button
                        Color="success"
                        on:click={() => SaveDescription()}
                    >Opslaan</Button>
                </div> 
            </div>
        {/if}

        <PolaroidPhoto
            RotateText={PolaroidData.Description}
            {...PolaroidData}
        >
            {#if PolaroidData.Description}
                {PolaroidData.Description}
            {:else}
                <Button
                    Color="warning"
                    style="border-radius: 2vh; left: 50%; transform: translateX(-50%)"
                    on:click={() => EditDescription = true}
                ><i class="fas fa-pen-alt"/> Beschrijving Toevoegen</Button>
            {/if}
        </PolaroidPhoto>

        <div class="polaroid-binder-edit-options">
            <Button
                Color="success"
                style="border-radius: 2vh;"
                on:click={() => Share()}
            ><i class="fas fa-share"/> Delen</Button>
            <Button
                Color="warning"
                style="border-radius: 2vh;"
                on:click={() => MoveToInventory()}
            ><i class="fas fa-archive"/> Verplaats naar Inventaris</Button>
            <Button
                Color="error"
                style="border-radius: 2vh;"
                on:click={() => Delete()}
            ><i class="fas fa-trash"/> Verwijderen</Button>
        </div>
    </div>
</div>

<style>
    .polaroid-binder-edit-container {
        position: absolute;

        width: 100%;
        height: 100%;

        background-color: rgba(0, 0, 0, 0.5);
    }

    .polaroid-binder-edit {
        position: absolute;
        top: 50%;
        left: 50%;

        transform: translate(-50%, -50%);
    }

    :global(.polaroid-binder-edit > .polaroid-photo) {
        width: 40vw !important;
        height: 80vh !important;

        border-radius: 0 !important;
    }

    :global(.polaroid-binder-edit > .polaroid-photo > .polaroid-date) {
        width: 95% !important;
    }

    :global(.polaroid-binder-edit > .polaroid-photo > .polaroid-image) {
        max-height: 67.5vh !important;
        width: 95% !important;
    }

    :global(.polaroid-binder-edit > .polaroid-photo > .polaroid-text) {
        font-size: 1.5vh !important;
    }

    .polaroid-binder-edit-options {
        position: absolute;
        left: 50%;

        width: max-content;

        transform: translateX(-50%);
    }

    .polaroid-edit-description {
        position: absolute;

        z-index: 10;

        padding: 1.5vh 1vw;

        background-color: #222831;

        top: 50%;
        left: 50%;

        width: 35.55vh;
        height: max-content;

        transform: translate(-50%, -50%);
    }

    .polaroid-edit-description-header {
        font-family: Roboto;
        font-weight: 600;
        font-size: 1.5vh;
        
        color: white;

        margin-bottom: 1vh;
    }

    .polaroid-edit-description-subheader {
        font-family: Roboto;
        font-size: 1.2vh;
        
        color: rgba(255, 255, 255, 0.5);

        margin-bottom: 1.5vh;
    }

    .polaroid-edit-description-buttons {
        position: relative;
        float: right;

        width: max-content;
    }
</style>