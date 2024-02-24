<div {...$$restProps} class="laptop-notification-card-icon {$$restProps?.class}">
    <slot></slot>
</div>

<style>
    .laptop-notification-card-icon {
        width: 3vh;
        height: 3vh;

        min-width: 3vh;

        margin: auto 0;
        margin-left: 1.3vh;
        
        font-family: Roboto;
        font-size: 1.5vh;

        line-height: 3vh;
        text-align: center;

        border-radius: .5vh;

        display: flex;
        justify-content: center;
        align-items: center;
    }
</style>