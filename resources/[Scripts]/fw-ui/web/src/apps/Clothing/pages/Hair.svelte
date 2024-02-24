<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardValue from "../components/CardValue.svelte";
    import { ComponentsValues, HairPalette } from "../clothing.store";
    import CardSlider from "../components/CardSlider.svelte";
</script>

<!-- Hair -->
<ClothingTab
    Title="Haar"
    AmountComponents={$ComponentsValues?.Hair?.MaxComps}
    AmountTextures={$ComponentsValues?.Hair?.MaxTxts}
    HasPalette={true}
    PaletteColors={HairPalette}
    PaletteId="Hair"
>
    <CardValue componentId="Hair" valueType="Drawable"/>
    <CardValue componentId="Hair" valueType="Texture"/>
</ClothingTab>

<!-- Fade -->
<ClothingTab
    Title="Fade"
    DisableTextureField={true}
>
    <div style="width: 100%;"> <!-- margin-bottom: 0.2vh -->
        <CardValue componentId="Fade" valueType="Drawable"/>
    </div>
</ClothingTab>

<!-- Eyebrows -->
<ClothingTab
    Title="Wenkbrauwen"
    AmountComponents={$ComponentsValues?.Eyebrows?.MaxComps}
    DisableTextureField={true}
    HasPalette={true}
    PaletteColors={HairPalette}
    PaletteId="Eyebrows"
    DisableHighlight={true}
>
    <CardValue componentId="Eyebrows" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="Eyebrows" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Facial Hair -->
<ClothingTab
    Title="Gezichtshaar"
    AmountComponents={$ComponentsValues?.Beard?.MaxComps}
    DisableTextureField={true}
    HasPalette={true}
    PaletteColors={HairPalette}
    PaletteId="Beard"
    DisableHighlight={true}
>
    <CardValue componentId="Beard" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="Beard" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Chest Hair -->
<ClothingTab
    Title="Borsthaar"
    AmountComponents={$ComponentsValues?.ChestHair?.MaxComps}
    DisableTextureField={true}
    HasPalette={true}
    PaletteColors={HairPalette}
    PaletteId="ChestHair"
    DisableHighlight={true}
>
    <CardValue componentId="ChestHair" valueType="Drawable"/>
    <CardSlider label="Opacity" componentId="ChestHair" valueId={1} style="width: 48.5%;"/>
</ClothingTab>