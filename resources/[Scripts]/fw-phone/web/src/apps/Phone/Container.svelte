<script>
    import Android from "./Brands/Android.svelte"
    import Iphone from "./Brands/Iphone.svelte"
    import Notifications from "./Notifications.svelte";
    import { Brand } from "./phone.stores";

    export let isBurner = false;
    export let backgroundOverride = false;
</script>

<div {...$$restProps} class="phone-container {$$restProps.class}">
    {#if $Brand == 'Android'}
        <Android {backgroundOverride}>
            {#if !isBurner} <Notifications/> {/if}
            <slot></slot>
        </Android>
    {:else if $Brand == 'iOS'}
        <Iphone {backgroundOverride}>
            {#if !isBurner} <Notifications/> {/if}
            <slot></slot>
        </Iphone>
    {/if}
</div>

<style>
    .phone-container {
        position: absolute;
        bottom: -70vh;
        right: 0vh;
        transition: bottom 800ms ease 0s
    }

    .phone-debug {
        position: absolute;
        top: 85%;
        left: -30%;

        transform: translate(-50%, -50%) scale(1.5);
    }

    .phone-container.phone-visible {
        bottom: 0vh;
        transition: bottom 800ms ease 0s
    }

    .phone-container.phone-half {
        bottom: -51vh;
        transition: none
    }

    .phone-container.phone-hidden {
        bottom: -70vh;
        transition: bottom 800ms ease 0s
    }
</style>