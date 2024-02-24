<div {...$$restProps} class="phone-paperlist {$$restProps.class}">
    <slot></slot>
</div>

<style>
    .phone-paperlist {
        overflow-y: auto;
        position: absolute;
        left: 0;
        right: 0;
        top: 9.7vh;
        margin: 0 auto;
        width: 89%;
        height: 46.5vh;
    }

    .phone-paperlist::-webkit-scrollbar {
        display: none;
    }
</style>