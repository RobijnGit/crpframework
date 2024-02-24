import { Delay, exp } from "../../shared/utils";

type TaskCallback = () => void;
export const PrisonTasks: [string, string, string, any][] = [];

export class PrisonTask {
    private readonly Name: string;
    private readonly Label: string;
    private readonly Description: string;
    private Tasks: {[key: string]: TaskCallback} = {};
    private StartCallback?: TaskCallback;
    private EndCallback?: TaskCallback;

    constructor(Id: string, Label: string, Description: string) {
        this.Name = Id;
        this.Label = Label;
        this.Description = Description;
        PrisonTasks.push([Id, Label, Description, this]);
    }

    onStart(Cb: TaskCallback) {
        this.StartCallback = Cb;
    }

    onEnd(Cb: TaskCallback) {
        this.EndCallback = Cb;
    }

    addTask(Id: string, Cb: TaskCallback) {
        this.Tasks[Id] = Cb;
    }

    setTask(Id: string) {
        this.Tasks[Id]();
    };

    async startJob() {
        if (this.StartCallback) this.StartCallback();
        exp['fw-ui'].ShowInteraction(`${this.Label} - ${this.Description}`);
        await Delay(5000)
        exp['fw-ui'].HideInteraction();
        return this;
    };

    endJob() {
        if (this.EndCallback) this.EndCallback();
        return this;
    }
}