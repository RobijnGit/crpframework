// Type "Ignore" is hardcoded to be, well, ignored for the leaflet map.
export const JobVehicles = {
    Police: [
        { Type: "Car", Label: "Voertuig", Icon: "fa-car" },
        { Type: "Pursuit", Label: "High Speed Pursuit Unit", Icon: "fa-horse-head" },
        { Type: "Interceptor", Label: "Interceptor", Icon: "fa-rabbit" },
        { Type: "Heli", Label: "Helikopter", Icon: "fa-helicopter" },
        { Type: "Motor", Label: "Motor", Icon: "fa-motorcycle" },
        { Type: "Undercover", Label: "Ongemarkeerd", Icon: "fa-user-secret" },
        { Type: "Ignore", Label: "Dispatch", Icon: "fa-headset" },
    ],
    EMS: [
        { Type: "Car", Label: "Voertuig", Icon: "fa-ambulance" },
        { Type: "Commander", Label: "Commander", Icon: "fa-car" },
        { Type: "Heli", Label: "Helikopter", Icon: "fa-helicopter" },
        { Type: "Motor", Label: "Motor", Icon: "fa-motorcycle" },
        { Type: "Ignore", Label: "Dispatch", Icon: "fa-headset" },
    ],
    DOC: [],
};

export const MapMarkers = {
    Police: {
        Car: {
            html: `<i class="fas fa-car"></i>`,
            iconSize: [32, 30],
            className: 'map-icon map-icon-pd',
            offset: [0, 0],
        },
        Pursuit: {
            html: `<i class="fas fa-horse-head"></i>`,
            iconSize: [35, 30],
            className: 'map-icon map-icon-pd',
            offset: [0, 0],
        },
        Interceptor: {
            html: `<i class="fas fa-rabbit"></i>`,
            iconSize: [35, 30],
            className: 'map-icon map-icon-pd',
            offset: [0, 0],
        },
        Heli: {
            html: `<i class="fas fa-helicopter"></i>`,
            iconSize: [45, 30],
            className: 'map-icon map-icon-pd',
            offset: [0, 0],
        },
        Motor: {
            html: `<i class="fas fa-motorcycle"></i>`,
            iconSize: [40, 30],
            className: 'map-icon map-icon-pd',
            offset: [0, 0],
        },
        Undercover: {
            html: `<i class="fas fa-user-secret"></i>`,
            iconSize: [30, 30],
            className: 'map-icon map-icon-pd',
            offset: [0, 0],
        },
    },
    EMS: {
        Car: {
            html: `<i class="fas fa-ambulance"></i>`,
            iconSize: [45, 30],
            className: 'map-icon map-icon-ems',
            offset: [0, 0],
        },
        Commander: {
            html: `<i class="fas fa-car"></i>`,
            iconSize: [32, 30],
            className: 'map-icon map-icon-ems',
            offset: [0, 0],
        },
        Heli: {
            html: `<i class="fas fa-helicopter"></i>`,
            iconSize: [45, 30],
            className: 'map-icon map-icon-ems',
            offset: [0, 0],
        },
        Motor: {
            html: `<i class="fas fa-motorcycle"></i>`,
            iconSize: [40, 30],
            className: 'map-icon map-icon-ems',
            offset: [0, 0],
        },
    },
    Call: {
        Ping: {
            html: `<i class="fas fa-map-pin"></i>`,
            iconSize: [15, 30],
            className: 'map-icon map-icon-pd',
            offset: [0, 0],
        },
    }
}