<div {...$$restProps} class="mdw-card-list-container {$$restProps?.class}">
    <slot></slot>
</div>

<style>
    .mdw-card-list-container {
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        margin-top: .5vh;
    
        flex: 1 1 0%;
        
        width: 96.8%;
        height: 91.5%;
        max-height: 91.5%;
    
        display: flex;
        flex-direction: column;
        overflow-y: auto;
    }
    
    .mdw-card-list-container::-webkit-scrollbar { display: none; }
</style>