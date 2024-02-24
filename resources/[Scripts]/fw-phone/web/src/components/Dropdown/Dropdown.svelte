<script>
    import { clickOutside } from "../../utils/ClickOutside";
    import { SetDropdown } from "../../utils/Utils";

    import { onMount, onDestroy, afterUpdate } from "svelte";
    import { createEventDispatcher } from "svelte";

    export var Value = "";
    export var Options = [];
    export var Positioning = {};

    const Dispatch = createEventDispatcher();

    let DropdownContainer;
    let WindowHeight;
    let WindowWidth;
    let MaxTop;
    let DropdownContainerHeight = 0;

    function handleDropdown() {
        if (!DropdownContainer) return;

        Dispatch("dropdownClosed");
        MaxTop = WindowHeight - DropdownContainerHeight - 25;

        const dropdownWidth = DropdownContainer.offsetWidth;
        const MaxLeft = WindowWidth - dropdownWidth - 25;

        if (Positioning?.Top > MaxTop) {
            DropdownContainer.style.setProperty("top", `${MaxTop}px`);
        } else {
            DropdownContainer.style.setProperty("top", `${Positioning?.Top}px`);
        }
        
        if (Positioning?.Left > MaxLeft) {
            DropdownContainer.style.setProperty("left", `${MaxLeft}px`);
        } else {
            DropdownContainer.style.setProperty("left", `${Positioning?.Left}px`);
        }
    }

    function handleOptionsUpdate() {
        if (!DropdownContainer) return;
        DropdownContainerHeight = DropdownContainer.offsetHeight;
        MaxTop = WindowHeight - DropdownContainerHeight - 25;
        handleDropdown();
    }

    onMount(() => {
        WindowHeight = window.innerHeight;
        WindowWidth = window.innerWidth;
        handleOptionsUpdate();
    });

    afterUpdate(() => {
        handleOptionsUpdate();
    });

    onDestroy(() => {
        DropdownContainer = null;
    });

    $: {
        handleDropdown();
    }
</script>

<div
    use:clickOutside
    on:clickOutside={() => {
        SetDropdown(false);
    }}
    class="dropdown-container"
    style="width: {Positioning?.Width}; top: {Positioning?.Top}px; left: {Positioning?.Left}px;"
    bind:this={DropdownContainer}
>
    {#each Options as Data, Key}
        <div
            on:keyup
            on:click={(e) => {
                Value = Data.Value;
                if (Data.Cb) {
                    if (Data.ValueIsReal) {
                        Data.Cb(Data.Value, Data.Value);
                    } else {
                        Data.Cb(Data.Value || Data.Text, Data.Text);
                    }
                    SetDropdown(false);
                }
            }}
            class="dropdown-option"
        >
            {#if Data.Icon}
                <i class="fas fa-{Data.Icon}" />
            {/if}
            {Data.Text}
        </div>
    {/each}
</div>

<style>
    .dropdown-container {
        position: absolute;

        user-select: none;

        min-width: 10vh;
        height: max-content;
        max-height: 50vh;

        margin-top: 2vh;

        z-index: 999;

        overflow-y: auto;

        padding: 0.8vh 0;

        border-radius: 0.4vh;

        background-color: #2e2e2e;
    }

    .dropdown-container::-webkit-scrollbar {
        display: none;
    }

    .dropdown-option {
        height: 3.3vh;
        line-height: 3.3vh;

        padding-left: 1.5vh;
        padding-right: 1.5vh;

        cursor: pointer;

        font-family: Roboto, Helvetica, Arial, sans-serif;
        font-weight: 400;
        font-size: 1.4vh;

        color: white;
        letter-spacing: 0.035vh;

        text-overflow: ellipsis;
        overflow: hidden;
        white-space: nowrap;
    }

    .dropdown-option > i {
        margin-right: 0.5vh;
    }

    .dropdown-option:hover {
        background-color: #3e3e3e;
    }
</style>
