<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardValue from "../components/CardValue.svelte";
    import { ComponentsValues, HairPalette } from "../clothing.store"
</script>

<!-- Hat -->
{#if $ComponentsValues?.Hat?.MaxComps > 0}
    <ClothingTab
        Title="Hoed"
        AmountComponents={$ComponentsValues?.Hat?.MaxComps}
        AmountTextures={$ComponentsValues?.Hat?.MaxTxts}
    >
        <CardValue componentId="Hat" valueType="Drawable" minValue={-1}/>
        <CardValue componentId="Hat" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Hair -->
{#if $ComponentsValues?.Hair?.MaxComps > 0}
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
{/if}

<!-- Jacket -->
{#if $ComponentsValues?.Jacket?.MaxComps > 0}
    <ClothingTab
        Title="Jas"
        AmountComponents={$ComponentsValues?.Jacket?.MaxComps}
        AmountTextures={$ComponentsValues?.Jacket?.MaxTxts}
    >
        <CardValue componentId="Jacket" valueType="Drawable"/>
        <CardValue componentId="Jacket" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Undershirt -->
{#if $ComponentsValues?.Undershirt?.MaxComps > 0}
    <ClothingTab
        Title="Ondershirt"
        AmountComponents={$ComponentsValues?.Undershirt?.MaxComps}
        AmountTextures={$ComponentsValues?.Undershirt?.MaxTxts}
    >
        <CardValue componentId="Undershirt" valueType="Drawable"/>
        <CardValue componentId="Undershirt" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Arms / Gloves -->
{#if $ComponentsValues?.Arms?.MaxComps > 0}
    <ClothingTab
        Title="Armen / Handschoenen"
        AmountComponents={$ComponentsValues?.Arms?.MaxComps}
        AmountTextures={$ComponentsValues?.Arms?.MaxTxts}
    >
        <CardValue componentId="Arms" valueType="Drawable"/>
        <CardValue componentId="Arms" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Pants -->
{#if $ComponentsValues?.Pants?.MaxComps > 0}
    <ClothingTab
        Title="Broeken"
        AmountComponents={$ComponentsValues?.Pants?.MaxComps}
        AmountTextures={$ComponentsValues?.Pants?.MaxTxts}
    >
        <CardValue componentId="Pants" valueType="Drawable"/>
        <CardValue componentId="Pants" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Shoes -->
{#if $ComponentsValues?.Shoes?.MaxComps > 0}
    <ClothingTab
        Title="Schoenen"
        AmountComponents={$ComponentsValues?.Shoes?.MaxComps}
        AmountTextures={$ComponentsValues?.Shoes?.MaxTxts}
    >
        <CardValue componentId="Shoes" valueType="Drawable"/>
        <CardValue componentId="Shoes" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Decals -->
{#if $ComponentsValues?.Decals?.MaxComps > 0}
    <ClothingTab
        Title="Decals"
        AmountComponents={$ComponentsValues?.Decals?.MaxComps}
        AmountTextures={$ComponentsValues?.Decals?.MaxTxts}
    >
        <CardValue componentId="Decals" valueType="Drawable"/>
        <CardValue componentId="Decals" valueType="Texture"/>
    </ClothingTab>
{/if}