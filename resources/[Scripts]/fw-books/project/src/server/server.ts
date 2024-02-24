import { exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

const ImgurRegex = /https:\/\/i\.imgur\.com\/[a-zA-Z0-9]+\.png$/i;

FW.Functions.CreateCallback("fw-books:Server:CreateBook", async (Source: number, Cb: Function, {Title, Icon, PagesUrls}: {Title: string, Icon: string, PagesUrls: string[]}, IgnorePaperRequirement: boolean) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!ImgurRegex.test(Icon)) {
        Player.Functions.Notify("Icoon moet een imgur PNG image zijn! (bv. https://i.imgur.com/SteKs2I.png", "error");
        return Cb({ Success: false });
    };

    if (!PagesUrls || PagesUrls.length < 1) {
        Player.Functions.Notify("Je moet ten minste 1 pagina hebben!", "error");
        return Cb({ Success: false });
    };

    if (PagesUrls.some((Img) => !ImgurRegex.test(Img))) {
        Player.Functions.Notify("Alle paginas moeten een imgur PNG image zijn! (bv. https://i.imgur.com/SteKs2I.png", "error");
        return Cb({ Success: false });
    };

    if (!IgnorePaperRequirement || await Player.Functions.RemoveItemByName("paper", 1, true)) {
        Player.Functions.AddItem("book", 1, false, {
            _Image: Icon,
            _Label: Title,
            _Pages: PagesUrls
        }, true);
    
        return Cb({ Success: true })
    };

    Cb({ Success: false })
});

FW.Functions.CreateUsableItem("book", async (Source: number, Item: any) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await Player.Functions.GetItemBySlot(Item.Slot)) return;

    if (!Item.Info._Pages || Item.Info._Pages.length == 0) {
        return;
    };

    emitNet("fw-books:Client:OpenBook", Source, Item.Info._Pages);
});

onNet("fw-books:Server:PurchasePaper", () => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    if (!Player.Functions.RemoveMoney("cash", 130)) {
        return Player.Functions.Notify("Je hebt niet genoeg cash!", "error");
    };

    Player.Functions.AddItem("paper", 1, false, false, true);
});