<script>
    import { ImageHoverData } from "../../../stores";
    export let Source = "https://media.tenor.com/FawYo00tBekAAAAC/loading-thinking.gif";

    let innerWidth = 0, innerHeight = 0;
    let HoverElement;

    const GetImageDimensions = () => {
        return new Promise(Res => {
            var img = new Image();
            img.addEventListener("load", function(){
                Res([this.naturalWidth, this.naturalHeight]);
            });
            img.src = Source;
        });
    };

    const MouseEnter = async () => {
        let [Width, Height] = await GetImageDimensions();
        let elemRect = HoverElement.getBoundingClientRect();

        let MaxWidth = 100;
        if (Width > (innerWidth * 0.8)) {
            const Reduction = (innerWidth * 0.8) / Width;
            MaxWidth = Reduction * 100;

            // Reduce twice, first is to 'fit to screen', then reduce it to MaxWidth of img.
            Width = (Width * Reduction) * Reduction;
            Height = (Height * Reduction) * Reduction;
        };

        let TopPosition = elemRect.top - Height - elemRect.height;
        let LeftPosition = elemRect.left - (Width / 2) + (elemRect.width / 2);

        if (TopPosition < 21) TopPosition = 21;
        if (TopPosition > innerHeight) TopPosition = innerHeight - Height - 21;

        if (LeftPosition < 21) LeftPosition = 21;
        if (LeftPosition > innerWidth) LeftPosition = innerWidth - Width - 21;

        ImageHoverData.set({
            Show: true,
            Source,
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

<div bind:this={HoverElement} on:mouseenter={MouseEnter} on:mouseleave={MouseLeave}>
    <slot></slot>
</div>