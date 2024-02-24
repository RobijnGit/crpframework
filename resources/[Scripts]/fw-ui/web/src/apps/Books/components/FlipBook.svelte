<script>
    import { PageFlip } from "page-flip"; // https://github.com/Nodlik/StPageFlip
    import { onMount } from "svelte";

    export let width = "";
    export let height = "";
    export let size = "fixed"; // fixed | stretched
    export let minWidth = 0;
    export let maxWidth = 0;
    export let minHeight = 0;
    export let maxHeight = 0;
    export let drawShadow = true;
    export let flippingTime = 1000;
    export let usePortrait = true;
    export let startZIndex = 0;
    export let autoSize = true;
    export let maxShadowOpacity = 1;
    export let showCover = false;
    export let mobileScrollSupport = true;
    export let onFlip = false;
    export let onChangeOrientation = false;
    export let onChangeState = false;
    export let onInit = false;
    export let onUpdate = false;
    export let htmlElementRef;
    export let images = [];

    export let pageFlipRef;

    const removeHandlers = () => {
        if (!pageFlipRef) return;

        pageFlipRef.off('flip');
        pageFlipRef.off('changeOrientation');
        pageFlipRef.off('changeState');
        pageFlipRef.off('init');
        pageFlipRef.off('update');
    }

    const setHandlers = () => {
        if (!pageFlipRef) return;

        if (onFlip) {
            pageFlipRef.on("flip", (e) => onFlip(e))
        };

        if (onChangeOrientation) {
            pageFlipRef.on("changeOrientation", (e) => onChangeOrientation(e))
        };

        if (onChangeState) {
            pageFlipRef.on("changeState", (e) => onChangeState(e))
        };

        if (onInit) {
            pageFlipRef.on("init", (e) => onInit(e))
        };

        if (onUpdate) {
            pageFlipRef.on("update", (e) => onUpdate(e))
        };
    };

    onMount(() => {
        if (!htmlElementRef) {
            throw new Error("Failed to load Book! ('htmlElementRef' cannot be undefined)")
        }

        pageFlipRef = new PageFlip(htmlElementRef, {
            width,
            height,
            size,
            minWidth,
            maxWidth,
            minHeight,
            maxHeight,
            drawShadow,
            flippingTime,
            usePortrait,
            startZIndex,
            autoSize,
            maxShadowOpacity,
            showCover,
            mobileScrollSupport
        });

        removeHandlers();

        const parser = new DOMParser();
        const pageElements = images.map((html) => parser.parseFromString(html, "text/html").body.firstChild);

        if (!pageFlipRef.getFlipController()) {
            pageFlipRef.loadFromHTML(pageElements)
        } else {
            pageFlipRef.updateFromHtml(pageElements)
        };

        return () => {
            pageFlipRef.destroy();
        }
    });
</script>

<div bind:this={htmlElementRef} class={$$restProps?.class} style={$$restProps?.style}/>