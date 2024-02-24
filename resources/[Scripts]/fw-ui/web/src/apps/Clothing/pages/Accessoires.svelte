<script>
    import ClothingTab from "../components/ClothingTab.svelte";
    import CardValue from "../components/CardValue.svelte";
    import { ComponentsValues } from "../clothing.store";
</script>

<!-- Masks -->
{#if $ComponentsValues?.Masks?.MaxComps > 0}
    <ClothingTab
        Title="Maskers"
        AmountComponents={$ComponentsValues?.Masks?.MaxComps}
        AmountTextures={$ComponentsValues?.Masks?.MaxTxts}
    >
        <CardValue componentId="Masks" valueType="Drawable"/>
        <CardValue componentId="Masks" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Glasses -->
{#if $ComponentsValues?.Glasses?.MaxComps > 0}
    <ClothingTab
        Title="Brillen"
        AmountComponents={$ComponentsValues?.Glasses?.MaxComps}
        AmountTextures={$ComponentsValues?.Glasses?.MaxTxts}
    >
        <CardValue componentId="Glasses" valueType="Drawable"/>
        <CardValue componentId="Glasses" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Earrings -->
{#if $ComponentsValues?.Earrings?.MaxComps > 0}
    <ClothingTab
        Title="Oorbellen"
        AmountComponents={$ComponentsValues?.Earrings?.MaxComps}
        AmountTextures={$ComponentsValues?.Earrings?.MaxTxts}
    >
        <CardValue componentId="Earrings" valueType="Drawable" minValue={-1}/>
        <CardValue componentId="Earrings" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Scarfs & Necklaces -->
{#if $ComponentsValues?.Scarfs?.MaxComps > 0}
    <ClothingTab
        Title="Sjaals en kettingen"
        AmountComponents={$ComponentsValues?.Scarfs?.MaxComps}
        AmountTextures={$ComponentsValues?.Scarfs?.MaxTxts}
    >
        <CardValue componentId="Scarfs" valueType="Drawable"/>
        <CardValue componentId="Scarfs" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Watches -->
{#if $ComponentsValues?.Watches?.MaxComps > 0}
    <ClothingTab
        Title="Horloges"
        AmountComponents={$ComponentsValues?.Watches?.MaxComps}
        AmountTextures={$ComponentsValues?.Watches?.MaxTxts}
    >
        <CardValue componentId="Watches" valueType="Drawable" minValue={-1}/>
        <CardValue componentId="Watches" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Bracelets -->
{#if $ComponentsValues?.Bracelets?.MaxComps > 0}
    <ClothingTab
        Title="Armbanden"
        AmountComponents={$ComponentsValues?.Bracelets?.MaxComps}
        AmountTextures={$ComponentsValues?.Bracelets?.MaxTxts}
    >
        <CardValue componentId="Bracelets" valueType="Drawable" minValue={-1}/>
        <CardValue componentId="Bracelets" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Vest -->
{#if $ComponentsValues?.Vest?.MaxComps > 0}
    <ClothingTab
        Title="Vest"
        AmountComponents={$ComponentsValues?.Vest?.MaxComps}
        AmountTextures={$ComponentsValues?.Vest?.MaxTxts}
    >
        <CardValue componentId="Vest" valueType="Drawable"/>
        <CardValue componentId="Vest" valueType="Texture"/>
    </ClothingTab>
{/if}

<!-- Bags -->
{#if $ComponentsValues?.Bags?.MaxComps > 0}
    <ClothingTab
        Title="Tassen"
        AmountComponents={$ComponentsValues?.Bags?.MaxComps}
        AmountTextures={$ComponentsValues?.Bags?.MaxTxts}
    >
        <CardValue componentId="Bags" valueType="Drawable"/>
        <CardValue componentId="Bags" valueType="Texture"/>
    </ClothingTab>
{/if}