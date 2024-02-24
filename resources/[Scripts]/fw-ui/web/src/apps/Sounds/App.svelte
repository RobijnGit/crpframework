<script>
    import { onMount } from "svelte";
    import { PlaySound, StopSound } from "./Utils.js";

    onMount(() => {
        window.addEventListener("message", function (event) {
            switch (event.data.action) {
                case "PlaySound":
                    PlaySound(event.data.SoundId, event.data.Volume);
                    break;
                case "StopSound":
                    StopSound();
                    break;
            }
        });
    });
</script>