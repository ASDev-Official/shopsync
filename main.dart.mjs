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
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `load-ids` option is passed. Each load ID maps to one
  //   or more wasm files as specified in the emitted JSON file. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It also takes a callback that should be invoked with the
  //   loaded module in a format supported by `WebAssembly.compile` or
  //   `WebAssembly.compileStreaming` and the result of using the JS 'import'
  //   API on the js file path. It should return a Promise that resolves when
  //   all the modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports,
      {loadDeferredModules, loadDynamicModule, loadDeferredId} = {}) {
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
            _1: (decoder, codeUnits) => decoder.decode(codeUnits),
      _2: () => new TextDecoder("utf-8", {fatal: true}),
      _3: () => new TextDecoder("utf-8", {fatal: false}),
      _4: (s) => +s,
      _5: x0 => new Uint8Array(x0),
      _6: (x0,x1,x2) => x0.set(x1,x2),
      _7: (x0,x1) => x0.transferFromImageBitmap(x1),
      _9: (x0,x1,x2) => x0.slice(x1,x2),
      _10: (x0,x1) => x0.decode(x1),
      _11: (x0,x1) => x0.segment(x1),
      _12: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _135: (x0,x1) => x0.appendChild(x1),
      _166: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _167: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _168: (x0,x1) => new OffscreenCanvas(x0,x1),
      _169: x0 => x0.remove(),
      _170: (x0,x1) => x0.append(x1),
      _172: x0 => x0.unlock(),
      _173: x0 => x0.getReader(),
      _174: (x0,x1) => x0.item(x1),
      _175: x0 => x0.next(),
      _176: x0 => x0.now(),
      _177: (x0,x1) => x0.revokeObjectURL(x1),
      _178: x0 => x0.close(),
      _179: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _180: x0 => new window.ImageDecoder(x0),
      _181: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      _182: (x0,x1) => x0.decode(x1),
      _183: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._183(f,arguments.length,x0) }),
      _184: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _186: (x0,x1) => x0.getModifierState(x1),
      _187: x0 => x0.preventDefault(),
      _188: x0 => x0.stopPropagation(),
      _189: (x0,x1) => x0.removeProperty(x1),
      _190: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._190(f,arguments.length,x0) }),
      _191: x0 => new window.FinalizationRegistry(x0),
      _192: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _194: (x0,x1) => x0.unregister(x1),
      _195: (x0,x1) => x0.prepend(x1),
      _196: x0 => new Intl.Locale(x0),
      _197: (x0,x1) => x0.observe(x1),
      _198: x0 => x0.disconnect(),
      _199: (x0,x1) => x0.getAttribute(x1),
      _200: (x0,x1) => x0.contains(x1),
      _201: (x0,x1) => x0.querySelector(x1),
      _202: (x0,x1) => x0.matchMedia(x1),
      _203: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._203(f,arguments.length,x0) }),
      _204: (x0,x1,x2) => x0.call(x1,x2),
      _205: x0 => x0.blur(),
      _206: x0 => x0.hasFocus(),
      _207: (x0,x1) => x0.removeAttribute(x1),
      _208: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _209: (x0,x1) => x0.hasAttribute(x1),
      _210: (x0,x1) => x0.getModifierState(x1),
      _211: (x0,x1) => x0.createTextNode(x1),
      _212: x0 => x0.getBoundingClientRect(),
      _213: (x0,x1) => x0.replaceWith(x1),
      _214: (x0,x1) => x0.contains(x1),
      _215: (x0,x1) => x0.closest(x1),
      _653: x0 => new Uint8Array(x0),
      _656: () => globalThis.window.flutterConfiguration,
      _658: x0 => x0.assetBase,
      _663: x0 => x0.canvasKitMaximumSurfaces,
      _664: x0 => x0.debugShowSemanticsNodes,
      _665: x0 => x0.hostElement,
      _666: x0 => x0.multiViewEnabled,
      _667: x0 => x0.nonce,
      _669: x0 => x0.fontFallbackBaseUrl,
      _679: x0 => x0.console,
      _680: x0 => x0.devicePixelRatio,
      _681: x0 => x0.document,
      _682: x0 => x0.history,
      _683: x0 => x0.innerHeight,
      _684: x0 => x0.innerWidth,
      _685: x0 => x0.location,
      _686: x0 => x0.navigator,
      _687: x0 => x0.visualViewport,
      _688: x0 => x0.performance,
      _689: x0 => x0.parent,
      _691: x0 => x0.URL,
      _693: (x0,x1) => x0.getComputedStyle(x1),
      _694: x0 => x0.screen,
      _695: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._695(f,arguments.length,x0) }),
      _696: (x0,x1) => x0.requestAnimationFrame(x1),
      _700: (x0,x1) => x0.warn(x1),
      _702: (x0,x1) => x0.debug(x1),
      _703: x0 => globalThis.parseFloat(x0),
      _704: () => globalThis.window,
      _705: () => globalThis.Intl,
      _706: () => globalThis.Symbol,
      _707: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _709: x0 => x0.clipboard,
      _710: x0 => x0.maxTouchPoints,
      _711: x0 => x0.vendor,
      _712: x0 => x0.language,
      _713: x0 => x0.platform,
      _714: x0 => x0.userAgent,
      _715: (x0,x1) => x0.vibrate(x1),
      _716: x0 => x0.languages,
      _717: x0 => x0.documentElement,
      _718: (x0,x1) => x0.querySelector(x1),
      _719: (x0,x1) => x0.querySelectorAll(x1),
      _721: (x0,x1) => x0.createElement(x1),
      _724: (x0,x1) => x0.createEvent(x1),
      _725: x0 => x0.activeElement,
      _728: x0 => x0.head,
      _729: x0 => x0.body,
      _731: (x0,x1) => { x0.title = x1 },
      _734: x0 => x0.visibilityState,
      _735: () => globalThis.document,
      _736: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._736(f,arguments.length,x0) }),
      _737: (x0,x1) => x0.dispatchEvent(x1),
      _745: x0 => x0.target,
      _747: x0 => x0.timeStamp,
      _748: x0 => x0.type,
      _750: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _757: x0 => x0.firstChild,
      _761: x0 => x0.parentElement,
      _763: (x0,x1) => { x0.textContent = x1 },
      _764: x0 => x0.parentNode,
      _765: x0 => x0.nextSibling,
      _766: (x0,x1) => x0.removeChild(x1),
      _767: x0 => x0.isConnected,
      _775: x0 => x0.clientHeight,
      _776: x0 => x0.clientWidth,
      _777: x0 => x0.offsetHeight,
      _778: x0 => x0.offsetWidth,
      _779: x0 => x0.id,
      _780: (x0,x1) => { x0.id = x1 },
      _783: (x0,x1) => { x0.spellcheck = x1 },
      _784: x0 => x0.tagName,
      _785: x0 => x0.style,
      _787: (x0,x1) => x0.querySelectorAll(x1),
      _788: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _789: x0 => x0.tabIndex,
      _790: (x0,x1) => { x0.tabIndex = x1 },
      _791: (x0,x1) => x0.focus(x1),
      _792: x0 => x0.scrollTop,
      _793: (x0,x1) => { x0.scrollTop = x1 },
      _794: (x0,x1) => { x0.scrollLeft = x1 },
      _795: x0 => x0.scrollLeft,
      _796: x0 => x0.classList,
      _797: (x0,x1) => x0.scrollIntoView(x1),
      _800: (x0,x1) => { x0.className = x1 },
      _802: (x0,x1) => x0.getElementsByClassName(x1),
      _803: x0 => x0.click(),
      _804: (x0,x1) => x0.attachShadow(x1),
      _807: x0 => x0.computedStyleMap(),
      _808: (x0,x1) => x0.get(x1),
      _814: (x0,x1) => x0.getPropertyValue(x1),
      _815: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _816: x0 => x0.offsetLeft,
      _817: x0 => x0.offsetTop,
      _818: x0 => x0.offsetParent,
      _820: (x0,x1) => { x0.name = x1 },
      _821: x0 => x0.content,
      _822: (x0,x1) => { x0.content = x1 },
      _826: (x0,x1) => { x0.src = x1 },
      _827: x0 => x0.naturalWidth,
      _828: x0 => x0.naturalHeight,
      _832: (x0,x1) => { x0.crossOrigin = x1 },
      _834: (x0,x1) => { x0.decoding = x1 },
      _835: x0 => x0.decode(),
      _840: (x0,x1) => { x0.nonce = x1 },
      _845: (x0,x1) => { x0.width = x1 },
      _847: (x0,x1) => { x0.height = x1 },
      _850: (x0,x1) => x0.getContext(x1),
      _918: x0 => x0.width,
      _919: x0 => x0.height,
      _921: (x0,x1) => x0.fetch(x1),
      _922: x0 => x0.status,
      _924: x0 => x0.body,
      _925: x0 => x0.arrayBuffer(),
      _928: x0 => x0.read(),
      _929: x0 => x0.value,
      _930: x0 => x0.done,
      _937: x0 => x0.name,
      _938: x0 => x0.x,
      _939: x0 => x0.y,
      _942: x0 => x0.top,
      _943: x0 => x0.right,
      _944: x0 => x0.bottom,
      _945: x0 => x0.left,
      _955: x0 => x0.height,
      _956: x0 => x0.width,
      _957: x0 => x0.scale,
      _958: (x0,x1) => { x0.value = x1 },
      _961: (x0,x1) => { x0.placeholder = x1 },
      _963: (x0,x1) => { x0.name = x1 },
      _964: x0 => x0.selectionDirection,
      _965: x0 => x0.selectionStart,
      _966: x0 => x0.selectionEnd,
      _969: x0 => x0.value,
      _971: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _972: x0 => x0.readText(),
      _973: (x0,x1) => x0.writeText(x1),
      _975: x0 => x0.altKey,
      _976: x0 => x0.code,
      _977: x0 => x0.ctrlKey,
      _978: x0 => x0.key,
      _979: x0 => x0.keyCode,
      _980: x0 => x0.location,
      _981: x0 => x0.metaKey,
      _982: x0 => x0.repeat,
      _983: x0 => x0.shiftKey,
      _984: x0 => x0.isComposing,
      _986: x0 => x0.state,
      _987: (x0,x1) => x0.go(x1),
      _989: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _990: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _991: x0 => x0.pathname,
      _992: x0 => x0.search,
      _993: x0 => x0.hash,
      _997: x0 => x0.state,
      _1000: (x0,x1) => x0.createObjectURL(x1),
      _1002: x0 => new Blob(x0),
      _1012: x0 => x0.matches,
      _1016: x0 => x0.matches,
      _1020: x0 => x0.relatedTarget,
      _1022: x0 => x0.clientX,
      _1023: x0 => x0.clientY,
      _1024: x0 => x0.offsetX,
      _1025: x0 => x0.offsetY,
      _1028: x0 => x0.button,
      _1029: x0 => x0.buttons,
      _1030: x0 => x0.ctrlKey,
      _1034: x0 => x0.pointerId,
      _1035: x0 => x0.pointerType,
      _1036: x0 => x0.pressure,
      _1037: x0 => x0.tiltX,
      _1038: x0 => x0.tiltY,
      _1039: x0 => x0.getCoalescedEvents(),
      _1042: x0 => x0.deltaX,
      _1043: x0 => x0.deltaY,
      _1044: x0 => x0.wheelDeltaX,
      _1045: x0 => x0.wheelDeltaY,
      _1046: x0 => x0.deltaMode,
      _1053: x0 => x0.changedTouches,
      _1056: x0 => x0.clientX,
      _1057: x0 => x0.clientY,
      _1060: x0 => x0.data,
      _1063: (x0,x1) => { x0.disabled = x1 },
      _1065: (x0,x1) => { x0.type = x1 },
      _1066: (x0,x1) => { x0.max = x1 },
      _1067: (x0,x1) => { x0.min = x1 },
      _1068: x0 => x0.value,
      _1069: (x0,x1) => { x0.value = x1 },
      _1070: x0 => x0.disabled,
      _1071: (x0,x1) => { x0.disabled = x1 },
      _1073: (x0,x1) => { x0.placeholder = x1 },
      _1075: (x0,x1) => { x0.name = x1 },
      _1076: (x0,x1) => { x0.autocomplete = x1 },
      _1078: x0 => x0.selectionDirection,
      _1079: x0 => x0.selectionStart,
      _1081: x0 => x0.selectionEnd,
      _1084: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1085: (x0,x1) => x0.add(x1),
      _1087: (x0,x1) => { x0.noValidate = x1 },
      _1088: (x0,x1) => { x0.method = x1 },
      _1089: (x0,x1) => { x0.action = x1 },
      _1114: x0 => x0.orientation,
      _1115: x0 => x0.width,
      _1116: x0 => x0.height,
      _1117: (x0,x1) => x0.lock(x1),
      _1136: x0 => new ResizeObserver(x0),
      _1139: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1139(f,arguments.length,x0,x1) }),
      _1147: x0 => x0.length,
      _1148: x0 => x0.iterator,
      _1149: x0 => x0.Segmenter,
      _1150: x0 => x0.v8BreakIterator,
      _1151: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1154: x0 => x0.language,
      _1155: x0 => x0.script,
      _1156: x0 => x0.region,
      _1174: x0 => x0.done,
      _1175: x0 => x0.value,
      _1176: x0 => x0.index,
      _1180: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1181: (x0,x1) => x0.adoptText(x1),
      _1182: x0 => x0.first(),
      _1183: x0 => x0.next(),
      _1184: x0 => x0.current(),
      _1186: () => globalThis.window.FinalizationRegistry,
      _1197: x0 => x0.hostElement,
      _1198: x0 => x0.viewConstraints,
      _1201: x0 => x0.maxHeight,
      _1202: x0 => x0.maxWidth,
      _1203: x0 => x0.minHeight,
      _1204: x0 => x0.minWidth,
      _1205: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1205(f,arguments.length,x0) }),
      _1206: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1206(f,arguments.length,x0) }),
      _1207: (x0,x1) => ({addView: x0,removeView: x1}),
      _1210: x0 => x0.loader,
      _1211: () => globalThis._flutter,
      _1212: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1213: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1213(f,arguments.length,x0) }),
      _1214: (module,f) => finalizeWrapper(f, function() { return module.exports._1214(f,arguments.length) }),
      _1215: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1218: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1218(f,arguments.length,x0) }),
      _1219: x0 => ({runApp: x0}),
      _1221: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1221(f,arguments.length,x0,x1) }),
      _1222: x0 => new Promise(x0),
      _1223: x0 => x0.length,
      _1224: () => globalThis.window.ImageDecoder,
      _1225: x0 => x0.tracks,
      _1227: x0 => x0.completed,
      _1229: x0 => x0.image,
      _1235: x0 => x0.displayWidth,
      _1236: x0 => x0.displayHeight,
      _1237: x0 => x0.duration,
      _1240: x0 => x0.ready,
      _1241: x0 => x0.selectedTrack,
      _1242: x0 => x0.repetitionCount,
      _1243: x0 => x0.frameCount,
      _1290: (x0,x1) => x0.createElement(x1),
      _1296: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1297: (module,f) => finalizeWrapper(f, function(x0,x1,x2) { return module.exports._1297(f,arguments.length,x0,x1,x2) }),
      _1298: (x0,x1) => x0.append(x1),
      _1300: x0 => x0.remove(),
      _1301: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1302: (x0,x1) => x0.removeAttribute(x1),
      _1304: (x0,x1) => x0.getResponseHeader(x1),
      _1327: (x0,x1) => x0.item(x1),
      _1330: (x0,x1) => { x0.csp = x1 },
      _1331: x0 => x0.csp,
      _1332: (x0,x1) => x0.getCookieExpirationDate(x1),
      _1333: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1333(f,arguments.length,x0) }),
      _1334: x0 => ({createScriptURL: x0}),
      _1335: (x0,x1,x2) => x0.createPolicy(x1,x2),
      _1336: (x0,x1,x2) => x0.createScriptURL(x1,x2),
      _1337: x0 => x0.hasChildNodes(),
      _1338: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _1339: (x0,x1) => x0.querySelectorAll(x1),
      _1340: (x0,x1) => x0.item(x1),
      _1341: x0 => ({type: x0}),
      _1344: (x0,x1) => x0.createElement(x1),
      _1345: x0 => x0.click(),
      _1347: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1347(f,arguments.length,x0,x1) }),
      _1348: x0 => globalThis.Sentry.init(x0),
      _1349: () => new Sentry.getClient(),
      _1350: x0 => x0.getOptions(),
      _1354: () => globalThis.Sentry.globalHandlersIntegration(),
      _1355: () => globalThis.Sentry.dedupeIntegration(),
      _1356: () => globalThis.Sentry.close(),
      _1357: (x0,x1) => x0.sendEnvelope(x1),
      _1360: () => globalThis.globalThis,
      _1361: x0 => x0.sdk,
      _1362: (x0,x1) => { x0.sdk = x1 },
      _1363: (x0,x1) => { x0.name = x1 },
      _1365: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1366: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1367: (x0,x1) => x0.getAttribute(x1),
      _1371: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1393: x0 => x0.toArray(),
      _1394: x0 => x0.toUint8Array(),
      _1395: x0 => ({serverTimestamps: x0}),
      _1396: x0 => ({source: x0}),
      _1397: x0 => ({merge: x0}),
      _1399: x0 => new firebase_firestore.FieldPath(x0),
      _1400: (x0,x1) => new firebase_firestore.FieldPath(x0,x1),
      _1401: (x0,x1,x2) => new firebase_firestore.FieldPath(x0,x1,x2),
      _1402: (x0,x1,x2,x3) => new firebase_firestore.FieldPath(x0,x1,x2,x3),
      _1403: (x0,x1,x2,x3,x4) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4),
      _1404: (x0,x1,x2,x3,x4,x5) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5),
      _1405: (x0,x1,x2,x3,x4,x5,x6) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6),
      _1406: (x0,x1,x2,x3,x4,x5,x6,x7) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7),
      _1407: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      _1408: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9),
      _1409: () => globalThis.firebase_firestore.documentId(),
      _1410: (x0,x1) => new firebase_firestore.Timestamp(x0,x1),
      _1411: (x0,x1) => new firebase_firestore.GeoPoint(x0,x1),
      _1412: x0 => globalThis.firebase_firestore.vector(x0),
      _1413: x0 => globalThis.firebase_firestore.Bytes.fromUint8Array(x0),
      _1414: x0 => globalThis.firebase_firestore.writeBatch(x0),
      _1415: (x0,x1) => globalThis.firebase_firestore.collection(x0,x1),
      _1417: (x0,x1) => globalThis.firebase_firestore.doc(x0,x1),
      _1420: x0 => x0.call(),
      _1444: x0 => x0.commit(),
      _1445: (x0,x1) => x0.delete(x1),
      _1447: (x0,x1,x2) => x0.set(x1,x2),
      _1448: x0 => globalThis.firebase_firestore.deleteDoc(x0),
      _1449: x0 => globalThis.firebase_firestore.getDoc(x0),
      _1450: x0 => globalThis.firebase_firestore.getDocFromServer(x0),
      _1451: x0 => globalThis.firebase_firestore.getDocFromCache(x0),
      _1452: (x0,x1) => ({includeMetadataChanges: x0,source: x1}),
      _1453: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1453(f,arguments.length,x0) }),
      _1454: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1454(f,arguments.length,x0) }),
      _1455: (x0,x1,x2,x3) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2,x3),
      _1456: (x0,x1,x2) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2),
      _1457: (x0,x1,x2) => globalThis.firebase_firestore.setDoc(x0,x1,x2),
      _1458: (x0,x1) => globalThis.firebase_firestore.setDoc(x0,x1),
      _1459: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1460: x0 => globalThis.firebase_firestore.getDocs(x0),
      _1461: x0 => globalThis.firebase_firestore.getDocsFromServer(x0),
      _1462: x0 => globalThis.firebase_firestore.getDocsFromCache(x0),
      _1463: x0 => globalThis.firebase_firestore.limit(x0),
      _1464: x0 => globalThis.firebase_firestore.limitToLast(x0),
      _1465: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1465(f,arguments.length,x0) }),
      _1466: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1466(f,arguments.length,x0) }),
      _1467: (x0,x1) => globalThis.firebase_firestore.orderBy(x0,x1),
      _1469: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      _1471: x0 => globalThis.firebase_firestore.doc(x0),
      _1474: (x0,x1) => x0.data(x1),
      _1478: x0 => x0.docChanges(),
      _1485: () => globalThis.firebase_firestore.deleteField(),
      _1486: () => globalThis.firebase_firestore.serverTimestamp(),
      _1488: () => globalThis.firebase_firestore.count(),
      _1489: x0 => globalThis.firebase_firestore.sum(x0),
      _1490: x0 => globalThis.firebase_firestore.average(x0),
      _1491: (x0,x1) => globalThis.firebase_firestore.getAggregateFromServer(x0,x1),
      _1492: x0 => x0.data(),
      _1496: (x0,x1) => globalThis.firebase_firestore.getFirestore(x0,x1),
      _1498: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      _1499: (module,f) => finalizeWrapper(f, function() { return module.exports._1499(f,arguments.length) }),
      _1637: () => globalThis.firebase_firestore.updateDoc,
      _1638: () => globalThis.firebase_firestore.or,
      _1639: () => globalThis.firebase_firestore.and,
      _1653: x0 => x0.path,
      _1656: () => globalThis.firebase_firestore.GeoPoint,
      _1657: x0 => x0.latitude,
      _1658: x0 => x0.longitude,
      _1660: () => globalThis.firebase_firestore.VectorValue,
      _1661: () => globalThis.firebase_firestore.Bytes,
      _1664: x0 => x0.type,
      _1666: x0 => x0.doc,
      _1668: x0 => x0.oldIndex,
      _1670: x0 => x0.newIndex,
      _1672: () => globalThis.firebase_firestore.DocumentReference,
      _1676: x0 => x0.path,
      _1685: x0 => x0.metadata,
      _1686: x0 => x0.ref,
      _1691: x0 => x0.docs,
      _1693: x0 => x0.metadata,
      _1698: () => globalThis.firebase_firestore.Timestamp,
      _1699: x0 => x0.seconds,
      _1700: x0 => x0.nanoseconds,
      _1736: x0 => x0.hasPendingWrites,
      _1738: x0 => x0.fromCache,
      _1745: x0 => x0.source,
      _1750: () => globalThis.firebase_firestore.startAfter,
      _1751: () => globalThis.firebase_firestore.startAt,
      _1752: () => globalThis.firebase_firestore.endBefore,
      _1753: () => globalThis.firebase_firestore.endAt,
      _1754: () => globalThis.firebase_firestore.arrayRemove,
      _1755: () => globalThis.firebase_firestore.arrayUnion,
      _1796: (x0,x1) => x0.querySelector(x1),
      _1797: x0 => x0.decode(),
      _1798: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1799: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1800: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1800(f,arguments.length,x0) }),
      _1801: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1801(f,arguments.length,x0) }),
      _1802: x0 => x0.send(),
      _1803: () => new XMLHttpRequest(),
      _1808: (x0,x1) => globalThis.firebase_auth.linkWithPopup(x0,x1),
      _1814: x0 => x0.reload(),
      _1817: (x0,x1) => globalThis.firebase_auth.unlink(x0,x1),
      _1821: (x0,x1) => globalThis.firebase_auth.updateProfile(x0,x1),
      _1824: x0 => x0.toJSON(),
      _1825: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1825(f,arguments.length,x0) }),
      _1826: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1826(f,arguments.length,x0) }),
      _1827: (x0,x1,x2) => x0.onAuthStateChanged(x1,x2),
      _1828: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1828(f,arguments.length,x0) }),
      _1829: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1829(f,arguments.length,x0) }),
      _1830: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1830(f,arguments.length,x0) }),
      _1831: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1831(f,arguments.length,x0) }),
      _1832: (x0,x1,x2) => x0.onIdTokenChanged(x1,x2),
      _1836: (x0,x1,x2) => globalThis.firebase_auth.createUserWithEmailAndPassword(x0,x1,x2),
      _1842: (x0,x1,x2) => globalThis.firebase_auth.sendPasswordResetEmail(x0,x1,x2),
      _1846: (x0,x1,x2) => globalThis.firebase_auth.signInWithEmailAndPassword(x0,x1,x2),
      _1849: (x0,x1) => globalThis.firebase_auth.signInWithPopup(x0,x1),
      _1851: x0 => x0.signOut(),
      _1852: (x0,x1) => globalThis.firebase_auth.connectAuthEmulator(x0,x1),
      _1867: () => new firebase_auth.GoogleAuthProvider(),
      _1868: (x0,x1) => x0.addScope(x1),
      _1869: (x0,x1) => x0.setCustomParameters(x1),
      _1875: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromResult(x0),
      _1890: x0 => globalThis.firebase_auth.getAdditionalUserInfo(x0),
      _1891: (x0,x1,x2) => ({errorMap: x0,persistence: x1,popupRedirectResolver: x2}),
      _1892: (x0,x1) => globalThis.firebase_auth.initializeAuth(x0,x1),
      _1898: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromError(x0),
      _1901: (x0,x1) => ({displayName: x0,photoURL: x1}),
      _1913: () => globalThis.firebase_auth.debugErrorMap,
      _1916: () => globalThis.firebase_auth.browserSessionPersistence,
      _1918: () => globalThis.firebase_auth.browserLocalPersistence,
      _1920: () => globalThis.firebase_auth.indexedDBLocalPersistence,
      _1923: x0 => globalThis.firebase_auth.multiFactor(x0),
      _1924: (x0,x1) => globalThis.firebase_auth.getMultiFactorResolver(x0,x1),
      _1926: x0 => x0.currentUser,
      _1930: x0 => x0.tenantId,
      _1940: x0 => x0.displayName,
      _1941: x0 => x0.email,
      _1942: x0 => x0.phoneNumber,
      _1943: x0 => x0.photoURL,
      _1944: x0 => x0.providerId,
      _1945: x0 => x0.uid,
      _1946: x0 => x0.emailVerified,
      _1947: x0 => x0.isAnonymous,
      _1948: x0 => x0.providerData,
      _1949: x0 => x0.refreshToken,
      _1950: x0 => x0.tenantId,
      _1951: x0 => x0.metadata,
      _1953: x0 => x0.providerId,
      _1954: x0 => x0.signInMethod,
      _1955: x0 => x0.accessToken,
      _1956: x0 => x0.idToken,
      _1957: x0 => x0.secret,
      _1969: x0 => x0.creationTime,
      _1970: x0 => x0.lastSignInTime,
      _1975: x0 => x0.code,
      _1977: x0 => x0.message,
      _1989: x0 => x0.email,
      _1990: x0 => x0.phoneNumber,
      _1991: x0 => x0.tenantId,
      _2014: x0 => x0.user,
      _2017: x0 => x0.providerId,
      _2018: x0 => x0.profile,
      _2019: x0 => x0.username,
      _2020: x0 => x0.isNewUser,
      _2023: () => globalThis.firebase_auth.browserPopupRedirectResolver,
      _2028: x0 => x0.displayName,
      _2029: x0 => x0.enrollmentTime,
      _2030: x0 => x0.factorId,
      _2031: x0 => x0.uid,
      _2033: x0 => x0.hints,
      _2034: x0 => x0.session,
      _2036: x0 => x0.phoneNumber,
      _2046: x0 => ({displayName: x0}),
      _2047: x0 => ({photoURL: x0}),
      _2048: (x0,x1) => x0.getItem(x1),
      _2053: (x0,x1) => x0.appendChild(x1),
      _2055: (x0,x1) => x0.removeItem(x1),
      _2056: (x0,x1,x2) => x0.setItem(x1,x2),
      _2059: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => ({apiKey: x0,authDomain: x1,databaseURL: x2,projectId: x3,storageBucket: x4,messagingSenderId: x5,measurementId: x6,appId: x7,recaptchaSiteKey: x8}),
      _2060: (x0,x1) => globalThis.firebase_core.initializeApp(x0,x1),
      _2061: x0 => globalThis.firebase_core.getApp(x0),
      _2062: () => globalThis.firebase_core.getApp(),
      _2063: (x0,x1,x2) => globalThis.firebase_core.registerVersion(x0,x1,x2),
      _2065: () => globalThis.firebase_core.SDK_VERSION,
      _2071: x0 => x0.apiKey,
      _2073: x0 => x0.authDomain,
      _2075: x0 => x0.databaseURL,
      _2077: x0 => x0.projectId,
      _2079: x0 => x0.storageBucket,
      _2081: x0 => x0.messagingSenderId,
      _2083: x0 => x0.measurementId,
      _2085: x0 => x0.appId,
      _2087: x0 => x0.recaptchaSiteKey,
      _2089: x0 => x0.name,
      _2090: x0 => x0.options,
      _2091: (x0,x1) => x0.debug(x1),
      _2092: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2092(f,arguments.length,x0) }),
      _2093: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._2093(f,arguments.length,x0,x1) }),
      _2094: (x0,x1) => ({createScript: x0,createScriptURL: x1}),
      _2095: (x0,x1) => x0.createScriptURL(x1),
      _2096: (x0,x1,x2) => x0.createScript(x1,x2),
      _2097: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2097(f,arguments.length,x0) }),
      _2098: x0 => x0.reload(),
      _2099: (x0,x1) => x0.replace(x1),
      _2101: (x0,x1) => x0.initialize(x1),
      _2107: Date.now,
      _2108: secondsSinceEpoch => {
        const date = new Date(secondsSinceEpoch * 1000);
        const match = /\((.*)\)/.exec(date.toString());
        if (match == null) {
            // This should never happen on any recent browser.
            return '';
        }
        return match[1];
      },
      _2109: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _2110: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _2111: () => typeof dartUseDateNowForTicks !== "undefined",
      _2112: () => 1000 * performance.now(),
      _2113: () => Date.now(),
      _2114: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _2115: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _2116: () => new WeakMap(),
      _2117: (map, o) => map.get(o),
      _2118: (map, o, v) => map.set(o, v),
      _2119: x0 => new WeakRef(x0),
      _2120: x0 => x0.deref(),
      _2127: () => globalThis.WeakRef,
      _2130: s => JSON.stringify(s),
      _2131: s => printToConsole(s),
      _2132: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      _2133: (o, p, r) => o.replaceAll(p, () => r),
      _2134: (o, p, r) => o.replace(p, () => r),
      _2135: Function.prototype.call.bind(String.prototype.toLowerCase),
      _2136: s => s.toUpperCase(),
      _2137: s => s.trim(),
      _2138: s => s.trimLeft(),
      _2139: s => s.trimRight(),
      _2140: (string, times) => string.repeat(times),
      _2141: Function.prototype.call.bind(String.prototype.indexOf),
      _2142: (s, p, i) => s.lastIndexOf(p, i),
      _2143: (string, token) => string.split(token),
      _2144: Object.is,
      _2149: (o, c) => o instanceof c,
      _2150: o => Object.keys(o),
      _2153: (o,s,v) => o[s] = v,
      _2204: x0 => new Array(x0),
      _2206: x0 => x0.length,
      _2208: (x0,x1) => x0[x1],
      _2209: (x0,x1,x2) => { x0[x1] = x2 },
      _2212: (x0,x1,x2) => new DataView(x0,x1,x2),
      _2214: x0 => new Int8Array(x0),
      _2215: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _2217: x0 => new Uint8ClampedArray(x0),
      _2219: x0 => new Int16Array(x0),
      _2221: x0 => new Uint16Array(x0),
      _2223: x0 => new Int32Array(x0),
      _2225: x0 => new Uint32Array(x0),
      _2227: x0 => new Float32Array(x0),
      _2229: x0 => new Float64Array(x0),
      _2249: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._2249(f,arguments.length,x0,x1) }),
      _2252: () => Symbol("jsBoxedDartObjectProperty"),
      _2253: x0 => x0.random(),
      _2254: (x0,x1) => x0.getRandomValues(x1),
      _2255: () => globalThis.crypto,
      _2256: () => globalThis.Math,
      _2269: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _2270: (handle) => clearTimeout(handle),
      _2271: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _2272: (handle) => clearInterval(handle),
      _2273: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _2274: () => Date.now(),
      _2275: () => new Error().stack,
      _2276: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _2277: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2278: (x0,x1) => x0.exec(x1),
      _2279: (x0,x1) => x0.test(x1),
      _2280: x0 => x0.pop(),
      _2282: o => o === undefined,
      _2284: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2286: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2287: o => o instanceof RegExp,
      _2288: (l, r) => l === r,
      _2289: o => o,
      _2290: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      _2291: o => o,
      _2292: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      _2293: o => o,
      _2294: b => !!b,
      _2295: o => o.length,
      _2297: (o, i) => o[i],
      _2298: f => f.dartFunction,
      _2299: () => ({}),
      _2300: () => [],
      _2302: () => globalThis,
      _2303: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2304: (o, p) => p in o,
      _2305: (o, p) => o[p],
      _2306: (o, p, v) => o[p] = v,
      _2307: (o, m, a) => o[m].apply(o, a),
      _2309: o => String(o),
      _2310: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _2311: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2311(f,arguments.length,x0) }),
      _2312: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._2312(f,arguments.length,x0,x1) }),
      _2313: o => {
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
      _2314: o => [o],
      _2315: (o0, o1) => [o0, o1],
      _2316: (o0, o1, o2) => [o0, o1, o2],
      _2317: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _2318: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      _2319: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2320: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2321: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2322: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2323: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2324: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2325: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2326: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2327: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2328: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2329: x0 => new ArrayBuffer(x0),
      _2330: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2332: x0 => x0.index,
      _2333: x0 => x0.groups,
      _2334: x0 => x0.flags,
      _2335: x0 => x0.multiline,
      _2336: x0 => x0.ignoreCase,
      _2337: x0 => x0.unicode,
      _2338: x0 => x0.dotAll,
      _2339: (x0,x1) => { x0.lastIndex = x1 },
      _2340: (o, p) => p in o,
      _2341: (o, p) => o[p],
      _2342: (o, p, v) => o[p] = v,
      _2343: (o, p) => delete o[p],
      _2344: () => new XMLHttpRequest(),
      _2345: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _2347: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _2348: (x0,x1) => x0.send(x1),
      _2349: x0 => x0.send(),
      _2351: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2351(f,arguments.length,x0) }),
      _2352: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2352(f,arguments.length,x0) }),
      _2363: x0 => x0.deviceMemory,
      _2364: (x0,x1) => x0.matchMedia(x1),
      _2365: x0 => x0.trustedTypes,
      _2366: (x0,x1) => { x0.src = x1 },
      _2367: (x0,x1) => x0.createScriptURL(x1),
      _2368: x0 => x0.nonce,
      _2369: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2369(f,arguments.length,x0) }),
      _2370: () => new AbortController(),
      _2371: x0 => x0.abort(),
      _2372: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _2373: (x0,x1) => globalThis.fetch(x0,x1),
      _2374: (x0,x1) => x0.get(x1),
      _2375: (module,f) => finalizeWrapper(f, function(x0,x1,x2) { return module.exports._2375(f,arguments.length,x0,x1,x2) }),
      _2376: (x0,x1) => x0.forEach(x1),
      _2377: x0 => x0.getReader(),
      _2378: x0 => x0.cancel(),
      _2379: x0 => x0.read(),
      _2386: () => globalThis.window.flutter_inappwebview,
      _2390: (x0,x1) => { x0.nativeCommunication = x1 },
      _2391: (x0,x1) => x0.key(x1),
      _2392: x0 => x0.trustedTypes,
      _2393: (x0,x1) => { x0.text = x1 },
      _2394: o => o instanceof Array,
      _2398: a => a.pop(),
      _2399: (a, i) => a.splice(i, 1),
      _2400: (a, s) => a.join(s),
      _2401: (a, s, e) => a.slice(s, e),
      _2403: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _2404: a => a.length,
      _2406: (a, i) => a[i],
      _2407: (a, i, v) => a[i] = v,
      _2409: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      _2410: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _2412: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      _2413: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _2414: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      _2415: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _2416: o => o instanceof Uint8ClampedArray,
      _2417: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _2418: o => o instanceof Uint16Array,
      _2419: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _2420: o => o instanceof Int16Array,
      _2421: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _2422: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      _2423: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _2424: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      _2425: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _2427: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _2428: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      _2429: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _2430: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      _2431: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _2432: (a, i) => a.push(i),
      _2433: (t, s) => t.set(s),
      _2434: l => new DataView(new ArrayBuffer(l)),
      _2435: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _2437: o => o.buffer,
      _2438: o => o.byteOffset,
      _2439: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _2440: (b, o) => new DataView(b, o),
      _2441: (b, o, l) => new DataView(b, o, l),
      _2442: Function.prototype.call.bind(DataView.prototype.getUint8),
      _2443: Function.prototype.call.bind(DataView.prototype.setUint8),
      _2444: Function.prototype.call.bind(DataView.prototype.getInt8),
      _2445: Function.prototype.call.bind(DataView.prototype.setInt8),
      _2446: Function.prototype.call.bind(DataView.prototype.getUint16),
      _2447: Function.prototype.call.bind(DataView.prototype.setUint16),
      _2448: Function.prototype.call.bind(DataView.prototype.getInt16),
      _2449: Function.prototype.call.bind(DataView.prototype.setInt16),
      _2450: Function.prototype.call.bind(DataView.prototype.getUint32),
      _2451: Function.prototype.call.bind(DataView.prototype.setUint32),
      _2452: Function.prototype.call.bind(DataView.prototype.getInt32),
      _2453: Function.prototype.call.bind(DataView.prototype.setInt32),
      _2456: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _2457: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _2458: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _2459: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _2460: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _2461: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _2462: Function.prototype.call.bind(Number.prototype.toString),
      _2463: Function.prototype.call.bind(BigInt.prototype.toString),
      _2464: Function.prototype.call.bind(Number.prototype.toString),
      _2465: (d, digits) => d.toFixed(digits),
      _2513: () => globalThis.google.accounts.id,
      _2527: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2527(f,arguments.length,x0) }),
      _2530: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16) => ({client_id: x0,auto_select: x1,callback: x2,login_uri: x3,native_callback: x4,cancel_on_tap_outside: x5,prompt_parent_id: x6,nonce: x7,context: x8,state_cookie_domain: x9,ux_mode: x10,allowed_parent_origin: x11,intermediate_iframe_close_callback: x12,itp_support: x13,login_hint: x14,hd: x15,use_fedcm_for_prompt: x16}),
      _2541: x0 => x0.error,
      _2543: x0 => x0.credential,
      _2554: x0 => { globalThis.onGoogleLibraryLoad = x0 },
      _2555: (module,f) => finalizeWrapper(f, function() { return module.exports._2555(f,arguments.length) }),
      _2600: x0 => x0.status,
      _2605: x0 => x0.responseText,
      _2680: x0 => x0.style,
      _2879: (x0,x1) => { x0.nonce = x1 },
      _3156: x0 => x0.src,
      _3157: (x0,x1) => { x0.src = x1 },
      _3160: x0 => x0.name,
      _3161: (x0,x1) => { x0.name = x1 },
      _3162: x0 => x0.sandbox,
      _3163: x0 => x0.allow,
      _3164: (x0,x1) => { x0.allow = x1 },
      _3165: x0 => x0.allowFullscreen,
      _3166: (x0,x1) => { x0.allowFullscreen = x1 },
      _3171: x0 => x0.referrerPolicy,
      _3172: (x0,x1) => { x0.referrerPolicy = x1 },
      _3917: (x0,x1) => { x0.src = x1 },
      _3919: (x0,x1) => { x0.type = x1 },
      _3923: (x0,x1) => { x0.async = x1 },
      _3925: (x0,x1) => { x0.defer = x1 },
      _3927: (x0,x1) => { x0.crossOrigin = x1 },
      _3929: (x0,x1) => { x0.text = x1 },
      _3931: (x0,x1) => { x0.integrity = x1 },
      _4386: () => globalThis.window,
      _4425: x0 => x0.document,
      _4428: x0 => x0.location,
      _4447: x0 => x0.navigator,
      _4451: x0 => x0.screen,
      _4463: x0 => x0.devicePixelRatio,
      _4701: x0 => x0.origin,
      _4709: x0 => x0.trustedTypes,
      _4710: x0 => x0.sessionStorage,
      _4711: x0 => x0.localStorage,
      _4719: x0 => x0.origin,
      _4724: x0 => x0.hostname,
      _4728: x0 => x0.pathname,
      _4733: (x0,x1) => { x0.hash = x1 },
      _4829: x0 => x0.platform,
      _4832: x0 => x0.userAgent,
      _4838: x0 => x0.onLine,
      _5040: x0 => x0.length,
      _6985: x0 => x0.signal,
      _6994: x0 => x0.length,
      _7034: x0 => x0.baseURI,
      _7040: x0 => x0.firstChild,
      _7051: () => globalThis.document,
      _7131: x0 => x0.body,
      _7133: x0 => x0.head,
      _7462: x0 => x0.id,
      _7463: (x0,x1) => { x0.id = x1 },
      _7693: x0 => x0.length,
      _8808: x0 => x0.value,
      _8810: x0 => x0.done,
      _9507: x0 => x0.url,
      _9509: x0 => x0.status,
      _9511: x0 => x0.statusText,
      _9512: x0 => x0.headers,
      _9513: x0 => x0.body,
      _9780: x0 => x0.type,
      _9795: x0 => x0.matches,
      _9806: x0 => x0.availWidth,
      _9807: x0 => x0.availHeight,
      _9812: x0 => x0.orientation,
      _11639: (x0,x1) => { x0.border = x1 },
      _11917: (x0,x1) => { x0.display = x1 },
      _12081: (x0,x1) => { x0.height = x1 },
      _12771: (x0,x1) => { x0.width = x1 },
      _13139: x0 => x0.name,
      _13854: () => globalThis.console,
      _13877: () => globalThis.document,
      _13879: () => globalThis.console,
      _13884: (x0,x1) => { x0.height = x1 },
      _13886: (x0,x1) => { x0.width = x1 },
      _13888: (x0,x1) => { x0.pointerEvents = x1 },
      _13897: x0 => x0.style,
      _13900: x0 => x0.src,
      _13901: (x0,x1) => { x0.src = x1 },
      _13902: x0 => x0.naturalWidth,
      _13903: x0 => x0.naturalHeight,
      _13918: (x0,x1) => x0.error(x1),
      _13923: x0 => x0.status,
      _13924: (x0,x1) => { x0.responseType = x1 },
      _13926: x0 => x0.response,
      _13929: () => globalThis.window.flutterCanvasKit,
      _13930: () => globalThis.window._flutter_skwasmInstance,
      _13931: x0 => x0.name,
      _13932: x0 => x0.message,
      _13933: x0 => x0.code,
      _13935: x0 => x0.customData,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

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
    dartInstance.exports.$setThisModule(dartInstance);

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
