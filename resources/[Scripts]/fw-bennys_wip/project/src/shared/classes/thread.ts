type ThreadType = 'tick' | 'frame';
type EventType = "preStart" | "active" | "preStop" | "afterStop";

interface ThreadHook {
    event: string;
    callback: (data: ThreadData) => void;
}

interface ThreadData {
    [key: string]: any;
}

export class Thread {
    private readonly threadFunction: false | (() => void);
    private readonly threadType: ThreadType;
    private readonly delay?: number;
    private hooks: ThreadHook[];
    running: boolean;
    data: ThreadData;

    constructor(threadFunction: false | (() => void), threadType: ThreadType, delay?: number) {
        this.threadFunction = threadFunction;
        this.threadType = threadType;
        this.delay = delay;
        this.running = false;
        this.hooks = [];
        this.data = {};
    }

    public addHook(event: EventType, callback: (data: ThreadData) => void): void {
        this.hooks.push({ event, callback });
    }

    private executeHooks(event: string): void {
        const matchingHooks = this.hooks.filter((hook) => hook.event === event);
        matchingHooks.forEach((hook) => hook.callback(this.data));
    }

    private tickThreadFunction(): void {
        if (!this.running) return;
        this.executeHooks('active');
        if (this.threadFunction) this.threadFunction();
        setTimeout(() => this.tickThreadFunction(), this.delay);
    }

    private frameThreadFunction(): void {
        if (IsDuplicityVersion()) return console.log("Frame thread can't be used in server!");
        if (!this.running) return;
        this.executeHooks('active');
        if (this.threadFunction) this.threadFunction();
        // @ts-ignore
        setTimeout(() => this.frameThreadFunction(), GetFrameTime() / 1000);
    }

    public start(): void {
        if (this.running) return;
        this.running = true;
        this.executeHooks('preStart');
        if (this.threadType === 'tick') {
            if (!this.delay) throw new Error("Delay must be defined for 'tick' type thread.");
            setTimeout(() => this.tickThreadFunction(), this.delay);
        } else if (this.threadType === 'frame') {
            this.frameThreadFunction();
        }
    }

    public stop(): void {
        if (!this.running) return;
        this.running = false;
        this.executeHooks('preStop');
        this.executeHooks('afterStop');
    }
}