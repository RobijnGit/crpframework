<script>
    import {clickOutside} from "../../utils/ClickOutside";
    import { SetDropdown } from "../../utils/Utils";
    import './Dropdown.css';
    export var Value = '';
    export var Options = [];
    export var Positioning = {};
</script>

<div use:clickOutside on:clickOutside={() => { SetDropdown(false) }} class="dropdown-container" style="width: {Positioning?.Width}; top: {Positioning?.Top}px; left: {Positioning?.Left}px;">
    {#each Options as Data, Key}
        <div on:keyup on:click={(e) => {
            Value = Data.Value;
            if (Data.Cb) {
                Data.Cb(Data.Value || Data.Text, Data.Text);
                SetDropdown(false);
            }
        }} class="dropdown-option" >
            {#if Data.Icon}
                <i class="fas {Data.Icon}"></i>
            {/if}
            {Data.Text}
        </div>
    {/each}
</div>