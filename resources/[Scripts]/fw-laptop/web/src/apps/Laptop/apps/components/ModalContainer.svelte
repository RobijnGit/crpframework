<div class="laptop-modal-wrapper">
    <div {...$$restProps} class="laptop-modal-container {$$restProps?.class}">
        <slot></slot>
    </div>
</div>

<style>
    .laptop-modal-wrapper {
        position: absolute;
        top: 0;
        left: 0;

        clear: both;

        width: 100%;
        height: 100%;

        z-index: 999;

        background-color: rgba(0, 0, 0, 0.5);
    }

    .laptop-modal-container {
        position: absolute;
        top: 50%;
        left: 50%;

        width: max-content;
        max-width: 15%;
        height: max-content;
        max-height: 27vh;

        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: #0b0d11;
    }
</style>