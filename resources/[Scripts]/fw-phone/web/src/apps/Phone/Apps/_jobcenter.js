// import { get } from "svelte/store";
import { SendEvent } from "../../../utils/Utils";

export const SetWaypoint = (JobId) => {
    SendEvent("JobCenter/LocateJob", {JobId})
};

export const CreateGroup = () => {
    SendEvent("JobCenter/CreateGroup", {}, (Success, Data) => {
        if (!Success) return;

        if (Data.Success) {
            return;
        }

        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: Data.Msg,
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                    },
                },
            ],
            Buttons: [
                {
                    Color: "success",
                    Text: "Okay",
                    Cb: () => {},
                },
            ],
        });
    });
};

export const Signout = () => {
    SendEvent("JobCenter/CheckOut");
};

export const RequestToJoin = (GroupId) => {
    SendEvent("JobCenter/RequestToJoin", {GroupId});
};

export const ToggleReady = () => {
    SendEvent("JobCenter/Ready");
};

export const DeleteGroup = () => {
    SendEvent("JobCenter/DisbandGroup");
};

export const LeaveGroup = () => {
    SendEvent("JobCenter/LeaveGroup");
};

export const KickFromGroup = (Member) => {
    SendEvent("JobCenter/RemoveFromGroup", {Member});
};

export const PromoteToLeader = (Member) => {
    SendEvent("JobCenter/PromoteToLeader", {Member});
};

export const AbandonJob = () => {
    SendEvent("JobCenter/AbandonJob");
};