<script>
    export let Icon = false;
    export let Title = "";
    export let Description = "";
    export let DescriptionHtml = false;
    export let Aux = "";
    export let Notification = false;
    export let Drawers = [];

    export let HasActions = false;
    export let HasDrawer = false;

    let ShowDrawer = false;
    const ToggleDrawer = (event) => {
        const PhoneCardDrawer = document.querySelector('.phone-card-drawer');
        const PhoneCardActions = document.querySelector('.phone-card-actions');

        if (event.target === PhoneCardDrawer || (PhoneCardDrawer && PhoneCardDrawer.contains(event.target))) return;
        if (HasActions && event.target != PhoneCardActions && PhoneCardActions.contains(event.target)) return;

        ShowDrawer = !ShowDrawer;
    }
</script>

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
            </div>
        {/if}
    </div>

    {#if HasDrawer && ShowDrawer}
        <div class="phone-card-drawer">
            {#each Drawers as Data, Id}
                <div class="phone-card-drawer-item">
                    <i class="fas fa-{Data[0]}"/>
                    <p>{@html Data[1]}</p>
                </div>
            {/each}
        </div>
    {/if}
</div>

<style>
    .phone-card-text > p {
        -webkit-line-clamp: unset !important;
        overflow-wrap: break-word !important;
    }
</style>