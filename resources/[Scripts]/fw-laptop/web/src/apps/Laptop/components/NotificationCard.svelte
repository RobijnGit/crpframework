<div {...$$restProps} class="laptop-notification-card {$$restProps?.class}">
    <slot></slot>
</div>

<style>
    .laptop-notification-card {
        position: relative;

        border-radius: 0.5vh;

        width: 100%;
        height: max-content;
        min-height: 6.7vh;

        margin-top: .5vh;

        background-color: rgba(10, 10, 10, 0.3);
        backdrop-filter: blur(.5vh);

        display: flex;
        flex-direction: row;
    }

    .laptop-notification-card.animate-in {
        animation: SlideIn 250ms linear forwards;
    }

    @keyframes SlideIn {
        0% {
            transform: translateX(100%);
        }
        100% {
            transform: translateX(0%);
        }
    }

    .laptop-notification-card.animate-out {
        animation: SlideOut 250ms linear forwards;
    }

    @keyframes SlideOut {
        0% {
            transform: translateX(0%);
        }
        100% {
            transform: translateX(100%);
        }
    }
</style>