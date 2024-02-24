<script>
    import _$ from 'jquery';
    import { onMount } from 'svelte';
    import { SetDropdown } from '../../utils/Utils';
    import './TextField.css';

    // This is a mess, first thing I had written in Svelte, probably should re-do the UI components.

    export var Title = 'No Title';
    export var Placeholder = '';
    export var Icon;
    export var Sub = '';
    export var Type = 'text';
    export var SubSet = () => {};
    export var MaxLength = 999;
    export var Value = '';
    export var Select = [];
    export var ReadOnly = false;
    export var RealValue = Value;
    export var OnSubmit = false;

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

    var InputField;

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

    {#if Icon && Select.length == 0}
        <i class="fas fa-{Icon}"></i>
    {/if}

    <input bind:this={InputField}
        on:input={(e) => {
            Value = e.target.value, RealValue = e.target.value;
            let SubsetValue = SubSet(Value);
            if (SubsetValue && SubsetValue != Sub) Sub = SubsetValue;
        }}
        on:click={(e) => {
            if (Select == undefined || Select.length == 0) return;

            const Container = _$(e.target).closest(".textfield-component-container");
            const ContainerWidth = _$(Container).width();

            for (let i = 0; i < Select.length; i++) {
                Select[i].Cb = (_Value, Text) => {
                    Value = _Value
                    RealValue = Text
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
        style="{Select.length > 0 && 'user-select: none;' || ''}"
        value={RealValue}
        placeholder={Placeholder}
        maxlength={MaxLength}
        type={Type}
        readonly={ReadOnly || Select.length > 0}
    >

    {#if Icon && Select.length > 0}
        <i class="fas fa-{Icon}"></i>
    {/if}

    <div class="textfield-underline"></div>
    <p class="textfield-sub">{Sub}</p>
</div>