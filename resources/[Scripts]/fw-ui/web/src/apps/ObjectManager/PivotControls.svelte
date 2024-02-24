<script>
    import { BoxGeometry, MeshStandardMaterial, Euler, MathUtils } from 'three';
    import { T, PerspectiveCamera, TransformControls, Canvas } from '@threlte/core'

    import { CameraPosition, CameraRotation, ObjectPosition, ObjectEuler, Entity } from "./objectManager.store";
    import { ConvertToGTA, ConvertToThree } from "./utils";

    import { OnEvent, SendEvent as _SendEvent } from "../../utils/Utils";
    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-editor");

    let mesh;
    let mode;
    let translationSnap = 0.01;
    let rotationSnapDegrees = 1;
    let space = "local";

    const HasPositionChanged = (NewPosition) => {
		return (
			NewPosition.x != $ObjectPosition.x ||
			NewPosition.y != $ObjectPosition.y ||
			NewPosition.z != $ObjectPosition.z
		)
	}

	const HasEulerChanged = (NewEuler) => {
		return (
			NewEuler.x != $ObjectEuler.x ||
			NewEuler.y != $ObjectEuler.y ||
			NewEuler.z != $ObjectEuler.z
		)
	}

    const GetMeshLocation = () => {
        if (mesh) {
			if (HasPositionChanged(mesh.position)) {
				$ObjectPosition.x = mesh.position.x
				$ObjectPosition.y = mesh.position.y
				$ObjectPosition.z = mesh.position.z

                SendEvent("Editor/SetCoords", {
                    ...ConvertToGTA($ObjectPosition)
                })
			}

			if (HasEulerChanged(mesh.rotation)) {
				$ObjectEuler.x = mesh.rotation.x
				$ObjectEuler.y = mesh.rotation.y
				$ObjectEuler.z = mesh.rotation.z

                const Rotation = ConvertToGTA($ObjectEuler);
                SendEvent("Editor/SetRotation", {
                    x: MathUtils.radToDeg(Rotation.x).toFixed(2),
                    y: MathUtils.radToDeg(Rotation.y).toFixed(2),
                    z: MathUtils.radToDeg(Rotation.z).toFixed(2)
                })
			}
		}
    };

    OnEvent("ObjectManager", "UpdatePivotCamera", (Data) => {
        console.log("POS", Data.Position.x, Data.Position.y, Data.Position.z);
        console.log("ROT", Data.Rotation.x, Data.Rotation.y, Data.Rotation.z);
        CameraPosition.set(ConvertToThree(Data.Position));
        CameraRotation.set(ConvertToThree(Data.Rotation));
        // CameraRotation.set(new Euler(
        //     MathUtils.degToRad(Data.Rotation.x),
        //     MathUtils.degToRad(Data.Rotation.z),
        //     MathUtils.degToRad(Data.Rotation.y),
        //     'YZX'
        // ))
        // CameraLookAt.set(ConvertToThree(Data.LookAt))
    });

    OnEvent("ObjectManager", "UpdateMesh", (Data) => {
        ObjectPosition.set(ConvertToThree(Data.Position));
        ObjectEuler.set(new Euler(
            MathUtils.degToRad(Data.Rotation.x),
            MathUtils.degToRad(Data.Rotation.z),
            MathUtils.degToRad(Data.Rotation.y),
            'YZX'
        ));

        Entity.set(Data.Entity);
    });

    // $: if (mesh) {
    //     mesh.rotation.set($ObjectEuler.x, $ObjectEuler.y, $ObjectEuler.z, $ObjectEuler.order);
    //     mesh.position.set($ObjectPosition.x, $ObjectPosition.y, $ObjectPosition.z);
    // };
</script>

<Canvas>
    <PerspectiveCamera
        position={$CameraPosition}
        rotation={$CameraRotation}
        fov={45}
    >
        <T.Mesh
            bind:ref={mesh}
            position.x={$ObjectPosition.x}
            position.y={$ObjectPosition.y}
            position.z={$ObjectPosition.z}
            geometry={new BoxGeometry(1.0, 1.0, 1.0)}
            material={new MeshStandardMaterial()}
            rotation.x={$ObjectEuler.x}
            rotation.y={$ObjectEuler.y}
            rotation.z={$ObjectEuler.z}
        >

            <TransformControls
                {mode}
                on:objectChange={() => GetMeshLocation}
                on:dragging-changed={(event) => {
                    // const isDragging = event.detail.value;
                    // if (!isDragging && $Entity != 0) {
                    //     SendEvent("Pivot/UpdateObject", {
                    //         Entity: $Entity,
                    //         Coords: ConvertToGTA($ObjectPosition),
                    //         Rot: ConvertToGTA($ObjectEuler),
                    //     })
                    // };
                }}
                {translationSnap}
                rotationSnap={MathUtils.degToRad(rotationSnapDegrees)}
                size={1.0}
                space={space}
            />

        </T.Mesh>

    </PerspectiveCamera>

</Canvas>