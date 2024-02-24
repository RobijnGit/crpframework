<script>
    export let IsSelected = 0;
    export let Label = "";
    export let Subtext = false;
</script>


<div class="bennys-list-item" class:selected={IsSelected}>
    <div class="bennys-list-text">
        <p>{#if IsSelected} <i class="fas fa-angle-double-right"></i>{/if} {Label}</p>
        {#if Subtext !== undefined && Subtext !== false}
            <p>{Subtext}</p>
        {/if}
    </div>
</div>

<style>
    .bennys-list-item {
        display: flex;
        justify-content: center;

        height: 3.25vh;
    }

    .bennys-list-item:nth-child(odd) {
        background-color: #30475ebe;
    }

    .bennys-list-item.selected {
        color: black;
        background-color: rgb(236, 240, 241);
    }

    .bennys-list-item.selected p {
        font-weight: 400;
    }

    .bennys-list-item > .bennys-list-text {
        width: 92%;

        font-weight: 300;
        font-style: normal;
        font-size: 1.7vh;

        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .bennys-list-item > .bennys-list-text > p {
        margin: 0;
        padding: 0;
    }

</style>