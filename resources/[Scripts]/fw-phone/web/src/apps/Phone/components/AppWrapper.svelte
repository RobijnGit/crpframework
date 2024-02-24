<script>
    import { fade } from "svelte/transition";
</script>

<div {...$$restProps} in:fade={{ duration: 250 }} class="phone-app-wrapper {$$restProps?.class}">
    <slot/>
</div>

<style>
    .phone-app-wrapper {
        color: white;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: #222832;
    }
</style>
