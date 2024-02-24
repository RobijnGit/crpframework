<script>
    export var Checked = false;
    export var click = () => {}

    var ChangeCheckbox = () => {
        Checked = !Checked;
        click();
    }
</script>

<div {...$$restProps} class="voting-checkbox-container {$$restProps?.class}">
    <label on:change on:keyup on:click={ChangeCheckbox} for="" class="voting-checkbox" style="width: auto; max-width: max-content;">
        <span class="voting-checkbox-root {Checked ? 'voting-checkbox-active': ''}" aria-disabled="false">
            <span class="voting-checkbox-label">
                {#if Checked}
                    <input class="voting-checkbox-input" type="checkbox" data-indeterminate="false" value="" checked>
                    <svg class="voting-checkbox-icon" focusable="false" viewBox="0 0 24 24" aria-hidden="true"><path d="M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2V5c0-1.1-.89-2-2-2zm-9 14l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"></path></svg>
                {:else}
                    <input class="voting-checkbox-input" type="checkbox" data-indeterminate="false" value="">
                    <svg class="voting-checkbox-icon" focusable="false" viewBox="0 0 24 24" aria-hidden="true"><path d="M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2V5c0-1.1-.89-2-2-2zm-9 9z"></path></svg>
                {/if}
            </span>
        </span>
    </label>
</div>

<style>
    .voting-checkbox-container {
        border: 0;
        margin: 0;
        display: inline-flex;
        padding: 0;
        position: relative;
        min-width: 0;
        flex-direction: column;
        vertical-align: top;
    }

    .voting-checkbox-container,
    .voting-checkbox {
        color: rgba(255, 255, 255, 0.7) !important;
        border-color: rgba(255, 255, 255, 0.7) !important;
    }

    .voting-checkbox {
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        margin-left: -1.1vh;
        margin-right: 1.6vh;
        vertical-align: middle;
        -webkit-tap-highlight-color: transparent;
    }

    .voting-checkbox-root {
        color: inherit;
        border: 0;
        cursor: pointer;
        margin: 0;
        display: inline-flex;
        outline: 0;
        padding: 0;
        position: relative;
        align-items: center;
        user-select: none;
        border-radius: 0;
        vertical-align: middle;
        -moz-appearance: none;
        justify-content: center;
        text-decoration: none;
        background-color: transparent;
        -webkit-appearance: none;
        -webkit-tap-highlight-color: transparent;

        flex: 0 0 auto;
        color: #fff;
        overflow: visible;
        font-size: 2.4vh;
        text-align: center;
        transition: background-color 150ms cubic-bezier(0.4, 0, 0.2, 1) 0ms;
        /* border-radius: 50%; */
        margin-top: -.5vh;
        margin-right: .4vh;

        color: #f7f7f9;
    }

    .voting-checkbox-label {
        width: 100%;
        display: flex;
        align-items: inherit;
        justify-content: inherit;
    }

    .voting-checkbox-input {
        top: 0;
        left: 0;
        width: 100%;
        cursor: inherit;
        height: 100%;
        margin: 0;
        opacity: 0;
        padding: 0;
        z-index: 1;
        position: absolute;
        ;
    }

    .voting-checkbox-icon {
        fill: currentColor;
        width: 6.5vh;
        height: 6.5vh;
        display: inline-block;
        font-size: 2vh;
        transition: fill 200ms cubic-bezier(0.4, 0, 0.2, 1) 0ms;
        flex-shrink: 0;
        user-select: none;
    }
</style>