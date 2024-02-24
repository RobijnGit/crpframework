<script>
    import AppWrapper from "../../components/AppWrapper.svelte";
    import { OnEvent, SetExitHandler } from "../../utils/Utils";
    import FlipBook from "./components/FlipBook.svelte";

    let Visible = false;

    SetExitHandler("", "Books/Close", () => Visible, {__resource: "fw-books"})

    let PageWidth = 0;
    let PageHeight = 0;

    // const Pages = [
    //     "https://i.imgur.com/zmrMEJT.png",
    //     "https://i.imgur.com/LfIhjt9.png",
    //     "https://i.imgur.com/JQmB311.png",
    //     "https://i.imgur.com/Xq5VTCq.png",
    //     "https://i.imgur.com/60AhPeq.png",
    //     "https://i.imgur.com/tgeA9Km.png"
    // ]

    const GetImageMeta = (Url) => {
        return new Promise((res, rej) => {
            let img = new Image();
            img.onload = () => res(img);
            img.onerror = () => rej(error);
            img.src = Url;
        });
    };

    let Pages = [];
    OnEvent("Books", "OpenBook", async ({Images}) => {
        const Image = await GetImageMeta(Images[0]);
        if (!Image) return;

        PageWidth = Image.naturalWidth;
        PageHeight = Image.naturalHeight;

        // Define max constrains here, in case if the user changes display settigs.
        const MaxWidth = window.innerWidth * 0.48;
        const MaxHeight = window.innerHeight * 0.9;

        if (PageWidth > MaxWidth || PageHeight > MaxHeight) {
            const Ratio = Math.min(MaxWidth / PageWidth, MaxHeight / PageHeight);
            PageWidth = Math.round(PageWidth * Ratio);
            PageHeight = Math.round(PageHeight * Ratio);
        };

        Pages = [];
        for (let i = 0; i < Images.length; i++) {
            Pages.push(`<div key="page_${i}">
                <img src="${Images[i]}" width="${PageWidth}" height="${PageHeight}" alt="page" />
            </div>`);
        };

        Visible = true;
    });

    OnEvent("Books", "CloseBook", () => {
        Visible = false;
        Pages = [];
        PageWidth = 0;
        PageHeight = 0;
    });

</script>

<AppWrapper AppName="Books" Focused={Visible}>
    {#if Visible}
        <div class="books-container" style="height: {PageHeight}px; width: {PageWidth * 2}px">
            <FlipBook
                width={PageWidth}
                height={PageHeight}
                size="fixed"
                maxShadowOpacity={0.3}
                showCover={true}
                images={Pages}
            />
        </div>
    {/if}
</AppWrapper>

<style>
    .books-container {
        position: absolute;
        top: 50%;
        left: 50%;

        transform: translate(-50%, -50%);
    }
</style>