import { writable } from "svelte/store";

// Misc
export const ImageHoverData = writable({Show: false, Source: '', Top: 0, Left: 0})
export const DropdownData = writable({Show: false});
export const ShowLoader = writable(false);

// Global
export const IsGov = writable(true);
export const IsEms = writable(true);
export const IsJudge = writable(true);
export const IsHighcommand = writable(true);

// MDW
export const CurrentTab = writable("Dashboard");
export const IsPublic = writable(false);
export const MdwProfile = writable({
    department: "public",
    callsign: "N.T.B",
    name: "",
    alias: "",
    roles: []
});

export const MdwCharges = writable([]);
export const MdwTags = writable([]);
export const MdwCerts = writable([]);
export const MdwRanks = writable([]);
export const MdwRoles = writable([]);
export const MdwEvidence = writable([]);

// MDW - Modals
export const MdwModalsTags = writable({
    Show: false,
    IgnoreFilter: [],
    Cb: () => {}
});

export const MdwModalsCerts = writable({
    Show: false,
    IgnoreFilter: [],
    Cb: () => {}
});

export const MdwModalsRoles = writable({
    Show: false,
    IgnoreFilter: [],
    Cb: () => {}
});

export const MdwModalsUnits = writable({
    Show: false,
    IgnoreFilter: [],
    Cb: () => {}
});

export const MdwModalsPerson = writable({
    Show: false,
    IgnoreFilter: [],
    Cb: () => {}
});

export const MdwModalsEvidence = writable({
    Show: false,
    Form: { Type: 'Foto', Identifier: '', Description: '', Cid: '' },
    Cb: () => {}
});

export const MdwModalsProfiles = writable({
    Show: false,
    IgnoreFilter: [],
    Cb: () => {}
});

export const MdwModalsCharges = writable({
    Show: false,
    Charges: [],
    Cb: () => {}
});

export const MdwModalsPermissions = writable({
    Show: false,
    Role: [],
    Cb: () => {}
});

export const MdwModalsExport = writable({
    Show: false,
    Msg: '',
});

export const MdwModalsChargeEditor = writable({
    Show: false,
    Charge: {},
});

export const MdwModalsVehicleHistory = writable({
    Show: false,
    Plate: ""
});


// MDW - Reports
export const CurrentReport = writable({
    category: 'Incidenten Rapport',
    title: '',
    report: '',
    evidence: [],
    tags: [],
    officers: [],
    persons: [],
    vehicles: [],
    scums: [],
})

// MDW - Profiles
export const CurrentProfile = writable({
    citizenid: "",
    name: "",
    image: "",
    notes: "",
})

// MDW - Evidence
export const CurrentEvidence = writable({
    type: "",
    identifier: "",
    description: "",
    citizenid: "",
})

// MDW - Properties
export const CurrentProperty = writable({
    adress: "",
    owned: "Nee",
})

// MDW - Staff
export const CurrentStaff = writable({
    citizenid: "",
    name: "",
    image: "",
    callsign: "",
    alias: "",
    phonenumber: "",
    department: "",
    rank: "",
    certs: [],
    strikes: [],
})

// MDW - Legislation
export const CurrentLegislation = writable({
    title: "",
    content: "",
})

// MDW - Businesses
export const CurrentBusiness = writable({ Employees: [] })

// MDW - Config