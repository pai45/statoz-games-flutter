import { spawn } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

function parseArgs(argv) {
  const values = new Map();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith('--') || value === undefined) {
      throw new Error(`Expected --name value arguments, received: ${argv.join(' ')}`);
    }
    values.set(key.slice(2), value);
  }
  return values;
}

function required(args, name) {
  const value = args.get(name);
  if (!value) throw new Error(`Missing required --${name} argument`);
  return value;
}

function positiveNumber(args, name, fallback) {
  const raw = args.get(name) ?? String(fallback);
  const value = Number(raw);
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error(`--${name} must be a positive number, received ${raw}`);
  }
  return value;
}

function nonNegativeNumber(args, name, fallback = 0) {
  const raw = args.get(name) ?? String(fallback);
  const value = Number(raw);
  if (!Number.isFinite(value) || value < 0) {
    throw new Error(`--${name} must be a non-negative number, received ${raw}`);
  }
  return value;
}

function sameMetric(actual, expected) {
  return Number.isFinite(actual) && Math.abs(actual - expected) < 0.01;
}

const delay = (milliseconds) =>
  new Promise((resolve) => setTimeout(resolve, milliseconds));

async function waitForDevTools(profileDirectory, timeoutMilliseconds = 15000) {
  const activePortFile = path.join(profileDirectory, 'DevToolsActivePort');
  const deadline = Date.now() + timeoutMilliseconds;
  while (Date.now() < deadline) {
    try {
      const [port] = (await readFile(activePortFile, 'utf8')).trim().split(/\r?\n/);
      if (port) return Number(port);
    } catch (error) {
      if (!['ENOENT', 'EBUSY', 'EACCES'].includes(error.code)) throw error;
    }
    await delay(100);
  }
  throw new Error(`Chrome did not create ${activePortFile}`);
}

async function waitForPageEndpoint(port, timeoutMilliseconds = 15000) {
  const deadline = Date.now() + timeoutMilliseconds;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(`http://127.0.0.1:${port}/json/list`);
      if (response.ok) {
        const targets = await response.json();
        const page = targets.find((target) => target.type === 'page');
        if (page?.webSocketDebuggerUrl) return page.webSocketDebuggerUrl;
      }
    } catch {
      // Chrome may expose DevToolsActivePort just before the HTTP endpoint.
    }
    await delay(100);
  }
  throw new Error(`Chrome did not expose a page target on port ${port}`);
}

class DevToolsSession {
  constructor(webSocketUrl) {
    this.socket = new WebSocket(webSocketUrl);
    this.nextId = 1;
    this.pending = new Map();
    this.opened = new Promise((resolve, reject) => {
      this.socket.addEventListener('open', resolve, { once: true });
      this.socket.addEventListener('error', reject, { once: true });
    });
    this.socket.addEventListener('message', (event) => {
      const message = JSON.parse(event.data);
      if (!message.id) return;
      const pending = this.pending.get(message.id);
      if (!pending) return;
      this.pending.delete(message.id);
      if (message.error) {
        pending.reject(
          new Error(`${pending.method} failed: ${message.error.message}`),
        );
      } else {
        pending.resolve(message.result ?? {});
      }
    });
  }

  async send(method, params = {}) {
    await this.opened;
    const id = this.nextId++;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`${method} timed out`));
      }, 30000);
      this.pending.set(id, {
        method,
        resolve: (value) => {
          clearTimeout(timer);
          resolve(value);
        },
        reject: (error) => {
          clearTimeout(timer);
          reject(error);
        },
      });
      this.socket.send(JSON.stringify({ id, method, params }));
    });
  }

  close() {
    this.socket.close();
  }
}

async function waitForFlutter(session, timeoutMilliseconds = 30000) {
  const deadline = Date.now() + timeoutMilliseconds;
  while (Date.now() < deadline) {
    const evaluation = await session.send('Runtime.evaluate', {
      expression:
        "document.readyState === 'complete' && " +
        "Boolean(document.querySelector('flutter-view, flt-glass-pane'))",
      returnByValue: true,
    });
    if (evaluation.result?.value === true) {
      await session.send('Runtime.evaluate', {
        expression: 'document.fonts ? document.fonts.ready.then(() => true) : true',
        awaitPromise: true,
        returnByValue: true,
      });
      return;
    }
    await delay(100);
  }
  throw new Error('Flutter did not mount before the capture timeout');
}

function pngDimensions(buffer) {
  const signature = buffer.subarray(0, 8).toString('hex');
  if (signature !== '89504e470d0a1a0a' || buffer.length < 24) {
    throw new Error('Chrome returned an invalid PNG');
  }
  return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20) };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const chromePath = required(args, 'chrome');
  const url = required(args, 'url');
  const outputPath = path.resolve(required(args, 'output'));
  const profileDirectory = path.resolve(required(args, 'profile'));
  const width = positiveNumber(args, 'width', 393);
  const height = positiveNumber(args, 'height', 852);
  const devicePixelRatio = positiveNumber(args, 'dpr', 1);
  const waitMilliseconds = positiveNumber(args, 'wait-ms', 8000);
  const scrollY = nonNegativeNumber(args, 'scroll-y');

  await mkdir(profileDirectory, { recursive: true });
  await mkdir(path.dirname(outputPath), { recursive: true });

  const chrome = spawn(
    chromePath,
    [
      '--headless=new',
      '--disable-gpu',
      '--hide-scrollbars',
      '--no-first-run',
      '--no-default-browser-check',
      '--remote-debugging-port=0',
      '--window-size=800,900',
      `--user-data-dir=${profileDirectory}`,
      'about:blank',
    ],
    { stdio: 'ignore', windowsHide: true },
  );

  let session;
  try {
    const port = await waitForDevTools(profileDirectory);
    session = new DevToolsSession(await waitForPageEndpoint(port));
    await session.send('Page.enable');
    await session.send('Runtime.enable');
    await session.send('Emulation.setDeviceMetricsOverride', {
      width,
      height,
      deviceScaleFactor: devicePixelRatio,
      mobile: false,
      screenWidth: width,
      screenHeight: height,
      positionX: 0,
      positionY: 0,
      screenOrientation: { type: 'portraitPrimary', angle: 0 },
    });
    await session.send('Page.navigate', { url });
    await waitForFlutter(session);
    await delay(waitMilliseconds);

    // Flutter renders nested ListViews on its canvas, so browser full-page
    // screenshots cannot reveal off-screen list content. Drive the same wheel
    // interaction a desktop player would use, in bounded chunks, for explicit
    // scroll-continuation catalog frames.
    for (let remaining = scrollY; remaining > 0; remaining -= 720) {
      await session.send('Input.dispatchMouseEvent', {
        type: 'mouseWheel',
        x: width / 2,
        y: height * 0.62,
        deltaX: 0,
        deltaY: Math.min(720, remaining),
        pointerType: 'mouse',
      });
      await delay(150);
    }

    const runtimeMetrics = await session.send('Runtime.evaluate', {
      expression: `JSON.stringify({
        innerWidth: window.innerWidth,
        innerHeight: window.innerHeight,
        devicePixelRatio: window.devicePixelRatio,
        clientWidth: document.documentElement.clientWidth,
        clientHeight: document.documentElement.clientHeight,
        visualWidth: window.visualViewport?.width,
        visualHeight: window.visualViewport?.height
      })`,
      returnByValue: true,
    });
    const browserMetrics = JSON.parse(runtimeMetrics.result.value);
    const layoutMetrics = await session.send('Page.getLayoutMetrics');
    const layoutViewport = layoutMetrics.cssLayoutViewport;
    const expected = { width, height, devicePixelRatio };
    const actual = {
      width: browserMetrics.innerWidth,
      height: browserMetrics.innerHeight,
      devicePixelRatio: browserMetrics.devicePixelRatio,
    };
    if (
      !sameMetric(actual.width, expected.width) ||
      !sameMetric(actual.height, expected.height) ||
      !sameMetric(actual.devicePixelRatio, expected.devicePixelRatio) ||
      !sameMetric(browserMetrics.clientWidth, expected.width) ||
      !sameMetric(browserMetrics.clientHeight, expected.height) ||
      !sameMetric(browserMetrics.visualWidth, expected.width) ||
      !sameMetric(browserMetrics.visualHeight, expected.height) ||
      !sameMetric(layoutViewport.clientWidth, expected.width) ||
      !sameMetric(layoutViewport.clientHeight, expected.height)
    ) {
      throw new Error(
        `Viewport mismatch: expected ${JSON.stringify(expected)}, ` +
          `runtime ${JSON.stringify(browserMetrics)}, ` +
          `layout ${JSON.stringify(layoutViewport)}`,
      );
    }

    const capture = await session.send('Page.captureScreenshot', {
      format: 'png',
      fromSurface: true,
      captureBeyondViewport: false,
      clip: { x: 0, y: 0, width, height, scale: 1 },
    });
    const png = Buffer.from(capture.data, 'base64');
    const dimensions = pngDimensions(png);
    if (dimensions.width !== width || dimensions.height !== height) {
      throw new Error(
        `Screenshot mismatch: expected ${width}x${height}, ` +
          `received ${dimensions.width}x${dimensions.height}`,
      );
    }
    await writeFile(outputPath, png);
    console.log(
      JSON.stringify({
        output: outputPath,
        viewport: expected,
        layoutViewport: {
          width: layoutViewport.clientWidth,
          height: layoutViewport.clientHeight,
        },
        screenshot: dimensions,
        scrollY,
      }),
    );
  } finally {
    session?.close();
    chrome.kill();
  }
}

main().catch((error) => {
  console.error(error.stack ?? error.message ?? String(error));
  process.exitCode = 1;
});
