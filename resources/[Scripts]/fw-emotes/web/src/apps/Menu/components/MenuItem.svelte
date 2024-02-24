<script>
    export let Text = ["adjust"];
    export let Selected = false;
    export let Special = false;
</script>

<div class="menu-item" class:item-selected={Selected} class:item-blue={Special}>
    {#each Text as Value, Id}
        <p>{Value}</p>
    {/each}
</div>

<style>
    .menu-item {
        position: relative;
        display: flex;
        justify-content: space-between;
        align-items: center;

        padding: 0 1vh;

        width: calc(100% - 2vh);
        height: 2.85vh;

        font-family: Helvetica;
        font-size: 1.5vh;

        color: white;
        text-shadow: .1vh .1vh 0 black;
        letter-spacing: .05vh;
        background-color: rgba(0, 0, 0, 0.35);
    }

    .item-blue {
        background-color: rgba(26, 112, 155, 0.5);
    }

    .menu-item.item-selected {
        background-color: white;
        color: black !important;
        text-shadow: none !important;
    }
</style>