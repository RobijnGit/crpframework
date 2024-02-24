<script>
    import { CurrentTab } from "../state.store.js";

    export let Id = '';
    export let Name = '';
</script>

<div
    class="navbar-item"
    class:active={$CurrentTab == Id}
    on:keyup on:click={() => CurrentTab.set(Id)}
>
    <p>{Name}</p>
</div>

<style>
    .navbar-item {
        width: 100%;
        height: 5.1vh;
        display: flex;
        cursor: pointer;
        align-items: center;
    }

    .navbar-item.active {
        background-color: rgb(34, 40, 49);
    }

    .navbar-item > p {
        margin: 0;
        letter-spacing: 0.014vh;
        line-height: 1.25vh;
        font-size: 1.5vh;
        font-family: "Roboto", "Helvetica", "Arial", sans-serif;
        font-weight: 400;
        padding-left: 1.5vh;
    }
</style>