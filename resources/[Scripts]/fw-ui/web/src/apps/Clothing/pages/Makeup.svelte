<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardValue from "../components/CardValue.svelte";
    import CardSlider from "../components/CardSlider.svelte";
    import { MakeupPalette, ComponentsValues } from "../clothing.store";
</script>

<!-- Makeup -->
<ClothingTab
    Title="Makeup"
    AmountComponents={$ComponentsValues?.Makeup?.MaxComps}
    DisableTextureField={true}
    HasPalette={true}
    PaletteColors={MakeupPalette}
    PaletteId="Makeup"
>
    <CardValue componentId="Makeup" valueType="Drawable" minValue={-1}/>
    <CardSlider label="Opacity" componentId="Makeup" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Blush -->
<ClothingTab
    Title="Blush"
    AmountComponents={$ComponentsValues?.Blush?.MaxComps}
    DisableTextureField={true}
    HasPalette={true}
    PaletteColors={MakeupPalette}
    PaletteId="Blush"
    DisableHighlight={true}
>
    <CardValue componentId="Blush" valueType="Drawable" minValue={-1}/>
    <CardSlider label="Opacity" componentId="Blush" valueId={1} style="width: 48.5%;"/>
</ClothingTab>

<!-- Lipstick -->
<ClothingTab
    Title="Lipstick"
    AmountComponents={$ComponentsValues?.Lipstick?.MaxComps}
    DisableTextureField={true}
    HasPalette={true}
    PaletteColors={MakeupPalette}
    PaletteId="Lipstick"
    DisableHighlight={true}
>
    <CardValue componentId="Lipstick" valueType="Drawable" minValue={-1}/>
    <CardSlider label="Opacity" componentId="Lipstick" valueId={1} style="width: 48.5%;"/>
</ClothingTab>