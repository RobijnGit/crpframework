<script>
    export let Information = [];
</script>

<div on:click on:keyup class="mdw-card-wrapper">
    <div class="mdw-card">
        <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
            {#each Information as Texts, Key}
                <div class="mdw-card-row">
                    {#each Texts as Value}
                        <p>{Value}</p>
                    {/each}
                </div>
            {/each}
        </div>
    </div>
</div>

<style>
    .mdw-card-wrapper {
        display: flex;
        padding: .8vh;
        margin-bottom: .8vh;
        flex-direction: column;
        background-color: rgb(34, 40, 49);
    }

    .mdw-card {
        cursor: pointer;
        display: flex;
        
        font-size: 1.3vh;
        font-family: "Roboto";
        font-weight: 450;
        letter-spacing: 0.0017136vh;
        color: white;
    }

    .mdw-card-row {
        width: 100%;
        display: flex;
        margin-top: .8vh;
        justify-content: space-between;
    }

    .mdw-card-row:first-of-type {
        margin-top: 0;
    }

    .mdw-card-row > p:first-of-type {
        text-align: left !important;
    }

    .mdw-card-row > p:last-of-type {
        text-align: right;
    }
</style>