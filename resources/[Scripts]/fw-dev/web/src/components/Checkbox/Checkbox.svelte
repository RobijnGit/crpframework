<script>
    export var Title = '';
    export var Checked = false;
    export var className = '';

    import './Checkbox.css';

    var ChangeCheckbox = () => {
        Checked = !Checked;
    }
</script>

<div class="ui-checkbox-container {className}">
    <label on:click={ChangeCheckbox} for="" class="ui-checkbox" style="width: auto; max-width: max-content;">
        <span class="ui-checkbox-root {Checked ? 'ui-checkbox-active': ''}" aria-disabled="false">
            <span class="ui-checkbox-label">
                {#if Checked}
                    <input class="ui-checkbox-input" type="checkbox" data-indeterminate="false" value="" checked>
                    <svg class="ui-checkbox-icon" focusable="false" viewBox="0 0 24 24" aria-hidden="true"><path d="M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2V5c0-1.1-.89-2-2-2zm-9 14l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"></path></svg>
                {:else}
                    <input class="ui-checkbox-input" type="checkbox" data-indeterminate="false" value="">
                    <svg class="ui-checkbox-icon" focusable="false" viewBox="0 0 24 24" aria-hidden="true"><path d="M19 5v14H5V5h14m0-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z"></path></svg>
                {/if}
            </span>
        </span>
        <span class="ui-checkbox-text">{Title}</span>
    </label>
</div>