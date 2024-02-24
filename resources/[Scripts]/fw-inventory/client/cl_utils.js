const MaxTime = (((1000 * 60) * 60) * 24) * 28;
const CalculateQuality = (ItemName, CreateDate) => {
    var StartDate = new Date(CreateDate).getTime();
    var DecayRate = exports['fw-inventory'].GetItemData(ItemName).DecayRate;
    var TimeExtra = MaxTime * DecayRate;
    var Quality = 100 - Math.ceil(((Date.now() - StartDate) / TimeExtra) * 100);

    if (DecayRate == 0) Quality = 100;
    if (Quality <= 0) Quality = 0;
    if (Quality >= 99.0) Quality = 100; // because lua uses seconds, and not milliseconds its never 100%, so we'll just pretend it is.

    return Quality
};
exports("CalculateQuality", CalculateQuality)

const DumpTable = (Object) => {
    console.log(JSON.stringify(Object, undefined, 2));
};
exports("DumpTable", DumpTable)