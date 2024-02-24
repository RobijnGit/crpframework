<script>
    import { fade } from "svelte/transition";
    import PolaroidPhoto from "./PolaroidPhoto.svelte";

    export let Image;
    export let Date;
    export let Description;
</script>

<div
    class="polaroid-photo-viewer"
    transition:fade={{duration: 450}}
>
    <PolaroidPhoto {Image} {Date} RotateText={true}>{Description || ""}</PolaroidPhoto>
</div>

<style>
    .polaroid-photo-viewer {
        position: absolute;
        top: 28vh;
        left: 2.13vh;

        width: 35.73vh;
        height: 43.9vh;
    }
</style>