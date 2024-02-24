<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardSlider from "../components/CardSlider.svelte";
    import CardValue from "../components/CardValue.svelte";
    import { ComponentsValues } from "../clothing.store";
</script>

<!-- Face One -->
<ClothingTab
    Title="Gezicht Een"
    AmountTextures={$ComponentsValues?.FaceOne?.MaxTxts}
    DisableTextureField={true}
    style="padding-bottom: 1vh;"
>
    <CardValue componentId="FaceOne" valueType="Drawable" />
    <CardValue componentId="FaceOne" valueType="Texture" />
</ClothingTab>

<!-- Face Two -->
<ClothingTab
    Title="Gezicht Twee"
    AmountTextures={$ComponentsValues?.FaceTwo?.MaxTxts}
    DisableTextureField={true}
    style="padding-bottom: 1vh;"
>
    <CardValue componentId="FaceTwo" valueType="Drawable"/>
    <CardValue componentId="FaceTwo" valueType="Texture"/>
</ClothingTab>

<!-- Face Three -->
<ClothingTab
    Title="Gezicht Drie"
    AmountTextures={$ComponentsValues?.FaceThree?.MaxTxts}
    DisableTextureField={true}
    style="padding-bottom: 1vh;"
>
    <CardValue componentId="FaceThree" valueType="Drawable"/>
    <CardValue componentId="FaceThree" valueType="Texture"/>
</ClothingTab>

<!-- Face Mix -->
<ClothingTab
    Title="Gezichts Mix"
    DisableTextureField={true}
>
    <CardSlider min={0} max={100} componentId="FaceMix" style="width: 100%" />
</ClothingTab>

<!-- Skin Mix -->
<ClothingTab
    Title="Huidskleur Mix"
    DisableTextureField={true}
>
    <CardSlider min={0} max={100} componentId="SkinMix" style="width: 100%" />
</ClothingTab>

<!-- Third Face Mix -->
<ClothingTab
    Title="Derde Gezicht Mix"
    DisableTextureField={true}
>
    <CardSlider min={0} max={100} componentId="ThirdFaceMix" style="width: 100%" />
</ClothingTab>