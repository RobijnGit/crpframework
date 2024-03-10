<script>
    import Button from "../../../components/Button/Button.svelte"
    import Checkbox from "../../../components/Checkbox/Checkbox.svelte";
    import { PermissionsLocale } from "../../../config";
    import { MdwModalsPermissions } from "../../../stores";

    let Permissions = Object.entries($MdwModalsPermissions.Role.permissions);
    Permissions = Permissions.sort((a, b) => a[0].localeCompare(b[0]));
</script>

<div class="mdw-modal-permissions">
    <div class="mdw-modal-permissions-container">
        <p>Edit Permissions</p>

        <div class="mdw-modal-permissions-grid">
            {#each Permissions as [Key, Data]}
                {#if $MdwModalsPermissions.Role}
                    <Checkbox Title={PermissionsLocale[Key] || Key} bind:Checked={$MdwModalsPermissions.Role.permissions[Key]} />
                {/if}
            {/each}
        </div>

        <div style="width: 50%; display: flex; justify-content: space-between; margin: 0 auto; margin-top: 2.4vh;">
            <Button Color="success" click={() => {
                const Cb = $MdwModalsPermissions.Cb
                MdwModalsPermissions.set({ Show: false });
                Cb($MdwModalsPermissions.Role.permissions)
            }}>Opslaan</Button>
            <Button Color="warning" click={() => {
                MdwModalsPermissions.set({
                    Show: false,
                    Role: false,
                    Cb: () => {}
                })
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-permissions {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-permissions-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 30%;
        height: max-content;
        max-height: 70vh;
        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49);

        overflow-y: auto;
    }

    .mdw-modal-permissions-container::-webkit-scrollbar {
        display: none;
    }

    .mdw-modal-permissions-grid {
        display: grid;
        grid-template-columns: repeat(2, 50%);
        grid-gap: 1vh;
        width: 100%;
    }

    .mdw-modal-permissions-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }
</style>