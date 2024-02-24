<script lang="ts">
    import Ripple from '@smui/ripple';

    type ColorType = 'disabled' | 'default' | 'error' | 'warning' | 'success';
    export var Color: ColorType = 'success';
</script>

<div {...$$restProps} on:keyup on:click use:Ripple={{ surface: true, active: true }} class="ui-button {Color} {$$restProps?.class}">
    <slot></slot>
</div>

<style>
    .ui-button {
        user-select: none;
        
        position: relative;
        float: left;

        width: max-content;
        height: max-content;

        padding: .8vh 1vh;
        border-radius: 0.4vh;

        margin: 0.5vh;

        font-family: 'Roboto';
        font-weight: 500;
        font-size: 1.2vh;
        
        box-shadow: 0.0vh 0.3vh 0.1vh -0.2vh rgb(0 0 0 / 20%), 0.0vh 0.2vh 0.2vh 0.0vh rgb(0 0 0 / 14%), 0.0vh 0.1vh 0.5vh 0.0vh rgb(0 0 0 / 12%);

        letter-spacing: 0.01vh;
        text-transform: uppercase;
        color: rgba(0, 0, 0, 0.87);

        cursor: pointer;

        transition: background-color 250ms;
    }

    .ui-button.disabled { color: rgba(255, 255, 255, 0.25); background-color: rgba(255, 255, 255, 0.12); cursor: not-allowed; }
    .ui-button.default { background-color: #e0e0de }
    .ui-button.error { background-color: #f44336 }
    .ui-button.warning { background-color: #f2a365 }
    .ui-button.success { background-color: #95ef77 }
</style>