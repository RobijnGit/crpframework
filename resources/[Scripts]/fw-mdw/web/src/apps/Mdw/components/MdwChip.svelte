<script>
    export let Text = '';
    export let PrefixIcon = false;
    export let SuffixIcon = false;
    export let Color = '#ffffff';

    const HexToRgb = Hex => {
        var ShorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
        Hex = Hex.replace(ShorthandRegex, function(m, r, g, b) {
            return r + r + g + g + b + b;
        });

        var Result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(Hex);
        return Result ? [
            parseInt(Result[1], 16),
            parseInt(Result[2], 16),
            parseInt(Result[3], 16)
        ] : [255, 255, 255];
    };

    const GetTextColor = () => {
        let [R, G, B] = HexToRgb(Color);
        if (R * 0.299 + G * 0.587 + B * 0.114 > 150) {
            return "#000000";
        } else {
            return "#FFFFFF";
        };
    };
</script>

{#if !SuffixIcon}
    <div on:keyup on:click class="chip-container" style="background-color: {Color || "#ffffff"}; color: {GetTextColor()};">
        {#if PrefixIcon}
            <span class="chip-cell">
                <i class="fas fa-{PrefixIcon}" style="margin-left: 0px; margin-right: 0.37vh;"></i>
            </span>
        {/if}
        <span class="chip-cell" style="margin: 0px;">
            <span style="margin: 0px; white-space: nowrap;">{Text}</span>
        </span>
    </div>
{:else}
    <div class="chip-container" style="background-color: {Color || "#ffffff"}; color: {GetTextColor()};">
        {#if PrefixIcon}
            <span class="chip-cell">
                <i class="fas fa-{PrefixIcon}" style="margin-left: 0px; margin-right: 0.37vh;"></i>
            </span>
        {/if}
        <span class="chip-cell" style="margin: 0px;">
            <span style="margin: 0px; white-space: nowrap;">{Text}</span>
        </span>
        {#if SuffixIcon}
            <span on:keyup on:click class="chip-cell">
                <i class="fas fa-{SuffixIcon}"></i>
            </span>
        {/if}
    </div>
{/if}

<style>
    .chip-container {
        border-radius: 1.48vh;
        background-color: white;
        height: 2.96vh;
        position: relative;
        display: inline-flex;
        align-items: center;
        padding: 0 1.11vh;
        border-width: 0;
        outline: none;
        font-family: Roboto;
        font-size: 1.3vh;
        font-weight: 400;
        margin: 0.37vh;
    }

    .chip-container i {
        vertical-align: middle;
        border-radius: 50%;
        /* width: 1.65vh; */
        height: 1.65vh;
        font-size: 1.65vh;
        margin-left: 0.37vh;
    }
</style>