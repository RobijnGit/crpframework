export async function FetchNui(Resource, EventName, Data) {
    const ResourceName = Resource || (GetParentResourceName ? (window).GetParentResourceName() : "nui-frame-app");
    const Response = await fetch(`https://${ResourceName}/${EventName}`, {
        method: "post",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(Data),
    });

    return await Response.json();
}