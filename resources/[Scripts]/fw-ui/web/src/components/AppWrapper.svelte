<script>
    import { Delay, IsEnvBrowser } from "../utils/Utils";
    import { Boundary } from "./Boundary";

    export let AppName = 'Undefined';
    export let Focused = false;

    const handleError = async (pError) => {
        console.log("------- UI ERROR -------");
        console.log(pError);
        console.log("------------------------");
        localStorage.setItem("isUiCrashed", "yes")
        localStorage.setItem("crashedAppName", AppName)

        if (IsEnvBrowser()) await Delay(1.5);

        window.location.reload();
    };
</script>


<Boundary onError={handleError}>
    <div
        class="app-wrapper"
        style="pointer-events: {Focused ? "unset" : "none"}; {$$restProps?.style || ""}"
    >
        <slot/>
    </div>
</Boundary>

<style>
    .app-wrapper {
        position: absolute;
        top: 0;
        left: 0;

        width: 100vw;
        height: 100vh;
    }
</style>