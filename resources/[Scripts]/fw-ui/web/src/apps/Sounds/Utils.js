import { Howl } from 'howler';

let audioPlayer = null;

export const PlaySound = (SoundId, Volume, SoundExtension = 'ogg', onEnd = () => {}) => {
    if (audioPlayer != null) audioPlayer.pause();
    audioPlayer = new Howl({ src: [`./sounds/${SoundId}.${SoundExtension}`], onend: onEnd });
    audioPlayer.volume(Volume);

    audioPlayer.play();
};

export const StopSound = () => {
    audioPlayer.pause();
    audioPlayer.unload();
    audioPlayer = null;
};
