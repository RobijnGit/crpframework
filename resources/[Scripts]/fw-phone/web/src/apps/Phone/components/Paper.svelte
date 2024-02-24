<script>
    export let Icon = false;
    export let Title = "";
    export let Description = "";
    export let DescriptionHtml = false;
    export let Aux = "";
    export let Notification = false;

    export let HasActions = false;
    export let HasDrawer = false;

    let ShowDrawer = false;
    const ToggleDrawer = (event) => {
        const PhoneCardDrawer = document.querySelector('.phone-card-drawer');
        if (event.target === PhoneCardDrawer || (PhoneCardDrawer && PhoneCardDrawer.contains(event.target))) return;
        ShowDrawer = !ShowDrawer;
    }
</script>

{#if !HasDrawer}
    <div class="phone-card-component" on:keyup on:click>
        {#if Notification}
            <div class="phone-card-notification phone-card-notification__{Notification}"></div>
        {/if}

        <div class="phone-card-container">
            {#if Icon}
                <div class="phone-card-icon">
                    <i class="fas fa-{Icon}" />
                </div>
            {/if}
            <div class="phone-card-details">
                <div class="phone-card-text">
                    {#if Array.isArray(Title)}
                        {#each Title as item}
                            <p>{item}</p>
                        {/each}
                    {:else}
                        <p>{Title}</p>
                    {/if}
                </div>
                <div class="phone-card-text">
                    {#if Array.isArray(Description)}
                        {#each Description as item}
                            {#if DescriptionHtml}
                                <p>{@html item}</p>
                            {:else}
                                <p>{item}</p>
                            {/if}
                        {/each}
                    {:else}
                        {#if DescriptionHtml}
                            <p>{@html Description}</p>
                        {:else}
                            <p>{Description}</p>
                        {/if}
                    {/if}
                </div>
                
            </div>
            {#if Aux}
                <div class="phone-car-details phone-card-details-aux">
                    <div class="phone-card-text">
                        <p>{Aux}</p>
                    </div>
                </div>
            {/if}

            {#if HasActions && $$slots.default}
                <div class="phone-card-actions">
                    <slot />
                    <!-- <i data-tooltip="Yeet" class="tooltip fas fa-user-slash" /> -->
                </div>
            {/if}
        </div>
    </div>
{:else}
    <div class="phone-card-component" on:keyup on:click={ToggleDrawer}>
        {#if Notification}
            <div class="phone-card-notification phone-card-notification__{Notification}"></div>
        {/if}

        <div class="phone-card-container">
            {#if Icon}
                <div class="phone-card-icon">
                    <i class="fas fa-{Icon}" />
                </div>
            {/if}
            <div class="phone-card-details">
                <div class="phone-card-text">
                    {#if Array.isArray(Title)}
                        {#each Title as item}
                            <p>{item}</p>
                        {/each}
                    {:else}
                        <p>{Title}</p>
                    {/if}
                </div>
                <div class="phone-card-text">
                    {#if Array.isArray(Description)}
                        {#each Description as item}
                            <p>{item}</p>
                        {/each}
                    {:else}
                        <p>{Description}</p>
                    {/if}
                </div>
                
            </div>
            {#if Aux}
                <div class="phone-car-details phone-card-details-aux">
                    <div class="phone-card-text">
                        <p>{Aux}</p>
                    </div>
                </div>
            {/if}

        </div>

        {#if ShowDrawer}
            <div class="phone-card-drawer">
                <slot />
            </div>
        {/if}
    </div>
{/if}

<style>
    :global(.phone-card-component) {
        position: relative;
        width: calc(100% - 1.6vh);
        background-color: #30475e;
        border-bottom: 0.1vh solid #c8c6ca;
        border-top-left-radius: 0.4vh;
        border-top-right-radius: 0.4vh;
        padding: 0.8vh;
        margin-bottom: 0.8vh;
        color: #e0e0e0;
    }

    :global(.phone-card-notification) {
        position: absolute;
        top: 0.8vh;
        right: 0.8vh;
        width: 0.8vh;
        height: 0.8vh;
        background-color: #69cbd3;
        border-radius: 100%;
    }

    :global(.phone-card-notification__green) {
        background-color: #4cae54;
    }

    :global(.phone-card-notification__red) {
        background-color: #e84c3d;
    }

    :global(.phone-card-container) {
        display: flex;
        width: 100%;
    }

    :global(.phone-card-icon) {
        font-size: 4vh;
        width: 5.4vh;
        height: 4vh;
        margin-right: 0.8vh;
    }

    :global(.phone-card-icon > i) {
        width: 100%;
        text-align: center;
        vertical-align: 0.2vh;
        display: inline-block;
    }

    :global(.phone-card-details) {
        position: relative;
        display: flex;
        flex-direction: column;
        align-content: space-between;
        justify-content: space-between;
        flex: 1 1;
        overflow: hidden;
    }

    :global(.phone-card-details .phone-card-text) {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
    }

    :global(.phone-card-details .phone-card-text > p) {
        display: -webkit-box;
        -webkit-line-clamp: 1;
        -webkit-box-orient: vertical;
        font-size: 1.4vh;
        letter-spacing: -0.035vh;
        text-overflow: ellipsis;
        overflow: hidden;
    }

    :global(.phone-card-details-aux) {
        display: flex;
        align-items: center;
        font-size: 1.4vh;
        letter-spacing: -0.035vh;
    }

    :global(.phone-card-actions) {
        display: none;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(1, 1, 1, 0.75);
        justify-content: center;
        align-items: center;
        border-radius: 0.4vh;
    }

    :global(.phone-card-component:hover .phone-card-actions) {
        display: flex;
    }

    :global(.phone-card-actions > i) {
        color: #e0e0e0;
        margin: 0.8vh 0.8vh 0;
        font-size: 1.8vh;
    }

    :global(.phone-card-drawer) {
        display: flex;
        flex-direction: column;
        padding: 0.8vh 1.2vh 0;
        color: #c8c6ca;
    }

    :global(.phone-card-drawer-item) {
        padding: 0.4vh 0;
        display: flex;
        align-items: center;
        margin-bottom: 0.8vh;
        border-bottom: 0.1vh solid #c8c6ca;
        text-shadow: 0.1vh 0.1vh black;
        font-size: 1.4vh;
    }

    :global(.phone-card-drawer-item > i) {
        width: 2vh;
        margin-right: 0.8vh;
        stroke: black;
        stroke-width: 4;
        text-align: center;
    }
</style>
