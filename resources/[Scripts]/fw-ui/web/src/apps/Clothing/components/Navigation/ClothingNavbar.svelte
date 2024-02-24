<script>
    import { onMount } from "svelte";
    import { CurrentTab, MenuTypes } from "../../clothing.store";
    import ClothingNavbarItem from "./ClothingNavbarItem.svelte";

    export let CurrentMenuType = "Creation";

    onMount(() => {
        CurrentTab.set(MenuTypes[CurrentMenuType][0]);
    })
</script>

<div class="clothing-navbar">
    <ClothingNavbarItem>
        <img
            alt=""
            src="./images/logo.png"
            style="width: 3.5vh; height: 3.5vh;"
        />
    </ClothingNavbarItem>

    {#if MenuTypes[CurrentMenuType].includes("clothes")}
        <ClothingNavbarItem
            TabId="clothes"
            Tooltip="Kleding"
        >
            <i class="clothing-navbar-icon fas fa-tshirt"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("accessoires")}
        <ClothingNavbarItem
            TabId="accessoires"
            Tooltip="Accessoires"
        >
            <i class="clothing-navbar-icon fas fa-vest-patches"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("peds")}
        <ClothingNavbarItem
            TabId="peds"
            Tooltip="Peds"
        >
            <i class="clothing-navbar-icon fas fa-people-arrows"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("parents")}
        <ClothingNavbarItem
            TabId="parents"
            Tooltip="Ouders"
        >
            <i class="clothing-navbar-icon fas fa-female"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("face")}
        <ClothingNavbarItem
            TabId="face"
            Tooltip="Gezicht"
        >
            <i class="clothing-navbar-icon fas fa-smile"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("skin")}
        <ClothingNavbarItem
            TabId="skin"
            Tooltip="Skin"
        >
            <i class="clothing-navbar-icon fas fa-meh-blank"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("hair")}
        <ClothingNavbarItem
            TabId="hair"
            Tooltip="Haar"
        >
            <i class="clothing-navbar-icon fas fa-cut"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("makeup")}
        <ClothingNavbarItem
            TabId="makeup"
            Tooltip="Makeup"
        >
            <i class="clothing-navbar-icon fas fa-palette"></i>
        </ClothingNavbarItem>
    {/if}

    {#if MenuTypes[CurrentMenuType].includes("tattoos")}
        <ClothingNavbarItem
            TabId="tattoos"
            Tooltip="Tattoos"
        >
            <i class="clothing-navbar-icon fas fa-paint-brush"></i>
        </ClothingNavbarItem>
    {/if}
</div>

<style>
    .clothing-navbar {
        height: 100%;
        width: 6.4vh;
    }

    .clothing-navbar-icon {
        font-size: 3vh;
        color: white;
    }
</style>