/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./src/server/server.ts":
/*!******************************!*\
  !*** ./src/server/server.ts ***!
  \******************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.FW = void 0;\nconst utils_1 = __webpack_require__(/*! ../shared/utils */ \"./src/shared/utils.ts\");\nexports.FW = utils_1.exp['fw-core'].GetCoreObject();\n\n\n//# sourceURL=webpack://fw-bennys/./src/server/server.ts?");

/***/ }),

/***/ "./src/shared/utils.ts":
/*!*****************************!*\
  !*** ./src/shared/utils.ts ***!
  \*****************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.RegisterNUICallback = exports.SetUIFocus = exports.SendUIMessage = exports.GetRandom = exports.Delay = exports.exp = void 0;\nexports.exp = __webpack_require__.g.exports;\nconst Delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));\nexports.Delay = Delay;\nconst GetRandom = (Min, Max) => Math.floor(Math.random() * (Max - Min + 1)) + Min;\nexports.GetRandom = GetRandom;\nexports.SendUIMessage = !IsDuplicityVersion() ? (App, Event, Data) => {\n    exports.exp['fw-ui'].SendUIMessage(App, Event, Data);\n} : () => console.warn(`SendUIMessage does exist on server.`);\nexports.SetUIFocus = !IsDuplicityVersion() ? (HasFocus, HasCursor) => {\n    exports.exp['fw-ui'].SetUIFocus(HasFocus, HasCursor);\n} : () => console.warn(`SetUIFocus does exist on server.`);\nexports.RegisterNUICallback = !IsDuplicityVersion() ? (Name, Cb) => {\n    RegisterNuiCallbackType(Name);\n    on(`__cfx_nui:${Name}`, Cb);\n} : () => console.log(`RegisterNUICallback can't be used on server.`);\n\n\n//# sourceURL=webpack://fw-bennys/./src/shared/utils.ts?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/global */
/******/ 	(() => {
/******/ 		__webpack_require__.g = (function() {
/******/ 			if (typeof globalThis === 'object') return globalThis;
/******/ 			try {
/******/ 				return this || new Function('return this')();
/******/ 			} catch (e) {
/******/ 				if (typeof window === 'object') return window;
/******/ 			}
/******/ 		})();
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module can't be inlined because the eval devtool is used.
/******/ 	var __webpack_exports__ = __webpack_require__("./src/server/server.ts");
/******/ 	
/******/ })()
;