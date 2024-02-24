<div class="modal-wrapper">
    <div {...$$restProps} class="modal-container">
        <slot/>
    </div>
</div>

<style>
    .modal-wrapper {
        position: absolute;
        top: 0;
        left: 0;

        width: 100%;
        height: 100%;

        background-color: rgba(0, 0, 0, 0.3);

        display: flex;
        justify-content: center;
        align-items: center;

        z-index: 1;
    }

    .modal-container {
        width: 47%;
        height: max-content;
        max-height: 70%;
        padding: 1.5vh;
        background-color: #30475d;
        overflow-y: auto;
    }

    .modal-container::-webkit-scrollbar { display: none }
</style>