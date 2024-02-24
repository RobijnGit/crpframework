<script>
    // import { AddNotification } from "../../../utils/Utils";
    import AppContainer from "./components/AppContainer.svelte";

    // let RandomVideos = [
    //     "dIR3XFuY4Qs", // Trololo Cat
    //     "dQw4w9WgXcQ", // Rick Astley - Never Gonna Give You Up (Official Music Video)
    //     "cFqLEwAvaHI", // Finnegan Fox chats while being scratched
    //     "w7x_lWJNnNg", // Cat has a crazy deep meow
    //     "dmOddwmhFc4", // Stick Roll but with a different link
    //     "f2qNwYUCSH4", // [ASMR] Cute panda eating carrot ~ Powerful Relaxation
    //     "6aocrnaeBhA", // Cat in a bunny costume #shorts
    //     "caYIXWp-Rw4", // reclame - robijn robijntje
    //     "pwMwvuGOsX8", // *Real Video* Woman yelling At a cat meme
    //     "zhJaibTzy9s", // Samson & Gert - De Burgemeester MIX
    //     "DpKWE8dSVW4", // cat reacts to cringe
    //     "ERwHvwsGFoE", // Red Pandas Play in the Snow
    //     "f8mL0_4GeV0", // Metal pipe falling sound effect but it’s more violent
    //     "3lUP0nd3soc", // interstellar hamster
    // ];

    // let VideoId = Math.floor(Math.random() * RandomVideos.length);

    // setTimeout(() => {
    //     if (RandomVideos[VideoId] == "dQw4w9WgXcQ") {
    //         AddNotification("internetexplorer.svg", [], "Interfox Explorer", "Wat een hit.. Vaker doen!")
    //     } else if (RandomVideos[VideoId] == "f2qNwYUCSH4") {
    //         AddNotification("internetexplorer.svg", [], "Interfox Explorer", "Is dit een Salty Panda?")
    //     } else if (RandomVideos[VideoId] == "pwMwvuGOsX8") {
    //         AddNotification("internetexplorer.svg", [], "Interfox Explorer", "Legendes zeggen dat de kat \"Moet jij lekker weten..\" meowde.")
    //     } else if (RandomVideos[VideoId] == "zhJaibTzy9s") {
    //         AddNotification("internetexplorer.svg", [], "Interfox Explorer", "Dit is de échte burgemeester!")
    //     } else if (RandomVideos[VideoId] == "ERwHvwsGFoE") {
    //         AddNotification("internetexplorer.svg", [], "Interfox Explorer", "WAT EEN COETIESSS AWHHH!")
    //     };
    // }, 500);
</script>

<AppContainer class="app-internet-container" AppId="Internet" App="Interfox Explorer">
    <div class="app-container">
        <!-- <iframe title="yeet" style="pointer-events: none; width: 100%; height: 100%;" src="https://www.youtube.com/embed/{RandomVideos[VideoId]}?controls=0&autoplay=1" frameborder="0" allowfullscreen></iframe> -->
        <i style="width: 100%; text-align: center; font-size: 3.6vh; color: rgba(255, 255, 255, 0.5); margin-top: 20vh;" class="fas fa-frown"></i>
        <p style="width: 100%; text-align: center; font-size: 1.8vh; color: rgba(255, 255, 255, 0.5); font-family: Roboto; margin-top: 2vh;">De site die je probeert te bereiken is momenteel niet beschikbaar..</p>
    </div>
</AppContainer>

<style>
    :global(.app-internet-container) {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: #101010 !important;
    }

    .app-container {
        margin: 0 auto;
        width: 100%;
        height: calc(100% - 3vh);
    }
</style>