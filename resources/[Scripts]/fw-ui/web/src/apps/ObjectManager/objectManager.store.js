import { writable } from "svelte/store";
import { Euler } from "three";

export const CameraPosition = writable({ x: 0, y: 0, z: 1 });
export const CameraRotation = writable({ x: 0, y: 0, z: 10 });
export const ObjectPosition = writable({ x: 0, y: 0, z: 10 });
export const ObjectEuler = writable(new Euler(0, 0, 0, "ZXY"));
export const Entity = writable(0);

