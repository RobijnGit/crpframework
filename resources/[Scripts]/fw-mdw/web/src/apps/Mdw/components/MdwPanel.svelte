<div {...$$restProps} class="mdw-box-container {$$restProps.class}">
    <slot></slot>
</div>

<style>
    .mdw-box-container {
        width: 33.15%;
        height: 100%;
        margin-right: .5vh;
        overflow-y: auto
    }

    .mdw-box-container::-webkit-scrollbar {
        display: none;
    }

    .mdw-box-container.filled {
        background-color: #1f3a57;
    }
</style>