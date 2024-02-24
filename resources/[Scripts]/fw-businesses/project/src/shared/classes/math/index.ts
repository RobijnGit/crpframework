export * from './easings';
export * from './vector3';

export const Radians = (Degrees: number) => {
	return Degrees * Math.PI / 180;
};

export const Degrees = (Radians: number) => {
	return Radians * 180 / Math.PI;
};
