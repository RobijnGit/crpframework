<div {...$$restProps} class="mdw-box-title">
    <slot></slot>
</div>

<style>
    .mdw-box-title {
        display: flex;
        justify-content: space-between;

        position: relative;
        left: 0;
        right: 0;

        margin: 0 auto;

        width: 96.8%;
        height: 5.2vh;
    }

    :global(.mdw-box-title > h6) {
        font-size: 1.9vh;
        font-family: Roboto;
        font-weight: 500;
        
        line-height: 1.6;
        letter-spacing: 0.012vh;
        
        color: white;
        margin: 0;
        margin-top: 0.6vh;
    }

    :global(.mdw-box-title > .textfield-component-container) {
        margin-top: .7vh;
        width: 40%;
    }

    :global(.mdw-box-title > .mdw-box-title-icons) {
        display: flex;
        margin-top: 0.7vh;
        font-size: 1.8vh;
        color: white
    }

    :global(.mdw-box-title > .mdw-box-title-icons > i) {
        margin-left: .5vh
    }
</style>