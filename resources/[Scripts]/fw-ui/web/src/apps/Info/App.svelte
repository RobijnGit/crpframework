<script>
    import { OnEvent } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let ShowInfo = false;
    let Title = '';
    let Description= [];
    let ResetTimeout;

    OnEvent("Info", "ShowInfo", (Data) => {
        if (ResetTimeout) clearTimeout(ResetTimeout);
        ShowInfo = true;
        Title = Data.Title;
        Description = Data.Items;
    });

    OnEvent("Info", "HideInfo", () => {
        ShowInfo = false;
        ResetTimeout = setTimeout(() => {
            Title = '';
            Description = [];
        }, 500);
    });
</script>

<AppWrapper AppName="Info" Focused={false}>
    <div class="info-container" class:info-up={ShowInfo}>
        <p class="info-title">{Title}</p>
        <div class="info-description">
            {#each Description as Data, Id}
                <p>{@html Data.Text}</p>
            {/each}
        </div>
    </div>
</AppWrapper>

<style>
    .info-container {
        position: absolute;
        bottom: -10vh;
        left: 50%;

        min-width: 19.4vh;
        min-height: 7vh;

        max-width: 50vh;
        max-height: 20vh;

        padding: 1.2vh 3vh .5vh;

        border: 0.1vh solid black;

        background-color: #222832;
        color: white;

        font-family: Roboto;
        font-size: 1.87vh;
        transform: translateX(-50%);

        transition: bottom ease 500ms;
    }

    .info-container.info-up {
        bottom: 0;
    }

    .info-container > .info-title {
        font-weight: 700;
        margin-bottom: 1vh;
    }

    .info-container > .info-description > p {
        font-size: 1.52vh;
        margin-bottom: .7vh;
    }
</style>