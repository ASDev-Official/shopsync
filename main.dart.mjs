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
      _5: o => Object.keys(o),
      _7: (o,s,v) => o[s] = v,
      _36: x0 => new Array(x0),
      _38: x0 => x0.length,
      _40: (x0,x1) => x0[x1],
      _41: (x0,x1,x2) => { x0[x1] = x2 },
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
      _87: x0 => x0.buffer,
      _88: x0 => x0.wasmMemory,
      _89: () => globalThis.window._flutter_skwasmInstance,
      _90: x0 => x0.rasterStartMilliseconds,
      _91: x0 => x0.rasterEndMilliseconds,
      _92: x0 => x0.imageBitmaps,
      _196: x0 => x0.stopPropagation(),
      _197: x0 => x0.preventDefault(),
      _199: x0 => x0.remove(),
      _200: (x0,x1) => x0.append(x1),
      _201: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _246: x0 => x0.unlock(),
      _247: x0 => x0.getReader(),
      _248: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _249: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _250: (x0,x1) => x0.item(x1),
      _251: x0 => x0.next(),
      _252: x0 => x0.now(),
      _253: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._253(f,arguments.length,x0) }),
      _254: (x0,x1) => x0.addListener(x1),
      _255: (x0,x1) => x0.removeListener(x1),
      _256: (x0,x1) => x0.matchMedia(x1),
      _257: (x0,x1) => x0.revokeObjectURL(x1),
      _258: x0 => x0.close(),
      _259: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _260: x0 => new window.ImageDecoder(x0),
      _261: x0 => ({frameIndex: x0}),
      _262: (x0,x1) => x0.decode(x1),
      _263: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._263(f,arguments.length,x0) }),
      _264: (x0,x1) => x0.getModifierState(x1),
      _265: (x0,x1) => x0.removeProperty(x1),
      _266: (x0,x1) => x0.prepend(x1),
      _267: x0 => new Intl.Locale(x0),
      _268: x0 => x0.disconnect(),
      _269: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._269(f,arguments.length,x0) }),
      _270: (x0,x1) => x0.getAttribute(x1),
      _271: (x0,x1) => x0.contains(x1),
      _272: (x0,x1) => x0.querySelector(x1),
      _273: x0 => x0.blur(),
      _274: x0 => x0.hasFocus(),
      _275: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _276: (x0,x1) => x0.hasAttribute(x1),
      _277: (x0,x1) => x0.getModifierState(x1),
      _278: (x0,x1) => x0.createTextNode(x1),
      _279: (x0,x1) => x0.appendChild(x1),
      _280: (x0,x1) => x0.removeAttribute(x1),
      _281: x0 => x0.getBoundingClientRect(),
      _282: (x0,x1) => x0.observe(x1),
      _283: x0 => x0.disconnect(),
      _284: (x0,x1) => x0.closest(x1),
      _707: () => globalThis.window.flutterConfiguration,
      _709: x0 => x0.assetBase,
      _714: x0 => x0.canvasKitMaximumSurfaces,
      _715: x0 => x0.debugShowSemanticsNodes,
      _716: x0 => x0.hostElement,
      _717: x0 => x0.multiViewEnabled,
      _718: x0 => x0.nonce,
      _720: x0 => x0.fontFallbackBaseUrl,
      _730: x0 => x0.console,
      _731: x0 => x0.devicePixelRatio,
      _732: x0 => x0.document,
      _733: x0 => x0.history,
      _734: x0 => x0.innerHeight,
      _735: x0 => x0.innerWidth,
      _736: x0 => x0.location,
      _737: x0 => x0.navigator,
      _738: x0 => x0.visualViewport,
      _739: x0 => x0.performance,
      _741: x0 => x0.URL,
      _743: (x0,x1) => x0.getComputedStyle(x1),
      _744: x0 => x0.screen,
      _745: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._745(f,arguments.length,x0) }),
      _746: (x0,x1) => x0.requestAnimationFrame(x1),
      _751: (x0,x1) => x0.warn(x1),
      _753: (x0,x1) => x0.debug(x1),
      _754: x0 => globalThis.parseFloat(x0),
      _755: () => globalThis.window,
      _756: () => globalThis.Intl,
      _757: () => globalThis.Symbol,
      _758: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _760: x0 => x0.clipboard,
      _761: x0 => x0.maxTouchPoints,
      _762: x0 => x0.vendor,
      _763: x0 => x0.language,
      _764: x0 => x0.platform,
      _765: x0 => x0.userAgent,
      _766: (x0,x1) => x0.vibrate(x1),
      _767: x0 => x0.languages,
      _768: x0 => x0.documentElement,
      _769: (x0,x1) => x0.querySelector(x1),
      _772: (x0,x1) => x0.createElement(x1),
      _775: (x0,x1) => x0.createEvent(x1),
      _776: x0 => x0.activeElement,
      _779: x0 => x0.head,
      _780: x0 => x0.body,
      _782: (x0,x1) => { x0.title = x1 },
      _785: x0 => x0.visibilityState,
      _786: () => globalThis.document,
      _787: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._787(f,arguments.length,x0) }),
      _788: (x0,x1) => x0.dispatchEvent(x1),
      _796: x0 => x0.target,
      _798: x0 => x0.timeStamp,
      _799: x0 => x0.type,
      _801: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _808: x0 => x0.firstChild,
      _812: x0 => x0.parentElement,
      _814: (x0,x1) => { x0.textContent = x1 },
      _815: x0 => x0.parentNode,
      _816: x0 => x0.nextSibling,
      _817: (x0,x1) => x0.removeChild(x1),
      _818: x0 => x0.isConnected,
      _826: x0 => x0.clientHeight,
      _827: x0 => x0.clientWidth,
      _828: x0 => x0.offsetHeight,
      _829: x0 => x0.offsetWidth,
      _830: x0 => x0.id,
      _831: (x0,x1) => { x0.id = x1 },
      _834: (x0,x1) => { x0.spellcheck = x1 },
      _835: x0 => x0.tagName,
      _836: x0 => x0.style,
      _838: (x0,x1) => x0.querySelectorAll(x1),
      _839: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _840: (x0,x1) => { x0.tabIndex = x1 },
      _841: x0 => x0.tabIndex,
      _842: (x0,x1) => x0.focus(x1),
      _843: x0 => x0.scrollTop,
      _844: (x0,x1) => { x0.scrollTop = x1 },
      _845: x0 => x0.scrollLeft,
      _846: (x0,x1) => { x0.scrollLeft = x1 },
      _847: x0 => x0.classList,
      _849: (x0,x1) => { x0.className = x1 },
      _851: (x0,x1) => x0.getElementsByClassName(x1),
      _852: x0 => x0.click(),
      _853: (x0,x1) => x0.attachShadow(x1),
      _856: x0 => x0.computedStyleMap(),
      _857: (x0,x1) => x0.get(x1),
      _863: (x0,x1) => x0.getPropertyValue(x1),
      _864: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _865: x0 => x0.offsetLeft,
      _866: x0 => x0.offsetTop,
      _867: x0 => x0.offsetParent,
      _869: (x0,x1) => { x0.name = x1 },
      _870: x0 => x0.content,
      _871: (x0,x1) => { x0.content = x1 },
      _875: (x0,x1) => { x0.src = x1 },
      _876: x0 => x0.naturalWidth,
      _877: x0 => x0.naturalHeight,
      _881: (x0,x1) => { x0.crossOrigin = x1 },
      _883: (x0,x1) => { x0.decoding = x1 },
      _884: x0 => x0.decode(),
      _889: (x0,x1) => { x0.nonce = x1 },
      _894: (x0,x1) => { x0.width = x1 },
      _896: (x0,x1) => { x0.height = x1 },
      _899: (x0,x1) => x0.getContext(x1),
      _960: x0 => x0.width,
      _961: x0 => x0.height,
      _963: (x0,x1) => x0.fetch(x1),
      _964: x0 => x0.status,
      _966: x0 => x0.body,
      _967: x0 => x0.arrayBuffer(),
      _970: x0 => x0.read(),
      _971: x0 => x0.value,
      _972: x0 => x0.done,
      _979: x0 => x0.name,
      _980: x0 => x0.x,
      _981: x0 => x0.y,
      _984: x0 => x0.top,
      _985: x0 => x0.right,
      _986: x0 => x0.bottom,
      _987: x0 => x0.left,
      _997: x0 => x0.height,
      _998: x0 => x0.width,
      _999: x0 => x0.scale,
      _1000: (x0,x1) => { x0.value = x1 },
      _1003: (x0,x1) => { x0.placeholder = x1 },
      _1005: (x0,x1) => { x0.name = x1 },
      _1006: x0 => x0.selectionDirection,
      _1007: x0 => x0.selectionStart,
      _1008: x0 => x0.selectionEnd,
      _1011: x0 => x0.value,
      _1013: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1014: x0 => x0.readText(),
      _1015: (x0,x1) => x0.writeText(x1),
      _1017: x0 => x0.altKey,
      _1018: x0 => x0.code,
      _1019: x0 => x0.ctrlKey,
      _1020: x0 => x0.key,
      _1021: x0 => x0.keyCode,
      _1022: x0 => x0.location,
      _1023: x0 => x0.metaKey,
      _1024: x0 => x0.repeat,
      _1025: x0 => x0.shiftKey,
      _1026: x0 => x0.isComposing,
      _1028: x0 => x0.state,
      _1029: (x0,x1) => x0.go(x1),
      _1031: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1032: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1033: x0 => x0.pathname,
      _1034: x0 => x0.search,
      _1035: x0 => x0.hash,
      _1039: x0 => x0.state,
      _1042: (x0,x1) => x0.createObjectURL(x1),
      _1044: x0 => new Blob(x0),
      _1046: x0 => new MutationObserver(x0),
      _1047: (x0,x1,x2) => x0.observe(x1,x2),
      _1048: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1048(f,arguments.length,x0,x1) }),
      _1051: x0 => x0.attributeName,
      _1052: x0 => x0.type,
      _1053: x0 => x0.matches,
      _1054: x0 => x0.matches,
      _1058: x0 => x0.relatedTarget,
      _1060: x0 => x0.clientX,
      _1061: x0 => x0.clientY,
      _1062: x0 => x0.offsetX,
      _1063: x0 => x0.offsetY,
      _1066: x0 => x0.button,
      _1067: x0 => x0.buttons,
      _1068: x0 => x0.ctrlKey,
      _1072: x0 => x0.pointerId,
      _1073: x0 => x0.pointerType,
      _1074: x0 => x0.pressure,
      _1075: x0 => x0.tiltX,
      _1076: x0 => x0.tiltY,
      _1077: x0 => x0.getCoalescedEvents(),
      _1080: x0 => x0.deltaX,
      _1081: x0 => x0.deltaY,
      _1082: x0 => x0.wheelDeltaX,
      _1083: x0 => x0.wheelDeltaY,
      _1084: x0 => x0.deltaMode,
      _1091: x0 => x0.changedTouches,
      _1094: x0 => x0.clientX,
      _1095: x0 => x0.clientY,
      _1098: x0 => x0.data,
      _1101: (x0,x1) => { x0.disabled = x1 },
      _1103: (x0,x1) => { x0.type = x1 },
      _1104: (x0,x1) => { x0.max = x1 },
      _1105: (x0,x1) => { x0.min = x1 },
      _1106: x0 => x0.value,
      _1107: (x0,x1) => { x0.value = x1 },
      _1108: x0 => x0.disabled,
      _1109: (x0,x1) => { x0.disabled = x1 },
      _1111: (x0,x1) => { x0.placeholder = x1 },
      _1112: (x0,x1) => { x0.name = x1 },
      _1115: (x0,x1) => { x0.autocomplete = x1 },
      _1116: x0 => x0.selectionDirection,
      _1117: x0 => x0.selectionStart,
      _1119: x0 => x0.selectionEnd,
      _1122: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1123: (x0,x1) => x0.add(x1),
      _1126: (x0,x1) => { x0.noValidate = x1 },
      _1127: (x0,x1) => { x0.method = x1 },
      _1128: (x0,x1) => { x0.action = x1 },
      _1154: x0 => x0.orientation,
      _1155: x0 => x0.width,
      _1156: x0 => x0.height,
      _1157: (x0,x1) => x0.lock(x1),
      _1176: x0 => new ResizeObserver(x0),
      _1179: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1179(f,arguments.length,x0,x1) }),
      _1187: x0 => x0.length,
      _1188: x0 => x0.iterator,
      _1189: x0 => x0.Segmenter,
      _1190: x0 => x0.v8BreakIterator,
      _1191: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1194: x0 => x0.language,
      _1195: x0 => x0.script,
      _1196: x0 => x0.region,
      _1214: x0 => x0.done,
      _1215: x0 => x0.value,
      _1216: x0 => x0.index,
      _1220: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1221: (x0,x1) => x0.adoptText(x1),
      _1222: x0 => x0.first(),
      _1223: x0 => x0.next(),
      _1224: x0 => x0.current(),
      _1238: x0 => x0.hostElement,
      _1239: x0 => x0.viewConstraints,
      _1242: x0 => x0.maxHeight,
      _1243: x0 => x0.maxWidth,
      _1244: x0 => x0.minHeight,
      _1245: x0 => x0.minWidth,
      _1246: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1246(f,arguments.length,x0) }),
      _1247: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1247(f,arguments.length,x0) }),
      _1248: (x0,x1) => ({addView: x0,removeView: x1}),
      _1251: x0 => x0.loader,
      _1252: () => globalThis._flutter,
      _1253: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1254: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1254(f,arguments.length,x0) }),
      _1255: f => finalizeWrapper(f, function() { return dartInstance.exports._1255(f,arguments.length) }),
      _1256: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1259: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1259(f,arguments.length,x0) }),
      _1260: x0 => ({runApp: x0}),
      _1262: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1262(f,arguments.length,x0,x1) }),
      _1263: x0 => x0.length,
      _1264: () => globalThis.window.ImageDecoder,
      _1265: x0 => x0.tracks,
      _1267: x0 => x0.completed,
      _1269: x0 => x0.image,
      _1275: x0 => x0.displayWidth,
      _1276: x0 => x0.displayHeight,
      _1277: x0 => x0.duration,
      _1280: x0 => x0.ready,
      _1281: x0 => x0.selectedTrack,
      _1282: x0 => x0.repetitionCount,
      _1283: x0 => x0.frameCount,
      _1338: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1338(f,arguments.length,x0,x1,x2) }),
      _1339: (x0,x1) => x0.append(x1),
      _1341: x0 => x0.remove(),
      _1342: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1343: (x0,x1) => x0.removeAttribute(x1),
      _1345: (x0,x1) => x0.getResponseHeader(x1),
      _1368: (x0,x1) => x0.item(x1),
      _1371: (x0,x1) => { x0.csp = x1 },
      _1372: x0 => x0.csp,
      _1373: (x0,x1) => x0.getCookieExpirationDate(x1),
      _1374: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1374(f,arguments.length,x0) }),
      _1375: x0 => ({createScriptURL: x0}),
      _1376: (x0,x1,x2) => x0.createPolicy(x1,x2),
      _1377: (x0,x1,x2) => x0.createScriptURL(x1,x2),
      _1378: x0 => x0.hasChildNodes(),
      _1379: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _1380: (x0,x1) => x0.querySelectorAll(x1),
      _1381: (x0,x1) => x0.item(x1),
      _1382: x0 => ({type: x0}),
      _1385: (x0,x1) => x0.createElement(x1),
      _1388: x0 => globalThis.Sentry.init(x0),
      _1389: () => new Sentry.getClient(),
      _1390: x0 => x0.getOptions(),
      _1394: () => globalThis.Sentry.globalHandlersIntegration(),
      _1395: () => globalThis.Sentry.dedupeIntegration(),
      _1396: () => globalThis.Sentry.close(),
      _1397: (x0,x1) => x0.sendEnvelope(x1),
      _1400: () => globalThis.globalThis,
      _1402: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1403: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1404: (x0,x1) => x0.getAttribute(x1),
      _1408: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1426: x0 => x0.toArray(),
      _1427: x0 => x0.toUint8Array(),
      _1428: x0 => ({serverTimestamps: x0}),
      _1429: x0 => ({source: x0}),
      _1430: x0 => ({merge: x0}),
      _1432: x0 => new firebase_firestore.FieldPath(x0),
      _1433: (x0,x1) => new firebase_firestore.FieldPath(x0,x1),
      _1434: (x0,x1,x2) => new firebase_firestore.FieldPath(x0,x1,x2),
      _1435: (x0,x1,x2,x3) => new firebase_firestore.FieldPath(x0,x1,x2,x3),
      _1436: (x0,x1,x2,x3,x4) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4),
      _1437: (x0,x1,x2,x3,x4,x5) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5),
      _1438: (x0,x1,x2,x3,x4,x5,x6) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6),
      _1439: (x0,x1,x2,x3,x4,x5,x6,x7) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7),
      _1440: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      _1441: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9),
      _1442: () => globalThis.firebase_firestore.documentId(),
      _1443: (x0,x1) => new firebase_firestore.GeoPoint(x0,x1),
      _1444: x0 => globalThis.firebase_firestore.vector(x0),
      _1445: x0 => globalThis.firebase_firestore.Bytes.fromUint8Array(x0),
      _1446: x0 => globalThis.firebase_firestore.writeBatch(x0),
      _1447: (x0,x1) => globalThis.firebase_firestore.collection(x0,x1),
      _1449: (x0,x1) => globalThis.firebase_firestore.doc(x0,x1),
      _1452: x0 => x0.call(),
      _1476: x0 => x0.commit(),
      _1477: (x0,x1) => x0.delete(x1),
      _1479: (x0,x1,x2) => x0.set(x1,x2),
      _1480: (x0,x1,x2) => x0.update(x1,x2),
      _1481: x0 => globalThis.firebase_firestore.deleteDoc(x0),
      _1482: x0 => globalThis.firebase_firestore.getDoc(x0),
      _1483: x0 => globalThis.firebase_firestore.getDocFromServer(x0),
      _1484: x0 => globalThis.firebase_firestore.getDocFromCache(x0),
      _1485: (x0,x1) => ({includeMetadataChanges: x0,source: x1}),
      _1486: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1486(f,arguments.length,x0) }),
      _1487: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1487(f,arguments.length,x0) }),
      _1488: (x0,x1,x2,x3) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2,x3),
      _1489: (x0,x1,x2) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2),
      _1490: (x0,x1,x2) => globalThis.firebase_firestore.setDoc(x0,x1,x2),
      _1491: (x0,x1) => globalThis.firebase_firestore.setDoc(x0,x1),
      _1492: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1493: x0 => globalThis.firebase_firestore.getDocs(x0),
      _1494: x0 => globalThis.firebase_firestore.getDocsFromServer(x0),
      _1495: x0 => globalThis.firebase_firestore.getDocsFromCache(x0),
      _1496: x0 => globalThis.firebase_firestore.limit(x0),
      _1497: x0 => globalThis.firebase_firestore.limitToLast(x0),
      _1498: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1498(f,arguments.length,x0) }),
      _1499: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1499(f,arguments.length,x0) }),
      _1500: (x0,x1) => globalThis.firebase_firestore.orderBy(x0,x1),
      _1502: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      _1504: x0 => globalThis.firebase_firestore.doc(x0),
      _1507: (x0,x1) => x0.data(x1),
      _1511: x0 => x0.docChanges(),
      _1519: () => globalThis.firebase_firestore.deleteField(),
      _1520: () => globalThis.firebase_firestore.serverTimestamp(),
      _1522: () => globalThis.firebase_firestore.count(),
      _1523: x0 => globalThis.firebase_firestore.sum(x0),
      _1524: x0 => globalThis.firebase_firestore.average(x0),
      _1525: (x0,x1) => globalThis.firebase_firestore.getAggregateFromServer(x0,x1),
      _1526: x0 => x0.data(),
      _1528: (x0,x1) => globalThis.firebase_firestore.getFirestore(x0,x1),
      _1530: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      _1531: f => finalizeWrapper(f, function() { return dartInstance.exports._1531(f,arguments.length) }),
      _1548: () => globalThis.firebase_firestore.updateDoc,
      _1549: () => globalThis.firebase_firestore.or,
      _1550: () => globalThis.firebase_firestore.and,
      _1555: x0 => x0.path,
      _1558: () => globalThis.firebase_firestore.GeoPoint,
      _1559: x0 => x0.latitude,
      _1560: x0 => x0.longitude,
      _1562: () => globalThis.firebase_firestore.VectorValue,
      _1563: () => globalThis.firebase_firestore.Bytes,
      _1566: x0 => x0.type,
      _1568: x0 => x0.doc,
      _1570: x0 => x0.oldIndex,
      _1572: x0 => x0.newIndex,
      _1574: () => globalThis.firebase_firestore.DocumentReference,
      _1578: x0 => x0.path,
      _1587: x0 => x0.metadata,
      _1588: x0 => x0.ref,
      _1593: x0 => x0.docs,
      _1595: x0 => x0.metadata,
      _1599: () => globalThis.firebase_firestore.Timestamp,
      _1600: x0 => x0.seconds,
      _1601: x0 => x0.nanoseconds,
      _1637: x0 => x0.hasPendingWrites,
      _1639: x0 => x0.fromCache,
      _1646: x0 => x0.source,
      _1651: () => globalThis.firebase_firestore.startAfter,
      _1652: () => globalThis.firebase_firestore.startAt,
      _1653: () => globalThis.firebase_firestore.endBefore,
      _1654: () => globalThis.firebase_firestore.endAt,
      _1655: () => globalThis.firebase_firestore.arrayRemove,
      _1656: () => globalThis.firebase_firestore.arrayUnion,
      _1667: (x0,x1) => x0.querySelector(x1),
      _1679: (x0,x1) => globalThis.firebase_auth.linkWithPopup(x0,x1),
      _1685: x0 => x0.reload(),
      _1688: (x0,x1) => globalThis.firebase_auth.unlink(x0,x1),
      _1692: (x0,x1) => globalThis.firebase_auth.updateProfile(x0,x1),
      _1695: x0 => x0.toJSON(),
      _1696: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1696(f,arguments.length,x0) }),
      _1697: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1697(f,arguments.length,x0) }),
      _1698: (x0,x1,x2) => x0.onAuthStateChanged(x1,x2),
      _1699: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1699(f,arguments.length,x0) }),
      _1700: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1700(f,arguments.length,x0) }),
      _1701: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1701(f,arguments.length,x0) }),
      _1702: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1702(f,arguments.length,x0) }),
      _1703: (x0,x1,x2) => x0.onIdTokenChanged(x1,x2),
      _1707: (x0,x1,x2) => globalThis.firebase_auth.createUserWithEmailAndPassword(x0,x1,x2),
      _1713: (x0,x1,x2) => globalThis.firebase_auth.sendPasswordResetEmail(x0,x1,x2),
      _1717: (x0,x1,x2) => globalThis.firebase_auth.signInWithEmailAndPassword(x0,x1,x2),
      _1720: (x0,x1) => globalThis.firebase_auth.signInWithPopup(x0,x1),
      _1722: x0 => x0.signOut(),
      _1723: (x0,x1) => globalThis.firebase_auth.connectAuthEmulator(x0,x1),
      _1738: () => new firebase_auth.GoogleAuthProvider(),
      _1739: (x0,x1) => x0.addScope(x1),
      _1740: (x0,x1) => x0.setCustomParameters(x1),
      _1746: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromResult(x0),
      _1761: x0 => globalThis.firebase_auth.getAdditionalUserInfo(x0),
      _1762: (x0,x1,x2) => ({errorMap: x0,persistence: x1,popupRedirectResolver: x2}),
      _1763: (x0,x1) => globalThis.firebase_auth.initializeAuth(x0,x1),
      _1769: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromError(x0),
      _1772: (x0,x1) => ({displayName: x0,photoURL: x1}),
      _1784: () => globalThis.firebase_auth.debugErrorMap,
      _1787: () => globalThis.firebase_auth.browserSessionPersistence,
      _1789: () => globalThis.firebase_auth.browserLocalPersistence,
      _1791: () => globalThis.firebase_auth.indexedDBLocalPersistence,
      _1794: x0 => globalThis.firebase_auth.multiFactor(x0),
      _1795: (x0,x1) => globalThis.firebase_auth.getMultiFactorResolver(x0,x1),
      _1797: x0 => x0.currentUser,
      _1801: x0 => x0.tenantId,
      _1811: x0 => x0.displayName,
      _1812: x0 => x0.email,
      _1813: x0 => x0.phoneNumber,
      _1814: x0 => x0.photoURL,
      _1815: x0 => x0.providerId,
      _1816: x0 => x0.uid,
      _1817: x0 => x0.emailVerified,
      _1818: x0 => x0.isAnonymous,
      _1819: x0 => x0.providerData,
      _1820: x0 => x0.refreshToken,
      _1821: x0 => x0.tenantId,
      _1822: x0 => x0.metadata,
      _1824: x0 => x0.providerId,
      _1825: x0 => x0.signInMethod,
      _1826: x0 => x0.accessToken,
      _1827: x0 => x0.idToken,
      _1828: x0 => x0.secret,
      _1839: x0 => x0.creationTime,
      _1840: x0 => x0.lastSignInTime,
      _1845: x0 => x0.code,
      _1847: x0 => x0.message,
      _1859: x0 => x0.email,
      _1860: x0 => x0.phoneNumber,
      _1861: x0 => x0.tenantId,
      _1884: x0 => x0.user,
      _1887: x0 => x0.providerId,
      _1888: x0 => x0.profile,
      _1889: x0 => x0.username,
      _1890: x0 => x0.isNewUser,
      _1893: () => globalThis.firebase_auth.browserPopupRedirectResolver,
      _1898: x0 => x0.displayName,
      _1899: x0 => x0.enrollmentTime,
      _1900: x0 => x0.factorId,
      _1901: x0 => x0.uid,
      _1903: x0 => x0.hints,
      _1904: x0 => x0.session,
      _1906: x0 => x0.phoneNumber,
      _1916: x0 => ({displayName: x0}),
      _1917: x0 => ({photoURL: x0}),
      _1918: (x0,x1) => x0.getItem(x1),
      _1923: (x0,x1) => x0.appendChild(x1),
      _1925: (x0,x1) => x0.removeItem(x1),
      _1926: (x0,x1,x2) => x0.setItem(x1,x2),
      _1929: (x0,x1,x2,x3,x4,x5,x6,x7) => ({apiKey: x0,authDomain: x1,databaseURL: x2,projectId: x3,storageBucket: x4,messagingSenderId: x5,measurementId: x6,appId: x7}),
      _1930: (x0,x1) => globalThis.firebase_core.initializeApp(x0,x1),
      _1931: x0 => globalThis.firebase_core.getApp(x0),
      _1932: () => globalThis.firebase_core.getApp(),
      _1933: (x0,x1,x2) => globalThis.firebase_core.registerVersion(x0,x1,x2),
      _1935: () => globalThis.firebase_core.SDK_VERSION,
      _1941: x0 => x0.apiKey,
      _1943: x0 => x0.authDomain,
      _1945: x0 => x0.databaseURL,
      _1947: x0 => x0.projectId,
      _1949: x0 => x0.storageBucket,
      _1951: x0 => x0.messagingSenderId,
      _1953: x0 => x0.measurementId,
      _1955: x0 => x0.appId,
      _1957: x0 => x0.name,
      _1958: x0 => x0.options,
      _1959: (x0,x1) => x0.debug(x1),
      _1960: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1960(f,arguments.length,x0) }),
      _1961: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1961(f,arguments.length,x0,x1) }),
      _1962: (x0,x1) => ({createScript: x0,createScriptURL: x1}),
      _1963: (x0,x1) => x0.createScriptURL(x1),
      _1964: (x0,x1,x2) => x0.createScript(x1,x2),
      _1965: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1965(f,arguments.length,x0) }),
      _1967: (x0,x1) => x0.initialize(x1),
      _1973: Date.now,
      _1974: secondsSinceEpoch => {
        const date = new Date(secondsSinceEpoch * 1000);
        const match = /\((.*)\)/.exec(date.toString());
        if (match == null) {
            // This should never happen on any recent browser.
            return '';
        }
        return match[1];
      },
      _1975: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1976: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1977: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1978: () => typeof dartUseDateNowForTicks !== "undefined",
      _1979: () => 1000 * performance.now(),
      _1980: () => Date.now(),
      _1981: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1982: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1983: () => new WeakMap(),
      _1984: (map, o) => map.get(o),
      _1985: (map, o, v) => map.set(o, v),
      _1986: x0 => new WeakRef(x0),
      _1987: x0 => x0.deref(),
      _1994: () => globalThis.WeakRef,
      _1997: s => JSON.stringify(s),
      _1998: s => printToConsole(s),
      _1999: (o, p, r) => o.replaceAll(p, () => r),
      _2000: (o, p, r) => o.replace(p, () => r),
      _2001: Function.prototype.call.bind(String.prototype.toLowerCase),
      _2002: s => s.toUpperCase(),
      _2003: s => s.trim(),
      _2004: s => s.trimLeft(),
      _2005: s => s.trimRight(),
      _2006: (string, times) => string.repeat(times),
      _2007: Function.prototype.call.bind(String.prototype.indexOf),
      _2008: (s, p, i) => s.lastIndexOf(p, i),
      _2009: (string, token) => string.split(token),
      _2010: Object.is,
      _2011: o => o instanceof Array,
      _2012: (a, i) => a.push(i),
      _2016: a => a.pop(),
      _2017: (a, i) => a.splice(i, 1),
      _2018: (a, s) => a.join(s),
      _2019: (a, s, e) => a.slice(s, e),
      _2021: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _2022: a => a.length,
      _2024: (a, i) => a[i],
      _2025: (a, i, v) => a[i] = v,
      _2027: o => {
        if (o instanceof ArrayBuffer) return 0;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 1;
        }
        return 2;
      },
      _2028: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _2030: o => o instanceof Uint8Array,
      _2031: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _2032: o => o instanceof Int8Array,
      _2033: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _2034: o => o instanceof Uint8ClampedArray,
      _2035: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _2036: o => o instanceof Uint16Array,
      _2037: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _2038: o => o instanceof Int16Array,
      _2039: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _2040: o => o instanceof Uint32Array,
      _2041: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _2042: o => o instanceof Int32Array,
      _2043: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _2045: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _2046: o => o instanceof Float32Array,
      _2047: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _2048: o => o instanceof Float64Array,
      _2049: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _2050: (t, s) => t.set(s),
      _2051: l => new DataView(new ArrayBuffer(l)),
      _2052: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _2054: o => o.buffer,
      _2055: o => o.byteOffset,
      _2056: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _2057: (b, o) => new DataView(b, o),
      _2058: (b, o, l) => new DataView(b, o, l),
      _2059: Function.prototype.call.bind(DataView.prototype.getUint8),
      _2060: Function.prototype.call.bind(DataView.prototype.setUint8),
      _2061: Function.prototype.call.bind(DataView.prototype.getInt8),
      _2062: Function.prototype.call.bind(DataView.prototype.setInt8),
      _2063: Function.prototype.call.bind(DataView.prototype.getUint16),
      _2064: Function.prototype.call.bind(DataView.prototype.setUint16),
      _2065: Function.prototype.call.bind(DataView.prototype.getInt16),
      _2066: Function.prototype.call.bind(DataView.prototype.setInt16),
      _2067: Function.prototype.call.bind(DataView.prototype.getUint32),
      _2068: Function.prototype.call.bind(DataView.prototype.setUint32),
      _2069: Function.prototype.call.bind(DataView.prototype.getInt32),
      _2070: Function.prototype.call.bind(DataView.prototype.setInt32),
      _2073: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _2074: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _2075: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _2076: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _2077: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _2078: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _2091: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _2092: (handle) => clearTimeout(handle),
      _2093: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _2094: (handle) => clearInterval(handle),
      _2095: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _2096: () => Date.now(),
      _2097: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2098: (x0,x1) => x0.exec(x1),
      _2099: (x0,x1) => x0.test(x1),
      _2100: x0 => x0.pop(),
      _2102: o => o === undefined,
      _2104: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2106: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2107: o => o instanceof RegExp,
      _2108: (l, r) => l === r,
      _2109: o => o,
      _2110: o => o,
      _2111: o => o,
      _2112: b => !!b,
      _2113: o => o.length,
      _2115: (o, i) => o[i],
      _2116: f => f.dartFunction,
      _2117: () => ({}),
      _2118: () => [],
      _2120: () => globalThis,
      _2121: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2122: (o, p) => p in o,
      _2123: (o, p) => o[p],
      _2124: (o, p, v) => o[p] = v,
      _2125: (o, m, a) => o[m].apply(o, a),
      _2127: o => String(o),
      _2128: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _2129: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2129(f,arguments.length,x0) }),
      _2130: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._2130(f,arguments.length,x0,x1) }),
      _2131: o => {
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
        if (o instanceof Promise) return 18;
        return 19;
      },
      _2132: o => [o],
      _2133: (o0, o1) => [o0, o1],
      _2134: (o0, o1, o2) => [o0, o1, o2],
      _2135: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _2136: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2137: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2138: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2139: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2140: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2141: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2142: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2143: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2144: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2145: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2146: x0 => new ArrayBuffer(x0),
      _2147: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2149: x0 => x0.index,
      _2150: x0 => x0.groups,
      _2151: x0 => x0.flags,
      _2152: x0 => x0.multiline,
      _2153: x0 => x0.ignoreCase,
      _2154: x0 => x0.unicode,
      _2155: x0 => x0.dotAll,
      _2156: (x0,x1) => { x0.lastIndex = x1 },
      _2157: (o, p) => p in o,
      _2158: (o, p) => o[p],
      _2159: (o, p, v) => o[p] = v,
      _2160: (o, p) => delete o[p],
      _2161: () => new XMLHttpRequest(),
      _2162: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _2164: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _2165: (x0,x1) => x0.send(x1),
      _2166: x0 => x0.send(),
      _2168: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2168(f,arguments.length,x0) }),
      _2169: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2169(f,arguments.length,x0) }),
      _2180: x0 => x0.deviceMemory,
      _2181: (x0,x1) => x0.matchMedia(x1),
      _2182: x0 => x0.trustedTypes,
      _2183: (x0,x1) => { x0.src = x1 },
      _2184: (x0,x1) => x0.createScriptURL(x1),
      _2185: x0 => x0.nonce,
      _2186: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2186(f,arguments.length,x0) }),
      _2187: () => new AbortController(),
      _2188: x0 => x0.abort(),
      _2189: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _2190: (x0,x1) => globalThis.fetch(x0,x1),
      _2191: (x0,x1) => x0.get(x1),
      _2192: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._2192(f,arguments.length,x0,x1,x2) }),
      _2193: (x0,x1) => x0.forEach(x1),
      _2194: x0 => x0.getReader(),
      _2195: x0 => x0.cancel(),
      _2196: x0 => x0.read(),
      _2203: () => globalThis.window.flutter_inappwebview,
      _2207: (x0,x1) => { x0.nativeCommunication = x1 },
      _2208: (x0,x1) => x0.key(x1),
      _2209: x0 => x0.trustedTypes,
      _2210: (x0,x1) => { x0.text = x1 },
      _2211: x0 => x0.random(),
      _2212: (x0,x1) => x0.getRandomValues(x1),
      _2213: () => globalThis.crypto,
      _2214: () => globalThis.Math,
      _2224: Function.prototype.call.bind(Number.prototype.toString),
      _2225: Function.prototype.call.bind(BigInt.prototype.toString),
      _2226: Function.prototype.call.bind(Number.prototype.toString),
      _2227: (d, digits) => d.toFixed(digits),
      _2309: () => globalThis.google.accounts.id,
      _2323: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2323(f,arguments.length,x0) }),
      _2326: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16) => ({client_id: x0,auto_select: x1,callback: x2,login_uri: x3,native_callback: x4,cancel_on_tap_outside: x5,prompt_parent_id: x6,nonce: x7,context: x8,state_cookie_domain: x9,ux_mode: x10,allowed_parent_origin: x11,intermediate_iframe_close_callback: x12,itp_support: x13,login_hint: x14,hd: x15,use_fedcm_for_prompt: x16}),
      _2337: x0 => x0.error,
      _2339: x0 => x0.credential,
      _2350: x0 => { globalThis.onGoogleLibraryLoad = x0 },
      _2351: f => finalizeWrapper(f, function() { return dartInstance.exports._2351(f,arguments.length) }),
      _2396: x0 => x0.status,
      _2401: x0 => x0.responseText,
      _2476: x0 => x0.style,
      _2675: (x0,x1) => { x0.nonce = x1 },
      _2952: x0 => x0.src,
      _2953: (x0,x1) => { x0.src = x1 },
      _2956: x0 => x0.name,
      _2957: (x0,x1) => { x0.name = x1 },
      _2958: x0 => x0.sandbox,
      _2959: x0 => x0.allow,
      _2960: (x0,x1) => { x0.allow = x1 },
      _2961: x0 => x0.allowFullscreen,
      _2962: (x0,x1) => { x0.allowFullscreen = x1 },
      _2967: x0 => x0.referrerPolicy,
      _2968: (x0,x1) => { x0.referrerPolicy = x1 },
      _3713: (x0,x1) => { x0.src = x1 },
      _3715: (x0,x1) => { x0.type = x1 },
      _3719: (x0,x1) => { x0.async = x1 },
      _3721: (x0,x1) => { x0.defer = x1 },
      _3723: (x0,x1) => { x0.crossOrigin = x1 },
      _3725: (x0,x1) => { x0.text = x1 },
      _3727: (x0,x1) => { x0.integrity = x1 },
      _4182: () => globalThis.window,
      _4221: x0 => x0.document,
      _4224: x0 => x0.location,
      _4243: x0 => x0.navigator,
      _4247: x0 => x0.screen,
      _4259: x0 => x0.devicePixelRatio,
      _4505: x0 => x0.trustedTypes,
      _4506: x0 => x0.sessionStorage,
      _4507: x0 => x0.localStorage,
      _4517: x0 => x0.origin,
      _4522: x0 => x0.hostname,
      _4526: x0 => x0.pathname,
      _4627: x0 => x0.platform,
      _4630: x0 => x0.userAgent,
      _4636: x0 => x0.onLine,
      _4838: x0 => x0.length,
      _6783: x0 => x0.signal,
      _6792: x0 => x0.length,
      _6832: x0 => x0.baseURI,
      _6838: x0 => x0.firstChild,
      _6849: () => globalThis.document,
      _6929: x0 => x0.body,
      _6931: x0 => x0.head,
      _7260: x0 => x0.id,
      _7261: (x0,x1) => { x0.id = x1 },
      _7491: x0 => x0.length,
      _8606: x0 => x0.value,
      _8608: x0 => x0.done,
      _9305: x0 => x0.url,
      _9307: x0 => x0.status,
      _9309: x0 => x0.statusText,
      _9310: x0 => x0.headers,
      _9311: x0 => x0.body,
      _9578: x0 => x0.type,
      _9593: x0 => x0.matches,
      _9604: x0 => x0.availWidth,
      _9605: x0 => x0.availHeight,
      _9610: x0 => x0.orientation,
      _11437: (x0,x1) => { x0.border = x1 },
      _11715: (x0,x1) => { x0.display = x1 },
      _11879: (x0,x1) => { x0.height = x1 },
      _12569: (x0,x1) => { x0.width = x1 },
      _12937: x0 => x0.name,
      _13652: () => globalThis.console,
      _13677: () => globalThis.window.flutterCanvasKit,
      _13678: () => globalThis.window._flutter_skwasmInstance,
      _13679: x0 => x0.name,
      _13680: x0 => x0.message,
      _13681: x0 => x0.code,
      _13683: x0 => x0.customData,

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
