import { SendUIMessage, exp } from "../../shared/utils";
import type { BennysItem } from "../../shared/types"

const FormatMenuItems = (Items: Array<BennysItem>): Array<BennysItem> => {
    for (let i = 0; i < Items.length; i++) {
        const Item = Items[i];
        Item.Id = i;

        if (Item.Children) {
            Item.Children = FormatMenuItems(Item.Children);
        }
    }

    return Items;
}

export const Menu = {
    // Menu Utils
    SetHeader: (Header: string, SubHeader: string) => {
        SendUIMessage("Bennys", "SetHeader", { Header, SubHeader });
    },
    SetMenuItems: (Items: Array<BennysItem>) => {
        const FormattedItems = FormatMenuItems(Items);
        SendUIMessage("Bennys", "SetMenu", { Items: FormattedItems });
    },
    SetMenuVisibility: (Visibility: boolean) => {
        SendUIMessage("Bennys", "SetVisibility", { Visibility });
    },

    // Menu Code
    Open: (Vehicle: number) => {
        const BodyHealth = GetVehicleBodyHealth(Vehicle);

        if (BodyHealth < 1000.0) {
            const Costs = Math.ceil(1000 - BodyHealth);

            Menu.SetHeader(`Welcome to Benny's Original Motorworks`, "Repair Vehicle");
            Menu.SetMenuItems([
                {
                    Label: "Repair",
                    Subtext: `€${Costs}`,
                    Data: {
                        Id: "RepairVehicle",
                        Costs
                    }
                }
            ]);

            Menu.SetMenuVisibility(true);

            return;
        }

    },
};