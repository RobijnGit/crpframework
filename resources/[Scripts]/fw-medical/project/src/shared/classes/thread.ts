type ThreadType = 'tick' | 'frame';
type EventType = "preStart" | "active" | "preStop" | "afterStop";

let ThreadsCreated: number = 0;

interface ThreadHook {
    Event: string;
    Callback: (data: ThreadData) => void;
}

interface ThreadData {
    [key: string]: any;
}

let Threads: Array<{
    Id: number;
    ThreadFunctions: Array<Function>;
    // ThreadType: ThreadType,
    Delay: number;
    LastExecution: number;
    Data: ThreadData
}> = [];

setTick(() => {
    const CurrentTime = GetGameTimer();
    for (let i = 0; i < Threads.length; i++) {
        const { Id, ThreadFunctions, Delay, LastExecution, Data } = Threads[i];
        if (CurrentTime > LastExecution + Delay) {
            // console.log(`Executing loop ${Id}!!!!`);
            ThreadFunctions.forEach((callback) => callback(Data));
            Threads[i].LastExecution = CurrentTime;
        }
    };
})

export class Thread {
    private readonly ThreadId: number;
    private readonly ThreadType: ThreadType;
    private readonly Delay: number;
    private hooks: ThreadHook[];
    running: boolean;
    data: ThreadData;

    constructor(ThreadType: ThreadType, Delay?: number) {
        ThreadsCreated += 1;

        this.ThreadType = ThreadType;
        this.Delay = Delay || 0;
        this.ThreadId = ThreadsCreated;
        this.running = false;
        this.hooks = [];
        this.data = {};
    }

    public addHook(Event: EventType, Callback: (data: ThreadData) => void): void {
        this.hooks.push({ Event, Callback });

        const ThreadIndex = Threads.findIndex((Val) => Val.Id == this.ThreadId);
        if (ThreadIndex == -1) return;

        Threads[ThreadIndex].ThreadFunctions = this.hooks.filter((Hook) => Hook.Event == 'active').map((Hook) => Hook.Callback);
    }

    public executeHook(HookType: EventType) {
        const MatchingHooks = this.hooks.filter((Hook) => Hook.Event == HookType);
        MatchingHooks.forEach((Hook) => Hook.Callback(this.data));
    }

    public start(): void {
        if (this.running) return;

        this.running = true;
        this.executeHook('preStart');

        if (this.ThreadType == "frame") {
            return console.log("Frame-timed threads currently unsupported!");
        };

        Threads.push({
            Id: this.ThreadId,
            ThreadFunctions: this.hooks.filter((Hook) => Hook.Event == 'active').map((Hook) => Hook.Callback),
            Delay: this.Delay,
            LastExecution: GetGameTimer() + this.Delay,
            Data: this.data,
        })
    }

    public stop(): void {
        if (!this.running) return;

        this.running = false;
        Threads = Threads.filter((Thread) => Thread.Id != this.ThreadId);
        this.executeHook('afterStop');
    }
};