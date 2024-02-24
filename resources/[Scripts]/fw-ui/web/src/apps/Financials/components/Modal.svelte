<div class="financials-input-wrapper">
    <div class="financials-input-container" style={$$restProps.style}>
        <slot/>
    </div>
</div>

<style>
    .financials-input-wrapper {
        position: absolute;
        width: 100%;
        height: 100%;
        z-index: 100;
        background-color: rgba(255, 255, 255, 0.3)
    }

    .financials-input-container {
        position: relative;
        top: 50%;
        left: 0;
        right: 0;
        transform: translateY(-50%);
        clear: both;
        overflow-y: auto;
        margin: 0 auto;
        width: 21%;
        height: max-content;
        max-height: 70%;
        padding: 1.5vh 13.8vh;
        border-radius: 0.4vh;
        background-color: #30475d
    }

    .financials-input-container::-webkit-scrollbar {
        display: none
    }

    :global(.financials-input-title) {
        margin-bottom: 2.5vh;
        width: 100%
    }

    :global(.financials-input-title>p) {
        color: white;
        font-size: 2.2vh;
        letter-spacing: 0;
        font-family: Roboto;
        margin: 0;
        text-align: center
    }

    :global(.financials-input-container > .financials-input-buttons) {
        display: flex;
        justify-content: space-between;
        height: 4vh;
        width: 100%;
        margin-top: 3.5vh
    }
</style>