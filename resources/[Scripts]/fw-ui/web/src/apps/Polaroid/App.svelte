<script>
    import AppWrapper from "../../components/AppWrapper.svelte";
    import { OnEvent, SetExitHandler } from "../../utils/Utils";
    import Camera from "./layers/Camera.svelte";
    import PhotoViewer from "./layers/PhotoViewer.svelte";
    import Photobook from "./layers/Photobook.svelte";
    import { IsEditingPhoto } from "./polaroid.store";

    let IsBinderVisible = false;
    let IsCameraVisible = false;
    let PhotoViewerVisible = false;

    let FilmsLeft;
    let ViewerTimeout;
    let PhotoData = {};
    let Photos = [];

    OnEvent("Polaroid", "SetBinderVisibility", (Data) => {
        IsBinderVisible = Data.Visible;
        Photos = Data.Photos;
    });

    OnEvent("Polaroid", "SetCameraVisibility", (Data) => {
        IsCameraVisible = Data.Visible;
        FilmsLeft = Data.FilmsLeft;
    });

    OnEvent("Polaroid", "ShowPhoto", (Data) => {
        if (ViewerTimeout) clearTimeout(ViewerTimeout);

        PhotoData = Data.Photo;
        PhotoViewerVisible = true;

        ViewerTimeout = setTimeout(() => {
            PhotoViewerVisible = false;
        }, 5000)
    });

    SetExitHandler("", "Polaroid/Close", () => {
        if ($IsEditingPhoto) {
            IsEditingPhoto.set(false);
            return false;
        };
        return IsBinderVisible
    }, {__resource: "fw-polaroid"});
</script>

<AppWrapper AppName="Polaroid" Focused={IsBinderVisible}>
    {#if IsCameraVisible}
        <Camera bind:FilmsLeft={FilmsLeft}/>
    {/if}

    {#if PhotoViewerVisible}
        <PhotoViewer {...PhotoData} />
    {/if}

    {#if IsBinderVisible}
        <Photobook bind:Photos={Photos}/>
    {/if}
</AppWrapper>