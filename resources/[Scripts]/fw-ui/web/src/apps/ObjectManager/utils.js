export const ConvertToThree = (Coords) => {
    return { x: Coords.x, y: Coords.z, z: -Coords.y };
};

export const ConvertToGTA = (Coords) => {
    return {x: Coords.x, y: -Coords.z, z: Coords.y };
};