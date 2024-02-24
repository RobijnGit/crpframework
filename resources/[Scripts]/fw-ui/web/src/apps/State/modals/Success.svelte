<script>
    import { onMount } from "svelte";
    import { CurrentModal } from "../state.store";
    import Modal from "./Modal.svelte";

    onMount(() => {
        setTimeout(() => {
            CurrentModal.set({});
        }, 1500);
    });
</script>

<Modal>
    <div style="display: flex; justify-content: center; align-items: center; height: 10vh; width: 100%;">
        <div class="checkmark-container">
            <div style="width: 6vh; height: 6vh" class="circle"></div>
            <svg fill="#fff" class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30" width="3vh" height="3vh">
                <path d="M 28.28125 6.28125 L 11 23.5625 L 3.71875 16.28125 L 2.28125 17.71875 L 10.28125 25.71875 L 11 26.40625 L 11.71875 25.71875 L 29.71875 7.71875 Z"></path>
            </svg>
        </div>
    </div>
</Modal>

<style>
    .checkmark-container {
        animation: CheckmarkScale .3s ease-in-out .9s both
    }

    .checkmark-container .circle {
        display: block;
        width: 5.6vh;
        height: 5.6vh;
        margin: 10% auto;
        border-radius: 50%;
        box-shadow: inset 0 0 0 #009688;
        animation: CheckmarkFill .4s ease-in-out .4s forwards
    }

    .checkmark-container .checkmark {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%) scale(0.0);
        animation: CheckmarkShow .3s ease-in-out .9s forwards
    }

    @keyframes CheckmarkShow {
        from { transform: translate(-50%, -50%) scale(0.0) }
        to { transform: translate(-50%, -50%) scale(1.0) }
    }

    @keyframes CheckmarkFill {
        to { box-shadow: inset 0 0 0 3vh #009688 }
    }

    @keyframes CheckmarkScale {
        0%, to { transform: none }
        50% { transform: scale(1.1) }
    }
</style>