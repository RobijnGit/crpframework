<script>
    import AppWrapper from "../components/AppWrapper.svelte";

    const Operators = ['+', '-', '*', '÷'];

    let DisplayElement;
    let Display = '';
    let History = [];

    const UpdateDisplayRatio = () => {
        const ratio = Math.min(1, 4 / Display.length);
        DisplayElement.style.transform = `scale(${ratio})`;
    };

    const HasOperator = () => {
        return History.some(val => Operators.includes(val));
    };

    const AddValue = (Key) => {
        const LastEntry = History[History.length - 1];
        if (LastEntry && !isNaN(LastEntry) && (LastEntry !== '.' || Key !== '.') && !Operators.includes(Key)) {
            History[History.length - 1] = LastEntry + Key;
        } else {
            if (Operators.includes(Key) && Operators.includes(LastEntry)) return; // don't allow multiple operators in a row. (It won't break it if disabled, but its just ugly.)
            if (Key != "-" && Operators.includes(Key) && !LastEntry) return; // never should be able to start with a operator.
            if (Key === '.' && (!LastEntry || isNaN(LastEntry))) History.push('0'); // if Key is a decimal, but there's no number in front of it - add it.
            History.push(Key);
        };

        Display = History.join('');
        UpdateDisplayRatio();
    };

    const CalculateResult = () => {
        let Expression = History.join('');
        if (Operators.includes(Expression.slice(-1))) {
            Expression = Expression.slice(0, -1);
        };

        let currentOperator = '+';
        let currentNumber = '';
        let result = 0;

        for (let i = 0; i < History.length; i++) {
            const currentChar = History[i];

            if (!isNaN(currentChar) || currentChar === '.') {
                currentNumber += currentChar;
            };

            if (Operators.includes(currentChar) || i === History.length - 1) {
                if (currentNumber) {
                    const parsedNumber = parseFloat(currentNumber);
                    if (currentOperator === '+') {
                        result += parsedNumber;
                    } else if (currentOperator === '-') {
                        result -= parsedNumber;
                    } else if (currentOperator === '*') {
                        result *= parsedNumber;
                    } else if (currentOperator === '÷') {
                        result /= parsedNumber;
                    };
                };

                currentNumber = '';
                currentOperator = currentChar;
            };
        };

        const FormattedResult = result.toString();
        const DecimalPlaces = FormattedResult.split('.')[1]?.length || 0;
        return DecimalPlaces > 0 ? (DecimalPlaces > 4 ? result.toFixed(4) : result.toFixed(DecimalPlaces)) : parseInt(result);
    };

    const ButtonPress = Key => {
        const LastEntry = History[History.length - 1];

        if (LastEntry && History.length == 1 && LastEntry == 0) {
            History = [];
        }

        switch (Key) {
            case "AC":
                History = [];
                Display = '';
                UpdateDisplayRatio();
                break;
            case "+/-":
                if (!LastEntry || isNaN(LastEntry)) return; // if the last entry is not a number, do nothing
                const InverseValue = -parseFloat(LastEntry);
                History[History.length - 1] = InverseValue.toString();
                Display = History.join('');
                UpdateDisplayRatio();
                break;
            case "%":
                if (!LastEntry || isNaN(LastEntry)) return;

                const Percentage = parseFloat(LastEntry) / 100;
                History[History.length - 1] = Percentage.toString();
                Display = History.join('');
                UpdateDisplayRatio();
                break;
            case "=":
                if (!HasOperator()) return;
                const Value = CalculateResult();
                History = [Value.toString()];
                Display = Value.toString();
                UpdateDisplayRatio();
                break;
            default:
                AddValue(Key);
                break;
        }
    };

    const RemoveLastDigit = Event => {
        if (Event.key != 'Backspace') return;

        const LastEntry = History[History.length - 1];
        if (!LastEntry) return;

        if (LastEntry.length === 1) {
            History.pop();
        } else {
            History[History.length - 1] = LastEntry.slice(0, -1);
        };

        Display = History.join('');
        UpdateDisplayRatio();
    }
</script>

<AppWrapper style="background-color: black">
    <div class="calculator" on:keydown={RemoveLastDigit}>
        <div class="calculator-display">
            <div bind:this={DisplayElement} class="auto-scaling-text">{Display}</div>
        </div>
        <div class="calculator-keypad">
            <div class="input-keys">
                <div class="function-keys">
                    <button on:click={() => { ButtonPress("AC")}} class="calculator-key key-clear">AC</button>
                    <button on:click={() => { ButtonPress("+/-")}} class="calculator-key key-sign">±</button>
                    <button on:click={() => { ButtonPress("%")}} class="calculator-key key-percent">%</button>
                </div>
                <div class="digit-keys">
                    <button on:click={() => { ButtonPress("0")}} class="calculator-key key-0">0</button>
                    <button on:click={() => { ButtonPress(".")}} class="calculator-key key-dot">●</button>
                    <button on:click={() => { ButtonPress("1")}} class="calculator-key key-1">1</button>
                    <button on:click={() => { ButtonPress("2")}} class="calculator-key key-2">2</button>
                    <button on:click={() => { ButtonPress("3")}} class="calculator-key key-3">3</button>
                    <button on:click={() => { ButtonPress("4")}} class="calculator-key key-4">4</button>
                    <button on:click={() => { ButtonPress("5")}} class="calculator-key key-5">5</button>
                    <button on:click={() => { ButtonPress("6")}} class="calculator-key key-6">6</button>
                    <button on:click={() => { ButtonPress("7")}} class="calculator-key key-7">7</button>
                    <button on:click={() => { ButtonPress("8")}} class="calculator-key key-8">8</button>
                    <button on:click={() => { ButtonPress("9")}} class="calculator-key key-9">9</button>
                </div>
            </div>
            <div class="operator-keys">
                <button on:click={() => { ButtonPress("÷")}} class="calculator-key key-divide">÷</button>
                <button on:click={() => { ButtonPress("*")}} class="calculator-key key-multiply">*</button>
                <button on:click={() => { ButtonPress("-")}} class="calculator-key key-subtract">-</button>
                <button on:click={() => { ButtonPress("+")}} class="calculator-key key-add">+</button>
                <button on:click={() => { ButtonPress("=")}} class="calculator-key key-equals">=</button>
            </div>
        </div>
    </div>
</AppWrapper>

<style>
    .calculator {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        width: 100%;
        height: 44vh;
        background: #000;
        display: flex;
        flex-direction: column
    }

    .calculator .calculator-display {
        color: #fff;
        background: #1c191c;
        line-height: 12vh;
        font-size: 8.8vh;
        flex: 1 1;
        white-space: nowrap;
    }

    .calculator .calculator-display .auto-scaling-text {
        display: inline-block;
        padding: 0 2.7vh;
        position: absolute;
        right: 0;
        -webkit-transform-origin: right;
        transform-origin: right;
    }

    .calculator .calculator-keypad {
        display: flex
    }

    .calculator .calculator-keypad .calculator-key {
        display: block;
        background: none;
        padding: 0;
        font-family: inherit;
        -webkit-user-select: none;
        -ms-user-select: none;
        user-select: none;
        cursor: pointer;
        outline: none;
        width: 33.333%;
        height: 6.4vh;
        border: none;
        border-top: .1vh solid #777;
        border-right: .1vh solid #666;
        text-align: center;
        line-height: 6.4vh
    }

    .calculator .calculator-keypad .calculator-key:active {
        box-shadow: inset 0 0 7.4vh 0 rgba(0, 0, 0, .25)
    }

    .calculator .calculator-keypad .input-keys {
        width: 75%
    }

    .calculator .calculator-keypad .input-keys .digit-keys {
        background: #e0e0e7;
        display: flex;
        flex-direction: row;
        flex-wrap: wrap-reverse
    }

    .calculator .calculator-keypad .input-keys .digit-keys .calculator-key {
        font-size: 3.3vh
    }

    .calculator .calculator-keypad .input-keys .digit-keys .key-0 {
        width: 66.6666%;
        text-align: left;
        padding-left: 2.5vh
    }

    .calculator .calculator-keypad .input-keys .digit-keys .key-dot {
        padding-top: 1.4vh;
        font-size: 1.1vh
    }

    .calculator .calculator-keypad .input-keys .function-keys {
        display: flex;
        background: linear-gradient(180deg, #cacacc 0, #c4c2cc)
    }

    .calculator .calculator-keypad .input-keys .function-keys .calculator-key {
        font-size: 2.9vh
    }

    .calculator .calculator-keypad .input-keys .function-keys .key-multiply {
        line-height: 4.6vh
    }

    .calculator .calculator-keypad .operator-keys {
        flex: 1 1;
        background: linear-gradient(180deg, #fc9c17 0, #f77e1b)
    }

    .calculator .calculator-keypad .operator-keys .calculator-key {
        width: 100%;
        color: #fff;
        border-right: 0;
        font-size: 4.4vh
    }
</style>