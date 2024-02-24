import {
    OrthographicCamera,
    Scene,
    WebGLRenderTarget,
    LinearFilter,
    NearestFilter,
    RGBAFormat,
    UnsignedByteType,
    CfxTexture,
    ShaderMaterial,
    PlaneBufferGeometry,
    Mesh,
    WebGLRenderer
} from '@citizenfx/three';

type RatioType = '16:9' | '1:1';

class ScreenshotRequest {
    encoding: 'jpg' | 'png' | 'webp';
    quality: number;
    headers: any;

    correlation: string;

    resultURL: string;

    targetURL: string;
    targetField: string;

    ratio: RatioType;
    username: undefined | string;
}

interface RatioObject {
    [key: string]: {
        offsetX: number;
        offsetY: number;
        width: number;
        height: number;
    }
}

let Ratios: RatioObject = {};

// from https://stackoverflow.com/a/12300351
function dataURItoBlob(dataURI: string) {
    const byteString = atob(dataURI.split(',')[1]);
    const mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

    const ab = new ArrayBuffer(byteString.length);
    const ia = new Uint8Array(ab);

    for (let i = 0; i < byteString.length; i++) {
        ia[i] = byteString.charCodeAt(i);
    }

    const blob = new Blob([ab], {type: mimeString});
    return blob;
}

class ScreenshotUI {
    renderer: any;
    rtTexture: any;
    sceneRTT: any;
    cameraRTT: any;
    material: any;
    request: ScreenshotRequest;

    initialize() {
        window.addEventListener('message', event => {
            this.request = event.data.request;
        });

        window.addEventListener('resize', event => {
            this.resize();
        });

        this.setupRatios();

        const cameraRTT: any = new OrthographicCamera( window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / -2, -10000, 10000 );
        cameraRTT.position.z = 100;

        const sceneRTT: any = new Scene();

        const rtTexture = new WebGLRenderTarget( window.innerWidth, window.innerHeight, { minFilter: LinearFilter, magFilter: NearestFilter, format: RGBAFormat, type: UnsignedByteType } );
        const gameTexture: any = new CfxTexture( );
        gameTexture.needsUpdate = true;

        const material = new ShaderMaterial( {

            uniforms: { "tDiffuse": { value: gameTexture } },
            vertexShader: `
			varying vec2 vUv;

			void main() {
				vUv = vec2(uv.x, 1.0-uv.y); // fuck gl uv coords
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
			}
`,
            fragmentShader: `
			varying vec2 vUv;
			uniform sampler2D tDiffuse;

			void main() {
				gl_FragColor = texture2D( tDiffuse, vUv );
			}
`

        } );

        this.material = material;

        const plane = new PlaneBufferGeometry( window.innerWidth, window.innerHeight );
        const quad: any = new Mesh( plane, material );
        quad.position.z = -100;
        sceneRTT.add( quad );

        const renderer = new WebGLRenderer();
        renderer.setPixelRatio( window.devicePixelRatio );
        renderer.setSize( window.innerWidth, window.innerHeight );
        renderer.autoClear = false;

        document.getElementById('app').appendChild(renderer.domElement);
        document.getElementById('app').style.display = 'none';

        this.renderer = renderer;
        this.rtTexture = rtTexture;
        this.sceneRTT = sceneRTT;
        this.cameraRTT = cameraRTT;

        this.animate = this.animate.bind(this);

        requestAnimationFrame(this.animate);
    }

    resize() {
        const cameraRTT: any = new OrthographicCamera( window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / -2, -10000, 10000 );
        cameraRTT.position.z = 100;

        this.cameraRTT = cameraRTT;

        const sceneRTT: any = new Scene();

        const plane = new PlaneBufferGeometry( window.innerWidth, window.innerHeight );
        const quad: any = new Mesh( plane, this.material );
        quad.position.z = -100;
        sceneRTT.add( quad );

        this.sceneRTT = sceneRTT;

        this.rtTexture = new WebGLRenderTarget( window.innerWidth, window.innerHeight, { minFilter: LinearFilter, magFilter: NearestFilter, format: RGBAFormat, type: UnsignedByteType } );

        this.renderer.setSize( window.innerWidth, window.innerHeight );

        this.setupRatios();
    }

    setupRatios() {
        const Width = window.innerWidth;
        const Height = window.innerHeight;

        Ratios["16:9"] = {
            offsetX: 0.0,
            offsetY: 0.0,
            width: Width,
            height: Height,
        }

        Ratios["1:1"] = {
            offsetX: 0.2185,
            offsetY: 0.0,
            width: Height,
            height: Height,
        }
    }

    animate() {
        requestAnimationFrame(this.animate);

        this.renderer.clear();
        this.renderer.render(this.sceneRTT, this.cameraRTT, this.rtTexture, true);

        if (this.request) {
            const request = this.request;
            this.request = null;

            this.handleRequest(request);
        }
    }

    handleRequest(request: ScreenshotRequest) {
        // read the screenshot
        const read = new Uint8Array(window.innerWidth * window.innerHeight * 4);
        this.renderer.readRenderTargetPixels(this.rtTexture, 0, 0, window.innerWidth, window.innerHeight, read);

        // create a temporary canvas to compress the image
        const canvas = document.createElement('canvas');
        canvas.style.display = 'inline';
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        // draw the image on the canvas
        const d = new Uint8ClampedArray(read.buffer);

        const cxt = canvas.getContext('2d');
        cxt.putImageData(new ImageData(d, window.innerWidth, window.innerHeight), 0, 0);

        // encode the image
        let type = 'image/png';

        switch (request.encoding) {
            case 'jpg':
                type = 'image/jpeg';
                break;
            case 'png':
                type = 'image/png';
                break;
            case 'webp':
                type = 'image/webp';
                break;
        }

        if (!request.quality) {
            request.quality = 0.92;
        }

        // actual encoding
        const crop = (canvas: HTMLCanvasElement, ratio: RatioType = "16:9") => {
            let buffer = document.createElement('canvas');
            let b_ctx = buffer.getContext('2d');

            const ratioData = Ratios[ratio];

            buffer.width = ratioData.width;
            buffer.height = ratioData.height;
            b_ctx.drawImage(canvas, window.innerWidth * ratioData.offsetX, ratioData.height * ratioData.offsetY, ratioData.width, ratioData.height, 0, 0, buffer.width, buffer.height);

            return buffer.toDataURL(type, request.quality);
        };

        const imageURL = crop(canvas, request.ratio);

        const getFormData = () => {
            const formData = new FormData();
            formData.append(request.targetField, dataURItoBlob(imageURL), `screenshot.${request.encoding}`);

            if (request.username) {
                formData.append('username', request.username);
            }

            return formData;
        };

        // upload the image somewhere
        fetch(request.targetURL, {
            method: 'POST',
            mode: 'cors',
            headers: request.headers,
            body: (request.targetField) ? getFormData() : JSON.stringify({
                data: imageURL,
                id: request.correlation
            })
        })
        .then(response => response.text())
        .then(text => {
            if (request.resultURL) {
                fetch(request.resultURL, {
                    method: 'POST',
                    mode: 'cors',
                    body: JSON.stringify({
                        data: text,
                        id: request.correlation
                    })
                });
            }
        });
    }
}

const ui = new ScreenshotUI();
ui.initialize();