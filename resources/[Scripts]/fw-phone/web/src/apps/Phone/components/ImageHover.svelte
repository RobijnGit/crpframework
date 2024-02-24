<script>
    import { ImageHoverData } from "../../../stores";
    import { CopyToClipboard } from "../../../utils/Utils";

    export let Url = '';
    let ImageElement;

    let innerWidth = 0,
        innerHeight = 0;

    const GetImageDimensions = () => {
        return new Promise((Res) => {
            var img = new Image();
            img.addEventListener("load", function () {
                Res([this.naturalWidth, this.naturalHeight]);
            });
            img.src = Url;
        });
    };

    const EnlargeImage = async () => {
        let [Width, Height] = await GetImageDimensions();
        let elemRect = ImageElement.getBoundingClientRect();

        CopyToClipboard(Url);

        let MaxWidth = 100;
        if (Width > innerWidth * 0.8) {
            const Reduction = (innerWidth * 0.8) / Width;
            MaxWidth = Reduction * 100;

            // Reduce twice, first is to 'fit to screen', then reduce it to MaxWidth of img.
            Width = Width * Reduction * Reduction;
            Height = Height * Reduction * Reduction;
        }

        let TopPosition = elemRect.top + elemRect.height / 2 - Height / 2;
        let LeftPosition = elemRect.left - Width - 30;

        if (TopPosition < 0) TopPosition = 0;
        if (TopPosition + Height > innerHeight) TopPosition = innerHeight - Height;
        if (LeftPosition < 0) LeftPosition = 0;
        if (LeftPosition + Width > innerWidth) LeftPosition = innerWidth - Width;

        ImageHoverData.set({
            Show: true,
            Source: Url,
            Top: TopPosition,
            Left: LeftPosition,
            MaxWidth: MaxWidth,
        });
    };

    const MouseLeave = () => {
        ImageHoverData.set({ Show: false, Source: "", Top: 0, Left: 0 });
    };
</script>

<svelte:window bind:innerWidth bind:innerHeight />

<div
    {...$$restProps}
    class="image {$$restProps.class}"
    bind:this={ImageElement}
    on:mouseleave={MouseLeave}
    on:keyup
    on:click={EnlargeImage}
    style="background-image: url({Url});"
/>
