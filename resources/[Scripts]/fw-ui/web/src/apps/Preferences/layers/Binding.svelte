<script>
    import TextField from "../../../lib/TextField/TextField.svelte";
    import { MyPreferences } from "../preferences.store.js";

    const Emotes = [
        "tired",
        "surprise",
        "smile-wink",
        "smile-beam",
        "smile",
        "sad-tear",
        "sad-cry",
        "meh-rolling-eyes",
        "meh-blank",
        "meh",
        "laugh-wink",
        "laugh-squint",
        "laugh-beam",
        "laugh",
        "kiss-wink-heart",
        "kiss-beam",
        "kiss",
        "grin-wink",
        "grin-tongue-wink",
        "grin-tongue-squint",
        "grin-tongue",
        "grin-tears",
        "grin-stars",
        "grin-squint-tears",
        "grin-squint",
        "grin-hearts",
        "grin-beam-sweat",
        "grin-alt",
        "grin",
        "grimace",
        "frown-open",
        "frown",
        "flushed",
        "dizzy",
        "angry",
    ]

    function getRandomEmote() {
        const randomIndex = Math.floor(Math.random() * Emotes.length);
        return Emotes[randomIndex];
    }

</script>
<p class="preferences-header">Emote Binds</p>

{#each ['F2', 'F3', 'F5', 'F6', 'F7', 'F9', 'F10'] as Data, Key}
    <TextField
        Title="Animatie Naam ({Data})"
        Icon={getRandomEmote()}
        IconColor="#ffcc33"
        bind:RealValue={$MyPreferences[`Binds.${Data}`]}
    />
{/each}