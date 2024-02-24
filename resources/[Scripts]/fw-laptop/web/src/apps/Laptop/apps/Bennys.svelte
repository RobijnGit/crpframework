<script>
    import AppContainer from "./components/AppContainer.svelte";
</script>

<AppContainer class="app-bennys-container" AppId="Bennys" App="Bennys Online Shop">
    <div class="app-container">
        <h1>Coming Soon...</h1>
    </div>
</AppContainer>

<style>
    :global(.app-bennys-container) {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: #101010 !important;
    }

    .app-container {
        margin: 0 auto;
        width: 80%;
        height: calc(100% - 3vh);
    }

    .app-container > h1 {
        text-align: center;
        font-family: Roboto;
        font-weight: bold;
        font-size: 5vh;
        line-height: 64vh;
        color: rgba(255, 255, 255, 0.3);
    }
</style>