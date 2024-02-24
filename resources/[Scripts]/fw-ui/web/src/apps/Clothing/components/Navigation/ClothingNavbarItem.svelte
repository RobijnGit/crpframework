<script>
    export let TabId = "";
    export let Tooltip = "";

    import { CurrentTab } from "../../clothing.store"

</script>

{#if !Tooltip}
    <div class="clothing-navbar-item">
        <slot/>
    </div>
{:else}
    <div
        data-tooltip={Tooltip}
        data-position="left"
        class="clothing-navbar-item"
        class:active={$CurrentTab == TabId}
        on:keyup on:click={() => CurrentTab.set(TabId)}
    >
        <slot/>
    </div>
{/if}

<style>
    .clothing-navbar-item {
        display: flex;
        justify-content: center;
        align-items: center;

        width: 100%;
        height: 5.2vh;
    }

    .clothing-navbar-item.active {
        background-color: rgb(34, 40, 49);
    }
</style>