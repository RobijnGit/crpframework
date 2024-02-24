<script>
    import { HasVpn, HasPDRacingUsb, HasRacingUsb } from "./phone.stores";

    import BankBusters from "./Apps/BankBusters.svelte"
    import Calculator from "./Apps/Calculator.svelte"
    import Calls from "./Apps/Calls.svelte"
    import Cars from "./Apps/Cars.svelte"
    import Contacts from "./Apps/Contacts.svelte"
    import Crypto from "./Apps/Crypto.svelte"
    import Debt from "./Apps/Debt.svelte";
    import Default from "./Apps/Default.svelte";
    import Details from "./Apps/Details.svelte"
    import Documents from "./Apps/Documents.svelte"
    import DOJ from "./Apps/DOJ.svelte"
    import Employment from "./Apps/Employment.svelte"
    import Housing from "./Apps/Housing.svelte"
    import JobCenter from "./Apps/JobCenter.svelte"
    import Mails from "./Apps/Mails.svelte"
    import Messages from "./Apps/Messages.svelte"
    import MilkRoad from "./Apps/MilkRoad.svelte"
    import News from "./Apps/News.svelte"
    import Pinger from "./Apps/Pinger.svelte"
    import Racing from "./Apps/Racing.svelte"
    import TierUp from "./Apps/TierUp.svelte"
    import Twatter from "./Apps/Twatter.svelte"
    import Vehicles from "./Apps/Vehicles.svelte"
    import Wenmo from "./Apps/Wenmo.svelte"
    import YellowPages from "./Apps/YellowPages.svelte"

    export let App = 'details';
</script>

{#if App == 'details'}
    <Details />
{:else if App == 'contacts'}
    <Contacts />
{:else if App == 'calls'}
    <Calls />
{:else if App == 'messages'}
    <Messages/>
{:else if App == 'pinger'}
    <Pinger />
{:else if App == 'mails'}
    <Mails />
{:else if App == 'yellowpages'}
    <YellowPages />
{:else if App == 'twatter'}
    <Twatter />
{:else if App == 'vehicles'}
    <Vehicles />
{:else if App == 'debt'}
    <Debt />
{:else if App == 'wenmo'}
    <Wenmo />
{:else if App == 'documents'}
    <Documents />
{:else if App == 'housing'}
    <Housing />
{:else if App == 'crypto'}
    <Crypto />
{:else if App == 'jobcenter'}
    <JobCenter />
{:else if App == 'employment'}
    <Employment />
{:else if App == 'news'}
    <News NewsNetwork="weazelnews" />
{:else if App == 'bin'}
    <News NewsNetwork="bin" />
{:else if (App == 'racing' || App == 'time-trials') && ($HasRacingUsb || $HasPDRacingUsb)}
    <Racing Type={App == "time-trials" ? "Gov" : "Crime"} />
{:else if App == 'milkroad'}
    <MilkRoad />
{:else if App == 'calculator'}
    <Calculator />
{:else if App == 'bankbusters'}
    <BankBusters />
{:else if App == 'doj'}
    <DOJ />
{:else if App == 'tierup'}
    <TierUp />
{:else if App == 'cars'}
    <Cars />
{:else}
    <Default/>
{/if}