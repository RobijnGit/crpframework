export type BennysItem = {
    Id?: number;
    Label: string;
    Subtext: false | string;
    Children?: BennysItem[];
    Data: any;
}