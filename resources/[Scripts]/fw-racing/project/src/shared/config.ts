export const Config: Config = {
    DrawCheckpointLine: false,
    DisableCurrentCheckpointCollision: false, // Disable checkpoint collision of current checkpoint
    LookAheadCheckpoints: 3, // Amount of checkpoints to draw on map
    RaycastBasedCheckpoint: false, // Check HasHitCheckpoint() for reasoning.
    RadiusCheckpointBuffer: 0.5,
    BrokenPBRecord: true, // Inform the player when they have broken their personal best record.
    CryptoReward: 6, // How many crypto to get? Multiplied by amount of racers.
    CryptoRewardNight: 7, // How many crypto to get at nighttime? Multiplied by amount of racers.
    PermissionBasedCreators: true, // Allow anyone with 'admin' permission to create a race.
    Creators: [ // Whitelisted creators by citizenid
        /* Example:
        "2009", // Eddie Dexter
        */
        "2004", // vinneh
        "3932", // cor leon
        "2897", // qZekk
    ],
};

interface Config {
    DrawCheckpointLine: boolean;
    DisableCurrentCheckpointCollision: boolean;
    LookAheadCheckpoints: number,
    RaycastBasedCheckpoint: boolean;
    RadiusCheckpointBuffer: number;
    BrokenPBRecord: boolean;
    CryptoReward: number;
    CryptoRewardNight: number;
    PermissionBasedCreators: boolean;
    Creators: Array<string>;
}