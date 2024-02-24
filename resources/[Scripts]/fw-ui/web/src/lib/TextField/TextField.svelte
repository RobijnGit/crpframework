<script>
    import _$ from 'jquery';
    import { onMount } from 'svelte';
    import { DropdownData } from '../../stores';
    import { SetDropdown } from '../../utils/Utils';
    import './TextField.css';

    export var Title = 'No Title';
    export var Placeholder = '';
    export var Icon;
    export let IconText = false; 
    export var IconColor = false;
    export var Sub = '';
    export var IsSubError = false;
    export var Type = 'text';
    export var SubSet = () => {};
    export var MaxLength = 999;
    export var Value = ''; // The actual value (used for dropdowns that don't show a different text than the value.)
    export var Select = undefined;
    export var ReadOnly = false;
    export var RealValue = Value; // Value shown in input
    export var SearchSelect = false;
    export var OnSubmit = false;
    export var BorderType = 'solid';

    let OrgSelect = Select && Select.length > 0 ? [...Select] : []

    let Focused = false;

    const CheckIfSubmit = Event => {
        if (!OnSubmit) return;

        switch (Event.key) {
            case "Enter":
                OnSubmit(RealValue, Value);
                RealValue = '';
                Value = '';
                break;
        };
    }

    onMount(() => {
        if (RealValue) {
            const SubsetValue = SubSet(RealValue);
            if (SubsetValue && SubsetValue != Sub) Sub = SubsetValue;
        };

        document.body.addEventListener("keyup", CheckIfSubmit);

        return () => {
            document.body.removeEventListener("keyup", CheckIfSubmit);
        };
    })
</script>

<div {...$$restProps} class="textfield-component-container {$$restProps?.class}">
    <p class="textfield-title">{Title}</p>

    <slot/>

    {#if Icon}
        {#if IconText}
            <span class="textfield-icon">{Icon}</span>
        {:else}
            {#if Focused && IconColor}
                <i class="fas fa-{Icon}" style="color: {IconColor}"></i>
            {:else}
                <i class="fas fa-{Icon}"></i>
            {/if}
        {/if}
    {/if}

    <input
        on:focusin={() => { Focused = true }}
        on:focusout={() => { Focused = false }}
        on:input={(e) => {
            Value = e.target.value, RealValue = e.target.value;

            if (Select && SearchSelect) {
                let Query = Value.toLowerCase();
                $DropdownData.Options = OrgSelect.filter(Val => Val.Value.toLowerCase().includes(Query) || Val.Text.toLowerCase().includes(Query));
                return;
            }

            const SubsetValue = SubSet(Value);
            if (SubsetValue && SubsetValue != Sub) Sub = SubsetValue;
        }}
        on:click={(e) => {
            if (!Select || Select.length == 0) return;

            const Container = _$(e.target).closest(".textfield-component-container");
            const ContainerWidth = _$(Container).width();

            for (let i = 0; i < Select.length; i++) {
                Select[i].Cb = (_Value, Text) => {
                    Value = _Value
                    RealValue = Text

                    const SubsetValue = SubSet(RealValue, Value);
                    if (SubsetValue && SubsetValue != Sub) Sub = SubsetValue;
                };
            };

            SetDropdown(true, Select, {
                Top: _$(Container).offset().top + (_$(Container).height() / 2),
                Left: _$(Container).offset().left,
                Width: ContainerWidth + "px"
            });
        }}
        on:blur={(e) => {
            // Must wait because otherwise the blur event is triggered before the dropdown click event.
            setTimeout(() => {
                SetDropdown(false, [], {});
            }, 200);
        }}
        style="{Select && Select.length > 0 && 'user-select: none;' || ''}"
        value={RealValue}
        placeholder={Placeholder}
        maxlength={MaxLength}
        type={Type}
        readonly={ReadOnly || (Select && Select.length > 0 && !SearchSelect)}
    >

    {#if Select && !Icon}
        <i class="fas fa-caret-down"></i>
    {/if}

    <div class="textfield-underline {BorderType}" style="height: 0.1vh">
        <div class="textfield-underline-fill" style="width: {Focused ? 100 : 0}%; {IconColor ? `background-color: ${IconColor}` : ""}"></div>
    </div>
    <p class="textfield-sub" style="color: {IsSubError ? "rgb(244, 67, 54)": "unset"};">{Sub ? Sub : ""}</p>
</div>