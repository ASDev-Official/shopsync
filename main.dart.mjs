// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It should return a JS Array containing 2 elements. The first
  //   should be the bytes for the wasm module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The second
  //   should be the result of using the JS 'import' API on the js file path.
  async instantiate(additionalImports, {loadDeferredWasm, loadDynamicModule} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _4: (o, c) => o instanceof c,
      _6: (o,s,v) => o[s] = v,
      _7: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._7(f,arguments.length,x0) }),
      _8: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._8(f,arguments.length,x0,x1) }),
      _37: x0 => new Array(x0),
      _39: x0 => x0.length,
      _41: (x0,x1) => x0[x1],
      _42: (x0,x1,x2) => { x0[x1] = x2 },
      _43: x0 => new Promise(x0),
      _45: (x0,x1,x2) => new DataView(x0,x1,x2),
      _47: x0 => new Int8Array(x0),
      _48: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _49: x0 => new Uint8Array(x0),
      _51: x0 => new Uint8ClampedArray(x0),
      _53: x0 => new Int16Array(x0),
      _55: x0 => new Uint16Array(x0),
      _57: x0 => new Int32Array(x0),
      _59: x0 => new Uint32Array(x0),
      _61: x0 => new Float32Array(x0),
      _63: x0 => new Float64Array(x0),
      _65: (x0,x1,x2) => x0.call(x1,x2),
      _66: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._66(f,arguments.length,x0,x1) }),
      _69: () => Symbol("jsBoxedDartObjectProperty"),
      _70: (decoder, codeUnits) => decoder.decode(codeUnits),
      _71: () => new TextDecoder("utf-8", {fatal: true}),
      _72: () => new TextDecoder("utf-8", {fatal: false}),
      _73: (s) => +s,
      _74: x0 => new Uint8Array(x0),
      _75: (x0,x1,x2) => x0.set(x1,x2),
      _76: (x0,x1) => x0.transferFromImageBitmap(x1),
      _78: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._78(f,arguments.length,x0) }),
      _79: x0 => new window.FinalizationRegistry(x0),
      _80: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _81: (x0,x1) => x0.unregister(x1),
      _82: (x0,x1,x2) => x0.slice(x1,x2),
      _83: (x0,x1) => x0.decode(x1),
      _84: (x0,x1) => x0.segment(x1),
      _85: () => new TextDecoder(),
      _87: x0 => x0.click(),
      _88: x0 => x0.buffer,
      _89: x0 => x0.wasmMemory,
      _90: () => globalThis.window._flutter_skwasmInstance,
      _91: x0 => x0.rasterStartMilliseconds,
      _92: x0 => x0.rasterEndMilliseconds,
      _93: x0 => x0.imageBitmaps,
      _120: x0 => x0.remove(),
      _121: (x0,x1) => x0.append(x1),
      _122: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _123: (x0,x1) => x0.querySelector(x1),
      _125: (x0,x1) => x0.removeChild(x1),
      _203: x0 => x0.stopPropagation(),
      _204: x0 => x0.preventDefault(),
      _206: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _251: x0 => x0.unlock(),
      _252: x0 => x0.getReader(),
      _253: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _254: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _255: (x0,x1) => x0.item(x1),
      _256: x0 => x0.next(),
      _257: x0 => x0.now(),
      _258: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._258(f,arguments.length,x0) }),
      _259: (x0,x1) => x0.addListener(x1),
      _260: (x0,x1) => x0.removeListener(x1),
      _261: (x0,x1) => x0.matchMedia(x1),
      _262: (x0,x1) => x0.revokeObjectURL(x1),
      _263: x0 => x0.close(),
      _264: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _265: x0 => new window.ImageDecoder(x0),
      _266: x0 => ({frameIndex: x0}),
      _267: (x0,x1) => x0.decode(x1),
      _268: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._268(f,arguments.length,x0) }),
      _269: (x0,x1) => x0.getModifierState(x1),
      _270: (x0,x1) => x0.removeProperty(x1),
      _271: (x0,x1) => x0.prepend(x1),
      _272: x0 => x0.disconnect(),
      _273: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._273(f,arguments.length,x0) }),
      _274: (x0,x1) => x0.getAttribute(x1),
      _275: (x0,x1) => x0.contains(x1),
      _276: x0 => x0.blur(),
      _277: x0 => x0.hasFocus(),
      _278: (x0,x1) => x0.hasAttribute(x1),
      _279: (x0,x1) => x0.getModifierState(x1),
      _280: (x0,x1) => x0.appendChild(x1),
      _281: (x0,x1) => x0.createTextNode(x1),
      _282: (x0,x1) => x0.removeAttribute(x1),
      _283: x0 => x0.getBoundingClientRect(),
      _284: (x0,x1) => x0.observe(x1),
      _285: x0 => x0.disconnect(),
      _286: (x0,x1) => x0.closest(x1),
      _696: () => globalThis.window.flutterConfiguration,
      _697: x0 => x0.assetBase,
      _703: x0 => x0.debugShowSemanticsNodes,
      _704: x0 => x0.hostElement,
      _705: x0 => x0.multiViewEnabled,
      _706: x0 => x0.nonce,
      _708: x0 => x0.fontFallbackBaseUrl,
      _712: x0 => x0.console,
      _713: x0 => x0.devicePixelRatio,
      _714: x0 => x0.document,
      _715: x0 => x0.history,
      _716: x0 => x0.innerHeight,
      _717: x0 => x0.innerWidth,
      _718: x0 => x0.location,
      _719: x0 => x0.navigator,
      _720: x0 => x0.visualViewport,
      _721: x0 => x0.performance,
      _723: x0 => x0.URL,
      _725: (x0,x1) => x0.getComputedStyle(x1),
      _726: x0 => x0.screen,
      _727: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._727(f,arguments.length,x0) }),
      _728: (x0,x1) => x0.requestAnimationFrame(x1),
      _733: (x0,x1) => x0.warn(x1),
      _735: (x0,x1) => x0.debug(x1),
      _736: x0 => globalThis.parseFloat(x0),
      _737: () => globalThis.window,
      _738: () => globalThis.Intl,
      _739: () => globalThis.Symbol,
      _740: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _742: x0 => x0.clipboard,
      _743: x0 => x0.maxTouchPoints,
      _744: x0 => x0.vendor,
      _745: x0 => x0.language,
      _746: x0 => x0.platform,
      _747: x0 => x0.userAgent,
      _748: (x0,x1) => x0.vibrate(x1),
      _749: x0 => x0.languages,
      _750: x0 => x0.documentElement,
      _751: (x0,x1) => x0.querySelector(x1),
      _754: (x0,x1) => x0.createElement(x1),
      _757: (x0,x1) => x0.createEvent(x1),
      _758: x0 => x0.activeElement,
      _761: x0 => x0.head,
      _762: x0 => x0.body,
      _764: (x0,x1) => { x0.title = x1 },
      _767: x0 => x0.visibilityState,
      _768: () => globalThis.document,
      _769: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._769(f,arguments.length,x0) }),
      _770: (x0,x1) => x0.dispatchEvent(x1),
      _778: x0 => x0.target,
      _780: x0 => x0.timeStamp,
      _781: x0 => x0.type,
      _783: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _790: x0 => x0.firstChild,
      _794: x0 => x0.parentElement,
      _796: (x0,x1) => { x0.textContent = x1 },
      _797: x0 => x0.parentNode,
      _799: x0 => x0.isConnected,
      _803: x0 => x0.firstElementChild,
      _805: x0 => x0.nextElementSibling,
      _806: x0 => x0.clientHeight,
      _807: x0 => x0.clientWidth,
      _808: x0 => x0.offsetHeight,
      _809: x0 => x0.offsetWidth,
      _810: x0 => x0.id,
      _811: (x0,x1) => { x0.id = x1 },
      _814: (x0,x1) => { x0.spellcheck = x1 },
      _815: x0 => x0.tagName,
      _816: x0 => x0.style,
      _818: (x0,x1) => x0.querySelectorAll(x1),
      _819: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _820: x0 => x0.tabIndex,
      _821: (x0,x1) => { x0.tabIndex = x1 },
      _822: (x0,x1) => x0.focus(x1),
      _823: x0 => x0.scrollTop,
      _824: (x0,x1) => { x0.scrollTop = x1 },
      _825: x0 => x0.scrollLeft,
      _826: (x0,x1) => { x0.scrollLeft = x1 },
      _827: x0 => x0.classList,
      _829: (x0,x1) => { x0.className = x1 },
      _831: (x0,x1) => x0.getElementsByClassName(x1),
      _832: (x0,x1) => x0.attachShadow(x1),
      _835: x0 => x0.computedStyleMap(),
      _836: (x0,x1) => x0.get(x1),
      _842: (x0,x1) => x0.getPropertyValue(x1),
      _843: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _844: x0 => x0.offsetLeft,
      _845: x0 => x0.offsetTop,
      _846: x0 => x0.offsetParent,
      _848: (x0,x1) => { x0.name = x1 },
      _849: x0 => x0.content,
      _850: (x0,x1) => { x0.content = x1 },
      _854: (x0,x1) => { x0.src = x1 },
      _855: x0 => x0.naturalWidth,
      _856: x0 => x0.naturalHeight,
      _860: (x0,x1) => { x0.crossOrigin = x1 },
      _862: (x0,x1) => { x0.decoding = x1 },
      _863: x0 => x0.decode(),
      _868: (x0,x1) => { x0.nonce = x1 },
      _873: (x0,x1) => { x0.width = x1 },
      _875: (x0,x1) => { x0.height = x1 },
      _878: (x0,x1) => x0.getContext(x1),
      _940: (x0,x1) => x0.fetch(x1),
      _941: x0 => x0.status,
      _943: x0 => x0.body,
      _944: x0 => x0.arrayBuffer(),
      _947: x0 => x0.read(),
      _948: x0 => x0.value,
      _949: x0 => x0.done,
      _951: x0 => x0.name,
      _952: x0 => x0.x,
      _953: x0 => x0.y,
      _956: x0 => x0.top,
      _957: x0 => x0.right,
      _958: x0 => x0.bottom,
      _959: x0 => x0.left,
      _971: x0 => x0.height,
      _972: x0 => x0.width,
      _973: x0 => x0.scale,
      _974: (x0,x1) => { x0.value = x1 },
      _977: (x0,x1) => { x0.placeholder = x1 },
      _979: (x0,x1) => { x0.name = x1 },
      _980: x0 => x0.selectionDirection,
      _981: x0 => x0.selectionStart,
      _982: x0 => x0.selectionEnd,
      _985: x0 => x0.value,
      _987: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _988: x0 => x0.readText(),
      _989: (x0,x1) => x0.writeText(x1),
      _991: x0 => x0.altKey,
      _992: x0 => x0.code,
      _993: x0 => x0.ctrlKey,
      _994: x0 => x0.key,
      _995: x0 => x0.keyCode,
      _996: x0 => x0.location,
      _997: x0 => x0.metaKey,
      _998: x0 => x0.repeat,
      _999: x0 => x0.shiftKey,
      _1000: x0 => x0.isComposing,
      _1002: x0 => x0.state,
      _1003: (x0,x1) => x0.go(x1),
      _1005: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1006: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1007: x0 => x0.pathname,
      _1008: x0 => x0.search,
      _1009: x0 => x0.hash,
      _1013: x0 => x0.state,
      _1016: (x0,x1) => x0.createObjectURL(x1),
      _1018: x0 => new Blob(x0),
      _1020: x0 => new MutationObserver(x0),
      _1021: (x0,x1,x2) => x0.observe(x1,x2),
      _1022: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1022(f,arguments.length,x0,x1) }),
      _1025: x0 => x0.attributeName,
      _1026: x0 => x0.type,
      _1027: x0 => x0.matches,
      _1028: x0 => x0.matches,
      _1032: x0 => x0.relatedTarget,
      _1034: x0 => x0.clientX,
      _1035: x0 => x0.clientY,
      _1036: x0 => x0.offsetX,
      _1037: x0 => x0.offsetY,
      _1040: x0 => x0.button,
      _1041: x0 => x0.buttons,
      _1042: x0 => x0.ctrlKey,
      _1046: x0 => x0.pointerId,
      _1047: x0 => x0.pointerType,
      _1048: x0 => x0.pressure,
      _1049: x0 => x0.tiltX,
      _1050: x0 => x0.tiltY,
      _1051: x0 => x0.getCoalescedEvents(),
      _1054: x0 => x0.deltaX,
      _1055: x0 => x0.deltaY,
      _1056: x0 => x0.wheelDeltaX,
      _1057: x0 => x0.wheelDeltaY,
      _1058: x0 => x0.deltaMode,
      _1065: x0 => x0.changedTouches,
      _1068: x0 => x0.clientX,
      _1069: x0 => x0.clientY,
      _1072: x0 => x0.data,
      _1075: (x0,x1) => { x0.disabled = x1 },
      _1077: (x0,x1) => { x0.type = x1 },
      _1078: (x0,x1) => { x0.max = x1 },
      _1079: (x0,x1) => { x0.min = x1 },
      _1080: x0 => x0.value,
      _1081: (x0,x1) => { x0.value = x1 },
      _1082: x0 => x0.disabled,
      _1083: (x0,x1) => { x0.disabled = x1 },
      _1085: (x0,x1) => { x0.placeholder = x1 },
      _1087: (x0,x1) => { x0.name = x1 },
      _1089: (x0,x1) => { x0.autocomplete = x1 },
      _1090: x0 => x0.selectionDirection,
      _1092: x0 => x0.selectionStart,
      _1093: x0 => x0.selectionEnd,
      _1096: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1097: (x0,x1) => x0.add(x1),
      _1100: (x0,x1) => { x0.noValidate = x1 },
      _1101: (x0,x1) => { x0.method = x1 },
      _1102: (x0,x1) => { x0.action = x1 },
      _1128: x0 => x0.orientation,
      _1129: x0 => x0.width,
      _1130: x0 => x0.height,
      _1131: (x0,x1) => x0.lock(x1),
      _1150: x0 => new ResizeObserver(x0),
      _1153: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1153(f,arguments.length,x0,x1) }),
      _1161: x0 => x0.length,
      _1162: x0 => x0.iterator,
      _1163: x0 => x0.Segmenter,
      _1164: x0 => x0.v8BreakIterator,
      _1165: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1166: x0 => x0.done,
      _1167: x0 => x0.value,
      _1168: x0 => x0.index,
      _1172: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1173: (x0,x1) => x0.adoptText(x1),
      _1174: x0 => x0.first(),
      _1175: x0 => x0.next(),
      _1176: x0 => x0.current(),
      _1182: x0 => x0.hostElement,
      _1183: x0 => x0.viewConstraints,
      _1186: x0 => x0.maxHeight,
      _1187: x0 => x0.maxWidth,
      _1188: x0 => x0.minHeight,
      _1189: x0 => x0.minWidth,
      _1190: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1190(f,arguments.length,x0) }),
      _1191: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1191(f,arguments.length,x0) }),
      _1192: (x0,x1) => ({addView: x0,removeView: x1}),
      _1193: x0 => x0.loader,
      _1194: () => globalThis._flutter,
      _1195: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1196: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1196(f,arguments.length,x0) }),
      _1197: f => finalizeWrapper(f, function() { return dartInstance.exports._1197(f,arguments.length) }),
      _1198: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1199: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1199(f,arguments.length,x0) }),
      _1200: x0 => ({runApp: x0}),
      _1201: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1201(f,arguments.length,x0,x1) }),
      _1202: x0 => x0.length,
      _1203: () => globalThis.window.ImageDecoder,
      _1204: x0 => x0.tracks,
      _1206: x0 => x0.completed,
      _1208: x0 => x0.image,
      _1214: x0 => x0.displayWidth,
      _1215: x0 => x0.displayHeight,
      _1216: x0 => x0.duration,
      _1219: x0 => x0.ready,
      _1220: x0 => x0.selectedTrack,
      _1221: x0 => x0.repetitionCount,
      _1222: x0 => x0.frameCount,
      _1277: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1277(f,arguments.length,x0,x1,x2) }),
      _1278: (x0,x1) => x0.append(x1),
      _1280: x0 => x0.remove(),
      _1281: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1282: (x0,x1) => x0.removeAttribute(x1),
      _1284: (x0,x1) => x0.getResponseHeader(x1),
      _1307: (x0,x1) => x0.item(x1),
      _1310: (x0,x1) => { x0.csp = x1 },
      _1311: x0 => x0.csp,
      _1312: (x0,x1) => x0.getCookieExpirationDate(x1),
      _1313: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1313(f,arguments.length,x0) }),
      _1314: x0 => ({createScriptURL: x0}),
      _1315: (x0,x1,x2) => x0.createPolicy(x1,x2),
      _1316: (x0,x1,x2) => x0.createScriptURL(x1,x2),
      _1317: x0 => x0.hasChildNodes(),
      _1318: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _1319: (x0,x1) => x0.querySelectorAll(x1),
      _1320: (x0,x1) => x0.item(x1),
      _1321: x0 => ({type: x0}),
      _1324: (x0,x1) => x0.createElement(x1),
      _1327: x0 => globalThis.Sentry.init(x0),
      _1328: () => new Sentry.getClient(),
      _1329: x0 => x0.getOptions(),
      _1333: () => globalThis.Sentry.globalHandlersIntegration(),
      _1334: () => globalThis.Sentry.dedupeIntegration(),
      _1335: () => globalThis.Sentry.close(),
      _1336: (x0,x1) => x0.sendEnvelope(x1),
      _1339: () => globalThis.globalThis,
      _1341: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1342: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1343: (x0,x1) => x0.getAttribute(x1),
      _1347: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1365: x0 => x0.toArray(),
      _1366: x0 => x0.toUint8Array(),
      _1367: x0 => ({serverTimestamps: x0}),
      _1368: x0 => ({source: x0}),
      _1371: x0 => new firebase_firestore.FieldPath(x0),
      _1372: (x0,x1) => new firebase_firestore.FieldPath(x0,x1),
      _1373: (x0,x1,x2) => new firebase_firestore.FieldPath(x0,x1,x2),
      _1374: (x0,x1,x2,x3) => new firebase_firestore.FieldPath(x0,x1,x2,x3),
      _1375: (x0,x1,x2,x3,x4) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4),
      _1376: (x0,x1,x2,x3,x4,x5) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5),
      _1377: (x0,x1,x2,x3,x4,x5,x6) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6),
      _1378: (x0,x1,x2,x3,x4,x5,x6,x7) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7),
      _1379: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      _1380: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9),
      _1381: () => globalThis.firebase_firestore.documentId(),
      _1382: (x0,x1) => new firebase_firestore.GeoPoint(x0,x1),
      _1383: x0 => globalThis.firebase_firestore.vector(x0),
      _1384: x0 => globalThis.firebase_firestore.Bytes.fromUint8Array(x0),
      _1385: x0 => globalThis.firebase_firestore.writeBatch(x0),
      _1386: (x0,x1) => globalThis.firebase_firestore.collection(x0,x1),
      _1388: (x0,x1) => globalThis.firebase_firestore.doc(x0,x1),
      _1391: x0 => x0.call(),
      _1415: x0 => x0.commit(),
      _1416: (x0,x1) => x0.delete(x1),
      _1418: (x0,x1,x2) => x0.set(x1,x2),
      _1419: (x0,x1,x2) => x0.update(x1,x2),
      _1420: x0 => globalThis.firebase_firestore.deleteDoc(x0),
      _1421: x0 => globalThis.firebase_firestore.getDoc(x0),
      _1422: x0 => globalThis.firebase_firestore.getDocFromServer(x0),
      _1423: x0 => globalThis.firebase_firestore.getDocFromCache(x0),
      _1424: (x0,x1) => ({includeMetadataChanges: x0,source: x1}),
      _1425: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1425(f,arguments.length,x0) }),
      _1426: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1426(f,arguments.length,x0) }),
      _1427: (x0,x1,x2,x3) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2,x3),
      _1428: (x0,x1,x2) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2),
      _1430: (x0,x1) => globalThis.firebase_firestore.setDoc(x0,x1),
      _1431: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1432: x0 => globalThis.firebase_firestore.getDocs(x0),
      _1433: x0 => globalThis.firebase_firestore.getDocsFromServer(x0),
      _1434: x0 => globalThis.firebase_firestore.getDocsFromCache(x0),
      _1435: x0 => globalThis.firebase_firestore.limit(x0),
      _1436: x0 => globalThis.firebase_firestore.limitToLast(x0),
      _1437: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1437(f,arguments.length,x0) }),
      _1438: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1438(f,arguments.length,x0) }),
      _1439: (x0,x1) => globalThis.firebase_firestore.orderBy(x0,x1),
      _1441: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      _1443: x0 => globalThis.firebase_firestore.doc(x0),
      _1446: (x0,x1) => x0.data(x1),
      _1450: x0 => x0.docChanges(),
      _1458: () => globalThis.firebase_firestore.deleteField(),
      _1459: () => globalThis.firebase_firestore.serverTimestamp(),
      _1461: () => globalThis.firebase_firestore.count(),
      _1462: x0 => globalThis.firebase_firestore.sum(x0),
      _1463: x0 => globalThis.firebase_firestore.average(x0),
      _1464: (x0,x1) => globalThis.firebase_firestore.getAggregateFromServer(x0,x1),
      _1465: x0 => x0.data(),
      _1467: (x0,x1) => globalThis.firebase_firestore.getFirestore(x0,x1),
      _1469: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      _1470: f => finalizeWrapper(f, function() { return dartInstance.exports._1470(f,arguments.length) }),
      _1487: () => globalThis.firebase_firestore.updateDoc,
      _1488: () => globalThis.firebase_firestore.or,
      _1489: () => globalThis.firebase_firestore.and,
      _1494: x0 => x0.path,
      _1497: () => globalThis.firebase_firestore.GeoPoint,
      _1498: x0 => x0.latitude,
      _1499: x0 => x0.longitude,
      _1501: () => globalThis.firebase_firestore.VectorValue,
      _1502: () => globalThis.firebase_firestore.Bytes,
      _1505: x0 => x0.type,
      _1507: x0 => x0.doc,
      _1509: x0 => x0.oldIndex,
      _1511: x0 => x0.newIndex,
      _1513: () => globalThis.firebase_firestore.DocumentReference,
      _1517: x0 => x0.path,
      _1526: x0 => x0.metadata,
      _1527: x0 => x0.ref,
      _1532: x0 => x0.docs,
      _1534: x0 => x0.metadata,
      _1538: () => globalThis.firebase_firestore.Timestamp,
      _1539: x0 => x0.seconds,
      _1540: x0 => x0.nanoseconds,
      _1576: x0 => x0.hasPendingWrites,
      _1578: x0 => x0.fromCache,
      _1585: x0 => x0.source,
      _1590: () => globalThis.firebase_firestore.startAfter,
      _1591: () => globalThis.firebase_firestore.startAt,
      _1592: () => globalThis.firebase_firestore.endBefore,
      _1593: () => globalThis.firebase_firestore.endAt,
      _1594: () => globalThis.firebase_firestore.arrayRemove,
      _1595: () => globalThis.firebase_firestore.arrayUnion,
      _1606: (x0,x1) => x0.querySelector(x1),
      _1618: (x0,x1) => globalThis.firebase_auth.linkWithPopup(x0,x1),
      _1624: x0 => x0.reload(),
      _1627: (x0,x1) => globalThis.firebase_auth.unlink(x0,x1),
      _1631: (x0,x1) => globalThis.firebase_auth.updateProfile(x0,x1),
      _1634: x0 => x0.toJSON(),
      _1635: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1635(f,arguments.length,x0) }),
      _1636: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1636(f,arguments.length,x0) }),
      _1637: (x0,x1,x2) => x0.onAuthStateChanged(x1,x2),
      _1638: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1638(f,arguments.length,x0) }),
      _1639: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1639(f,arguments.length,x0) }),
      _1640: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1640(f,arguments.length,x0) }),
      _1641: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1641(f,arguments.length,x0) }),
      _1642: (x0,x1,x2) => x0.onIdTokenChanged(x1,x2),
      _1646: (x0,x1,x2) => globalThis.firebase_auth.createUserWithEmailAndPassword(x0,x1,x2),
      _1652: (x0,x1,x2) => globalThis.firebase_auth.sendPasswordResetEmail(x0,x1,x2),
      _1656: (x0,x1,x2) => globalThis.firebase_auth.signInWithEmailAndPassword(x0,x1,x2),
      _1659: (x0,x1) => globalThis.firebase_auth.signInWithPopup(x0,x1),
      _1661: x0 => x0.signOut(),
      _1662: (x0,x1) => globalThis.firebase_auth.connectAuthEmulator(x0,x1),
      _1677: () => new firebase_auth.GoogleAuthProvider(),
      _1678: (x0,x1) => x0.addScope(x1),
      _1679: (x0,x1) => x0.setCustomParameters(x1),
      _1685: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromResult(x0),
      _1700: x0 => globalThis.firebase_auth.getAdditionalUserInfo(x0),
      _1701: (x0,x1,x2) => ({errorMap: x0,persistence: x1,popupRedirectResolver: x2}),
      _1702: (x0,x1) => globalThis.firebase_auth.initializeAuth(x0,x1),
      _1708: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromError(x0),
      _1711: (x0,x1) => ({displayName: x0,photoURL: x1}),
      _1723: () => globalThis.firebase_auth.debugErrorMap,
      _1726: () => globalThis.firebase_auth.browserSessionPersistence,
      _1728: () => globalThis.firebase_auth.browserLocalPersistence,
      _1730: () => globalThis.firebase_auth.indexedDBLocalPersistence,
      _1733: x0 => globalThis.firebase_auth.multiFactor(x0),
      _1734: (x0,x1) => globalThis.firebase_auth.getMultiFactorResolver(x0,x1),
      _1736: x0 => x0.currentUser,
      _1740: x0 => x0.tenantId,
      _1750: x0 => x0.displayName,
      _1751: x0 => x0.email,
      _1752: x0 => x0.phoneNumber,
      _1753: x0 => x0.photoURL,
      _1754: x0 => x0.providerId,
      _1755: x0 => x0.uid,
      _1756: x0 => x0.emailVerified,
      _1757: x0 => x0.isAnonymous,
      _1758: x0 => x0.providerData,
      _1759: x0 => x0.refreshToken,
      _1760: x0 => x0.tenantId,
      _1761: x0 => x0.metadata,
      _1763: x0 => x0.providerId,
      _1764: x0 => x0.signInMethod,
      _1765: x0 => x0.accessToken,
      _1766: x0 => x0.idToken,
      _1767: x0 => x0.secret,
      _1778: x0 => x0.creationTime,
      _1779: x0 => x0.lastSignInTime,
      _1784: x0 => x0.code,
      _1786: x0 => x0.message,
      _1798: x0 => x0.email,
      _1799: x0 => x0.phoneNumber,
      _1800: x0 => x0.tenantId,
      _1823: x0 => x0.user,
      _1826: x0 => x0.providerId,
      _1827: x0 => x0.profile,
      _1828: x0 => x0.username,
      _1829: x0 => x0.isNewUser,
      _1832: () => globalThis.firebase_auth.browserPopupRedirectResolver,
      _1837: x0 => x0.displayName,
      _1838: x0 => x0.enrollmentTime,
      _1839: x0 => x0.factorId,
      _1840: x0 => x0.uid,
      _1842: x0 => x0.hints,
      _1843: x0 => x0.session,
      _1845: x0 => x0.phoneNumber,
      _1855: x0 => ({displayName: x0}),
      _1856: x0 => ({photoURL: x0}),
      _1857: (x0,x1) => x0.getItem(x1),
      _1862: (x0,x1) => x0.appendChild(x1),
      _1864: (x0,x1) => x0.removeItem(x1),
      _1865: (x0,x1,x2) => x0.setItem(x1,x2),
      _1868: (x0,x1,x2,x3,x4,x5,x6,x7) => ({apiKey: x0,authDomain: x1,databaseURL: x2,projectId: x3,storageBucket: x4,messagingSenderId: x5,measurementId: x6,appId: x7}),
      _1869: (x0,x1) => globalThis.firebase_core.initializeApp(x0,x1),
      _1870: x0 => globalThis.firebase_core.getApp(x0),
      _1871: () => globalThis.firebase_core.getApp(),
      _1872: (x0,x1,x2) => globalThis.firebase_core.registerVersion(x0,x1,x2),
      _1874: () => globalThis.firebase_core.SDK_VERSION,
      _1880: x0 => x0.apiKey,
      _1882: x0 => x0.authDomain,
      _1884: x0 => x0.databaseURL,
      _1886: x0 => x0.projectId,
      _1888: x0 => x0.storageBucket,
      _1890: x0 => x0.messagingSenderId,
      _1892: x0 => x0.measurementId,
      _1894: x0 => x0.appId,
      _1896: x0 => x0.name,
      _1897: x0 => x0.options,
      _1898: (x0,x1) => x0.debug(x1),
      _1899: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1899(f,arguments.length,x0) }),
      _1900: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1900(f,arguments.length,x0,x1) }),
      _1901: (x0,x1) => ({createScript: x0,createScriptURL: x1}),
      _1902: (x0,x1) => x0.createScriptURL(x1),
      _1903: (x0,x1,x2) => x0.createScript(x1,x2),
      _1904: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1904(f,arguments.length,x0) }),
      _1906: (x0,x1) => x0.initialize(x1),
      _1912: Date.now,
      _1913: secondsSinceEpoch => {
        const date = new Date(secondsSinceEpoch * 1000);
        const match = /\((.*)\)/.exec(date.toString());
        if (match == null) {
            // This should never happen on any recent browser.
            return '';
        }
        return match[1];
      },
      _1914: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1915: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1916: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1917: () => typeof dartUseDateNowForTicks !== "undefined",
      _1918: () => 1000 * performance.now(),
      _1919: () => Date.now(),
      _1920: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1921: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1922: () => new WeakMap(),
      _1923: (map, o) => map.get(o),
      _1924: (map, o, v) => map.set(o, v),
      _1925: x0 => new WeakRef(x0),
      _1926: x0 => x0.deref(),
      _1933: () => globalThis.WeakRef,
      _1936: s => JSON.stringify(s),
      _1937: s => printToConsole(s),
      _1938: (o, p, r) => o.replaceAll(p, () => r),
      _1939: (o, p, r) => o.replace(p, () => r),
      _1940: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1941: s => s.toUpperCase(),
      _1942: s => s.trim(),
      _1943: s => s.trimLeft(),
      _1944: s => s.trimRight(),
      _1945: (string, times) => string.repeat(times),
      _1946: Function.prototype.call.bind(String.prototype.indexOf),
      _1947: (s, p, i) => s.lastIndexOf(p, i),
      _1948: (string, token) => string.split(token),
      _1949: Object.is,
      _1950: o => o instanceof Array,
      _1951: (a, i) => a.push(i),
      _1955: a => a.pop(),
      _1956: (a, i) => a.splice(i, 1),
      _1957: (a, s) => a.join(s),
      _1958: (a, s, e) => a.slice(s, e),
      _1960: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1961: a => a.length,
      _1963: (a, i) => a[i],
      _1964: (a, i, v) => a[i] = v,
      _1966: o => {
        if (o instanceof ArrayBuffer) return 0;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 1;
        }
        return 2;
      },
      _1967: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1969: o => o instanceof Uint8Array,
      _1970: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1971: o => o instanceof Int8Array,
      _1972: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1973: o => o instanceof Uint8ClampedArray,
      _1974: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1975: o => o instanceof Uint16Array,
      _1976: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1977: o => o instanceof Int16Array,
      _1978: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1979: o => o instanceof Uint32Array,
      _1980: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1981: o => o instanceof Int32Array,
      _1982: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1984: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1985: o => o instanceof Float32Array,
      _1986: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1987: o => o instanceof Float64Array,
      _1988: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1989: (t, s) => t.set(s),
      _1990: l => new DataView(new ArrayBuffer(l)),
      _1991: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1993: o => o.buffer,
      _1994: o => o.byteOffset,
      _1995: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1996: (b, o) => new DataView(b, o),
      _1997: (b, o, l) => new DataView(b, o, l),
      _1998: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1999: Function.prototype.call.bind(DataView.prototype.setUint8),
      _2000: Function.prototype.call.bind(DataView.prototype.getInt8),
      _2001: Function.prototype.call.bind(DataView.prototype.setInt8),
      _2002: Function.prototype.call.bind(DataView.prototype.getUint16),
      _2003: Function.prototype.call.bind(DataView.prototype.setUint16),
      _2004: Function.prototype.call.bind(DataView.prototype.getInt16),
      _2005: Function.prototype.call.bind(DataView.prototype.setInt16),
      _2006: Function.prototype.call.bind(DataView.prototype.getUint32),
      _2007: Function.prototype.call.bind(DataView.prototype.setUint32),
      _2008: Function.prototype.call.bind(DataView.prototype.getInt32),
      _2009: Function.prototype.call.bind(DataView.prototype.setInt32),
      _2012: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _2013: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _2014: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _2015: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _2016: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _2017: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _2030: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _2031: (handle) => clearTimeout(handle),
      _2032: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _2033: (handle) => clearInterval(handle),
      _2034: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _2035: () => Date.now(),
      _2040: o => Object.keys(o),
      _2041: x0 => x0.deviceMemory,
      _2043: () => new XMLHttpRequest(),
      _2044: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _2045: x0 => x0.send(),
      _2051: () => new AbortController(),
      _2052: x0 => x0.abort(),
      _2053: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _2054: (x0,x1) => globalThis.fetch(x0,x1),
      _2055: (x0,x1) => x0.get(x1),
      _2056: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._2056(f,arguments.length,x0,x1,x2) }),
      _2057: (x0,x1) => x0.forEach(x1),
      _2058: x0 => x0.getReader(),
      _2059: x0 => x0.cancel(),
      _2060: x0 => x0.read(),
      _2062: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _2063: (x0,x1) => x0.send(x1),
      _2065: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2065(f,arguments.length,x0) }),
      _2066: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2066(f,arguments.length,x0) }),
      _2071: (x0,x1) => x0.matchMedia(x1),
      _2072: x0 => x0.trustedTypes,
      _2073: (x0,x1) => { x0.src = x1 },
      _2074: (x0,x1) => x0.createScriptURL(x1),
      _2075: x0 => x0.nonce,
      _2076: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2076(f,arguments.length,x0) }),
      _2083: () => globalThis.window.flutter_inappwebview,
      _2087: (x0,x1) => { x0.nativeCommunication = x1 },
      _2088: (x0,x1) => x0.key(x1),
      _2089: x0 => x0.trustedTypes,
      _2090: (x0,x1) => { x0.text = x1 },
      _2100: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2101: (x0,x1) => x0.exec(x1),
      _2102: (x0,x1) => x0.test(x1),
      _2103: x0 => x0.pop(),
      _2105: o => o === undefined,
      _2107: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2109: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2110: o => o instanceof RegExp,
      _2111: (l, r) => l === r,
      _2112: o => o,
      _2113: o => o,
      _2114: o => o,
      _2115: b => !!b,
      _2116: o => o.length,
      _2118: (o, i) => o[i],
      _2119: f => f.dartFunction,
      _2120: () => ({}),
      _2121: () => [],
      _2123: () => globalThis,
      _2124: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2125: (o, p) => p in o,
      _2126: (o, p) => o[p],
      _2127: (o, p, v) => o[p] = v,
      _2128: (o, m, a) => o[m].apply(o, a),
      _2130: o => String(o),
      _2131: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _2132: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        return 18;
      },
      _2133: o => [o],
      _2134: (o0, o1) => [o0, o1],
      _2135: (o0, o1, o2) => [o0, o1, o2],
      _2136: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _2137: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2138: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2139: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2140: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2141: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2142: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2143: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2144: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2145: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2146: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2147: x0 => new ArrayBuffer(x0),
      _2148: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2150: x0 => x0.index,
      _2151: x0 => x0.groups,
      _2152: x0 => x0.flags,
      _2153: x0 => x0.multiline,
      _2154: x0 => x0.ignoreCase,
      _2155: x0 => x0.unicode,
      _2156: x0 => x0.dotAll,
      _2157: (x0,x1) => { x0.lastIndex = x1 },
      _2158: (o, p) => p in o,
      _2159: (o, p) => o[p],
      _2160: (o, p, v) => o[p] = v,
      _2161: (o, p) => delete o[p],
      _2162: x0 => x0.random(),
      _2163: (x0,x1) => x0.getRandomValues(x1),
      _2164: () => globalThis.crypto,
      _2165: () => globalThis.Math,
      _2166: Function.prototype.call.bind(Number.prototype.toString),
      _2167: Function.prototype.call.bind(BigInt.prototype.toString),
      _2168: Function.prototype.call.bind(Number.prototype.toString),
      _2169: (d, digits) => d.toFixed(digits),
      _2251: () => globalThis.google.accounts.id,
      _2265: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2265(f,arguments.length,x0) }),
      _2268: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16) => ({client_id: x0,auto_select: x1,callback: x2,login_uri: x3,native_callback: x4,cancel_on_tap_outside: x5,prompt_parent_id: x6,nonce: x7,context: x8,state_cookie_domain: x9,ux_mode: x10,allowed_parent_origin: x11,intermediate_iframe_close_callback: x12,itp_support: x13,login_hint: x14,hd: x15,use_fedcm_for_prompt: x16}),
      _2279: x0 => x0.error,
      _2281: x0 => x0.credential,
      _2292: x0 => { globalThis.onGoogleLibraryLoad = x0 },
      _2293: f => finalizeWrapper(f, function() { return dartInstance.exports._2293(f,arguments.length) }),
      _2338: x0 => x0.status,
      _2343: x0 => x0.responseText,
      _2418: x0 => x0.style,
      _2617: (x0,x1) => { x0.nonce = x1 },
      _2894: x0 => x0.src,
      _2895: (x0,x1) => { x0.src = x1 },
      _2898: x0 => x0.name,
      _2899: (x0,x1) => { x0.name = x1 },
      _2900: x0 => x0.sandbox,
      _2901: x0 => x0.allow,
      _2902: (x0,x1) => { x0.allow = x1 },
      _2903: x0 => x0.allowFullscreen,
      _2904: (x0,x1) => { x0.allowFullscreen = x1 },
      _2909: x0 => x0.referrerPolicy,
      _2910: (x0,x1) => { x0.referrerPolicy = x1 },
      _3655: (x0,x1) => { x0.src = x1 },
      _3657: (x0,x1) => { x0.type = x1 },
      _3661: (x0,x1) => { x0.async = x1 },
      _3663: (x0,x1) => { x0.defer = x1 },
      _3665: (x0,x1) => { x0.crossOrigin = x1 },
      _3667: (x0,x1) => { x0.text = x1 },
      _3669: (x0,x1) => { x0.integrity = x1 },
      _4124: () => globalThis.window,
      _4163: x0 => x0.document,
      _4166: x0 => x0.location,
      _4185: x0 => x0.navigator,
      _4189: x0 => x0.screen,
      _4201: x0 => x0.devicePixelRatio,
      _4447: x0 => x0.trustedTypes,
      _4448: x0 => x0.sessionStorage,
      _4449: x0 => x0.localStorage,
      _4459: x0 => x0.origin,
      _4464: x0 => x0.hostname,
      _4468: x0 => x0.pathname,
      _4569: x0 => x0.platform,
      _4572: x0 => x0.userAgent,
      _4578: x0 => x0.onLine,
      _4780: x0 => x0.length,
      _6725: x0 => x0.signal,
      _6734: x0 => x0.length,
      _6774: x0 => x0.baseURI,
      _6780: x0 => x0.firstChild,
      _6791: () => globalThis.document,
      _6871: x0 => x0.body,
      _6873: x0 => x0.head,
      _7202: x0 => x0.id,
      _7203: (x0,x1) => { x0.id = x1 },
      _7433: x0 => x0.length,
      _8548: x0 => x0.value,
      _8550: x0 => x0.done,
      _9247: x0 => x0.url,
      _9249: x0 => x0.status,
      _9251: x0 => x0.statusText,
      _9252: x0 => x0.headers,
      _9253: x0 => x0.body,
      _9520: x0 => x0.type,
      _9535: x0 => x0.matches,
      _9546: x0 => x0.availWidth,
      _9547: x0 => x0.availHeight,
      _9552: x0 => x0.orientation,
      _11379: (x0,x1) => { x0.border = x1 },
      _11657: (x0,x1) => { x0.display = x1 },
      _11821: (x0,x1) => { x0.height = x1 },
      _12511: (x0,x1) => { x0.width = x1 },
      _12879: x0 => x0.name,
      _13594: () => globalThis.console,
      _13619: () => globalThis.window.flutterCanvasKit,
      _13620: () => globalThis.window._flutter_skwasmInstance,
      _13621: x0 => x0.name,
      _13622: x0 => x0.message,
      _13623: x0 => x0.code,
      _13625: x0 => x0.customData,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      S: new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
