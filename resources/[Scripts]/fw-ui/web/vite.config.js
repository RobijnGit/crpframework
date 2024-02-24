import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import obfuscatorPlugin from "vite-plugin-javascript-obfuscator";
import { resolve } from "path";

// https://vitejs.dev/config/
export default defineConfig(({ command, mode, ssrBuild }) => {
    return {
        plugins: [
            svelte(),
            mode == "production" ? obfuscatorPlugin({
                apply: "build",
                options: {
                    compact: true,
                    controlFlowFlattening: false,
                    deadCodeInjection: false,
                    debugProtection: false,
                    debugProtectionInterval: 0,
                    disableConsoleOutput: true,
                    identifierNamesGenerator: 'hexadecimal',
                    log: false,
                    numbersToExpressions: false,
                    renameGlobals: false,
                    selfDefending: false,
                    simplify: true,
                    splitStrings: false,
                    stringArray: true,
                    stringArrayCallsTransform: false,
                    stringArrayCallsTransformThreshold: 0.5,
                    stringArrayEncoding: [],
                    stringArrayIndexShift: true,
                    stringArrayRotate: true,
                    stringArrayShuffle: true,
                    stringArrayWrappersCount: 1,
                    stringArrayWrappersChainedCalls: true,
                    stringArrayWrappersParametersMaxCount: 2,
                    stringArrayWrappersType: 'variable',
                    stringArrayThreshold: 0.75,
                    unicodeEscapeSequence: false
                },
            }) : undefined,
        ],
        base: './',
        resolve: {
            alias: {
                // "@lib": resolve("./src/lib"),
                // "@utils": resolve("./src/utils"),
                // "@apps": resolve("./src/layers"),
            }
        }
    }
})
