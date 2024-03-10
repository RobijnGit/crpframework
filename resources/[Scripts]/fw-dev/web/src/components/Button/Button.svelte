<script>
    import './Button.css';
    import Ripple from '@smui/ripple';

    export var Color = 'primary';
</script>


<div {...$$restProps} on:keyup on:click use:Ripple={{ surface: true, active: true }} class="ui-button {Color} {$$restProps?.class}">
    <slot></slot>
</div>