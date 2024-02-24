<script>
    import { onMount } from "svelte";
    import { FocusedApp, CurrentApps } from "../../../../stores";

    import Ripple from '@smui/ripple';

    export let AppId = "";
    export let App = "";
    export let HideTopbar = false;

    const CloseApp = () => {
        CurrentApps.set($CurrentApps.filter(Val => Val.Id != AppId));
        if ($CurrentApps.length > 0) {
            FocusedApp.set($CurrentApps[$CurrentApps.length - 1].Id)
        } else {
            FocusedApp.set(false);
        };
    };

    const SetFocusedApp = () => {
        FocusedApp.set(AppId)
    }

    let innerWidth = 0
    let innerHeight = 0
    
    let DraggingApp = false;
    let Left = 0;
    let Top = 0;

    // center shit dud
    onMount(() => {
        Left = innerWidth * 0.0753749999;
        Top = innerHeight * 0.0851851852;
    })

	const onMouseDown = () => {
		DraggingApp = true;
	}
	
	const onMouseMove = e => {
		if (!DraggingApp) return;

        Left += e.movementX;
        Top += e.movementY;

        if (Left < 0) Left = 0;
        if (Top < 0) Top = 0;
	}
	
	const onMouseUp = () => {
		DraggingApp = false;
	}
</script>

<svelte:window bind:innerWidth bind:innerHeight />

<div {...$$restProps} on:mousedown={SetFocusedApp} class="laptop-app-container {$$restProps?.class}" style="left: {Left}px; top: {Top}px; z-index: {$FocusedApp == AppId ? 10 : 1}; {$$restProps?.style}">
    {#if !HideTopbar}
        <div class="app-topbar" on:mousedown={onMouseDown} on:mouseup={onMouseUp} on:mouseleave={onMouseUp} on:mousemove={onMouseMove}>
            <p>{App}</p>
            <div style="display: flex;">
                <div use:Ripple={{ surface: true, active: true }} style="background-color: #ffbe68;" class="app-topbar-button"></div>
                <div use:Ripple={{ surface: true, active: true }} on:keyup on:click={CloseApp} style="background-color: #fc6359;" class="app-topbar-button"></div>
            </div>
        </div>
    {/if}

    <slot></slot>
</div>

<style>
    .laptop-app-container {
        position: absolute;
        top: 92px;
        left: 162px;

        width: 120.3vh;
        height: 67.3vh;

        background-color: white;
        box-shadow: 0 0 2vh 0 rgba(0,0,0,0.75);
    }

    .app-topbar {
        display: flex;
        justify-content: space-between;
        height: 3vh;
        width: 100%;
        background-color: #21211f;

        cursor: grab;
    }

    .app-topbar > p {
        padding-left: 1vh;
        
        font-family: Roboto;
        font-weight: bold;
        font-size: 1.25vh;
        
        color: white;
        line-height: 3vh;
    }

    .app-topbar .app-topbar-button {
        padding: .8vh 1vh;

        height: 0;
        width: .1vh;
        
        cursor: pointer;

        margin: auto 0;
        margin-right: 1vh;

        border-radius: 1vh;
    }
</style>