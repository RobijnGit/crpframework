<script>
    import { onMount } from "svelte";
    import AppContainer from "../components/AppContainer.svelte";
    import CartCard from "./CartCard.svelte";
    import ItemCard from "./ItemCard.svelte";
    import { SendEvent } from "../../../../utils/Utils";
    import ModalContainer from "../components/ModalContainer.svelte";
    import Button from "../../../../components/Button/Button.svelte";

    let Cart = [];
    let CartTotal = 0;

    let Products = [];
    let FilteredProducts = [];

    let CurrentCategory = 0;
    let SearchText = '';

    let ModalMessage = false;

    const SetCurrentCategory = Val => {
        CurrentCategory = Val;
        FilterProducts(SearchText);
    };

    const AddProductToCart = (Product) => { 
        if (Cart.includes(Product.id)) return;
        Cart = [...Cart, Product.id];
        CartTotal = GetCartTotal();
    };

    const RemoveProductFromCart = (ProductId) => {
        if (!Cart.includes(ProductId)) return;
        Cart = Cart.filter(Val => Val != ProductId);
        CartTotal = GetCartTotal();
    };

    const GetCartInfo = (ProductId, ProductInfo) => {
        const Product = Products.filter(Val => Val.id == ProductId)[0];
        if (!Product) return "";

        switch (ProductInfo) {
            case "Image":
                return Product.SharedData.Image;
            case "Name":
                return Product.SharedData.Label;
            case "Price":
                return Product.price;
            default:
                return "";
        }
    };

    const GetCartTotal = () => {
        let Retval = 0;

        for (let i = 0; i < Cart.length; i++) {
            const Product = Products.filter(Val => Val.id == Cart[i])[0];
            if (!Product) continue;

            Retval += Product.price
        };

        return Retval;
    }

    const IsOfferRecent = (Timestamp) => {
        const Diff = new Date().getTime() - Timestamp;
        const HoursInMs = 24 * 60 * 60 * 1000;
        return Diff <= HoursInMs;
    };

    const FilterProducts = (Query) => {
        Query = Query.toLowerCase();

        const _CategorizedProducts = Products.filter(Val => CurrentCategory == 0 ? IsOfferRecent(Val.date) : true)
        FilteredProducts = _CategorizedProducts.filter(Val => Val.SharedData.Label.toLowerCase().includes(Query))
    };

    const PurchaseProducts = () => {
        if (Cart.length == 0) return ModalMessage = 'Je kan geen leeg winkelmandje bestellen..';
        
        SendEvent("Market/PurchaseProducts", {Cart}, (Success, Data) => {
            if (!Success) return ModalMessage = 'Je bestelling kon niet worden afgerond..';
            ModalMessage = Data.Msg;
            Cart = [];
        })
    };

    onMount(() => {
        SendEvent("Market/GetProducts", {}, (Success, Data) => {
            if (!Success) return;
            Products = Data;
            FilterProducts(SearchText);
        });
    });
</script>

<AppContainer
    class="app-market-container"
    AppId="Market"
    App="Holle Bolle Market - GNE hier."
>

{#if ModalMessage}
    <ModalContainer style="max-width: 50%;">
        <h1 style="color: white; text-align: center; font-size: 2vh; font-weight: 500; font-family: Roboto">{ModalMessage}</h1>
        <div style="margin-top: 1vh; width: 100%; display: flex; justify-content: space-around;">
            <Button Color="success" click={() => {
                ModalMessage = false;
            }}>Okay</Button>
        </div>
    </ModalContainer>
{/if}

    <div class="navbar-wrapper">
        <div class="app-navbar">
            <div
                class:selected={CurrentCategory == 0}
                class="app-navbar-item"
                on:keyup on:click={() => SetCurrentCategory(0)}
            >Recent</div>
            <div
                class:selected={CurrentCategory == 1}
                class="app-navbar-item"
                on:keyup on:click={() => SetCurrentCategory(1)}
            >Alles</div>
            {#if CurrentCategory != 2}
                <div
                    class="app-navbar-item selected"
                >
                    <input
                        class="app-navbar-search"
                        placeholder="Zoeken"
                        bind:value={SearchText}
                        on:input={() => FilterProducts(SearchText)}
                    />
                </div>
            {/if}

            <div
                class="app-navbar-item selected"
                style="padding: 1.1vh 1.5vh;"
                on:keyup on:click={() => SetCurrentCategory(2)}
            >
                {#if Cart.length > 0}
                    <p class="cart-amount">{Cart.length}</p>
                {/if}
                <i class="fas fa-shopping-cart" /> Winkelmandje
            </div>
        </div>
    </div>

    {#if CurrentCategory == 2} 
        <div class="item-cart-cards">
            <div class="cards">
                {#each Cart as Data, Id}
                    <CartCard
                        Image={GetCartInfo(Data, 'Image')}
                        Name={GetCartInfo(Data, 'Name')}
                        Price={GetCartInfo(Data, 'Price')}
                        on:click={() => RemoveProductFromCart(Data)}
                    />
                {/each}
            </div>

            <div class="payment">
                <p>Totaal: {CartTotal} GNE</p>
                <div
                    class="payment-button"
                    on:keyup on:click={() => PurchaseProducts()}
                >
                    Bestellen
                </div>
            </div>
        </div>
    {:else}
        <div class="item-cards-wrapper">
            {#each FilteredProducts as Data, Id}
                <ItemCard
                    Image={Data.SharedData.Image}
                    Name={Data.SharedData.Label}
                    Timestamp={Data.date}
                    Price={Data.price}
                    CartAmount={Cart.filter(Val => Val == Data.id).length}
                    on:click={() => AddProductToCart(Data)}
                />
            {/each}
        </div>
    {/if}

</AppContainer>


<style>
    :global(.app-market-container) {
        width: 127.8vh !important;
        background-color: #101010 !important;
    }

    :global(.app-market-container > .app-topbar) {
        background-color: #212121 !important;
    }

    .navbar-wrapper {
        position: absolute;
        top: 6vh;
        left: 50%;

        transform: translateX(-50%);

        width: calc(100% - 6vh);
        height: fit-content;
    }

    .app-navbar {
        display: flex;
    }

    .app-navbar-item {
        color: #9494ff;

        font-family: Roboto;
        font-weight: bold;
        text-transform: uppercase;

        border-radius: 3vh;
        padding: 1.1vh 2vh;

        font-size: 1.25vh;

        margin-right: 1vh;

        transition: background-color ease-in 100ms;
    }

    .app-navbar-item.selected {
        background-color: #212121;
    }

    .app-navbar-search {
        background-color: transparent;
        outline: none;
        border: none;
        color: white;
        width: 15vh;
    }

    .app-navbar-item:last-of-type {
        margin-left: auto;
    }

    .app-navbar-item:last-of-type > .cart-amount {
        position: absolute;
        top: -1.2vh;
        right: -.8vh;

        display: flex;
        justify-content: center;
        align-items: center;

        font-size: 1.25vh;
        border-radius: 50%;
        background-color: #6360f5;
        color: white;

        width: 3vh;
        height: 3vh;

        box-shadow: 0 0 1vh 0 rgba(0, 0, 0, .5);
    }

    .item-cards-wrapper {
        position: relative;
        top: 8.6vh;
        left: 0;
        right: 0;

        margin: 0 auto;
        overflow-y: auto;

        width: 95%;
        height: 78%;

        display: grid;
        grid-template-columns: repeat(5, 15.5vh);
        grid-column-gap: 2.4vh;
        grid-row-gap: 2.4vh;
    }

    .item-cards-wrapper::-webkit-scrollbar {
        display: none;
    }

    .item-cart-cards {
        display: flex;

        position: relative;
        top: 10vh;
        left: 0;
        right: 0;

        margin: 0 auto;
        overflow-y: auto;

        width: 95%;
        height: 78%;
    }


    .item-cart-cards > .cards {
        max-height: 100%;
        width: 80%;
        overflow-y: auto;
    }

    .item-cart-cards > .cards::-webkit-scrollbar {
        display: none;
    }

    .item-cart-cards > .payment {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;

        width: 20%;
        height: 65%;
    }

    .item-cart-cards > .payment > p {
        color: white;
        font-family: 1.4vh;
    }

    .item-cart-cards > .payment > .payment-button {
        margin-top: 1vh;

        padding: 1vh 1.2vh;
        border-radius: 4vh;
        font-size: 1.3vh;
        max-width: 60%;

        text-transform: uppercase;

        font-family: Roboto;
        font-weight: 600;
        color: white;

        background-color: #00810d;
    }
</style>