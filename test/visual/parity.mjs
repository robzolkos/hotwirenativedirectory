import { chromium } from "playwright";
import { execFileSync } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [baselineUrl, candidateUrl, outDir = "tmp/visual-parity"] = process.argv.slice(2);

if (!baselineUrl || !candidateUrl) {
  console.error("Usage: node parity.mjs <baseline-url> <candidate-url> [out-dir]");
  process.exit(2);
}

const VIEWPORTS = [
  { width: 375, height: 812 },
  { width: 639, height: 900 },
  { width: 640, height: 900 },
  { width: 1023, height: 900 },
  { width: 1024, height: 900 },
  { width: 1440, height: 900 },
];

const FIRST_CARD = "main > ul > li:first-child";

const STATES = [
  { name: "rest", hover: null },
  { name: "hover-card", hover: `${FIRST_CARD} > img` },
  { name: "hover-card-title", hover: `${FIRST_CARD} > div > a` },
  { name: "hover-download", hover: `${FIRST_CARD} > ul > li:first-child > a` },
  { name: "hover-add-app", hover: "nav > a" },
];

function pngSize(buffer) {
  return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20) };
}

function differingPixels(baselinePath, candidatePath, diffPath) {
  try {
    execFileSync("magick", ["compare", "-metric", "AE", baselinePath, candidatePath, diffPath], { stdio: "pipe" });
    return 0;
  } catch (error) {
    return Number.parseFloat(error.stderr.toString());
  }
}

async function capture(page, url, state) {
  await page.goto(url, { waitUntil: "networkidle" });
  await page.evaluate(() => Promise.all([...document.images].map((img) => img.decode().catch(() => {}))));
  await page.mouse.move(0, 0);
  if (state.hover) await page.hover(state.hover);
  await page.waitForTimeout(700);

  const screenshot = await page.screenshot({ fullPage: true, animations: "disabled" });
  const styles = await page.evaluate(() => {
    const skipped = new Set(["SCRIPT", "NOSCRIPT", "TEMPLATE"]);
    return [...document.body.querySelectorAll("*")]
      .filter((el) => !skipped.has(el.tagName))
      .map((el) => {
        const computed = getComputedStyle(el);
        const style = {};
        for (const property of computed) {
          if (!property.startsWith("--")) style[property] = computed.getPropertyValue(property);
        }
        return { tag: el.tagName, style };
      });
  });
  return { screenshot, styles };
}

function styleMismatches(baseline, candidate) {
  if (baseline.length !== candidate.length) {
    return [{ index: "-", tag: "-", property: "element count", baseline: baseline.length, candidate: candidate.length }];
  }
  return baseline.flatMap((element, index) => {
    const other = candidate[index];
    if (element.tag !== other.tag) {
      return [{ index, tag: element.tag, property: "tag", baseline: element.tag, candidate: other.tag }];
    }
    return [...new Set([...Object.keys(element.style), ...Object.keys(other.style)])]
      .filter((property) => element.style[property] !== other.style[property])
      .map((property) => ({ index, tag: element.tag, property, baseline: element.style[property], candidate: other.style[property] }));
  });
}

function formatMismatch({ index, tag, property, baseline, candidate }) {
  return `#${index} <${tag}> ${property}: ${baseline} vs ${candidate}`;
}

mkdirSync(outDir, { recursive: true });
const browser = await chromium.launch();
const results = [];

for (const viewport of VIEWPORTS) {
  const context = await browser.newContext({ viewport, deviceScaleFactor: 1 });
  const page = await context.newPage();

  for (const state of STATES) {
    const name = `${viewport.width}-${state.name}`;
    const baseline = await capture(page, baselineUrl, state);
    const candidate = await capture(page, candidateUrl, state);

    const baselinePath = join(outDir, `${name}.baseline.png`);
    const candidatePath = join(outDir, `${name}.candidate.png`);
    writeFileSync(baselinePath, baseline.screenshot);
    writeFileSync(candidatePath, candidate.screenshot);

    const baselineSize = pngSize(baseline.screenshot);
    const candidateSize = pngSize(candidate.screenshot);
    const sameSize = baselineSize.width === candidateSize.width && baselineSize.height === candidateSize.height;

    let pixels;
    if (baseline.screenshot.equals(candidate.screenshot)) pixels = 0;
    else if (!sameSize) pixels = Number.POSITIVE_INFINITY;
    else pixels = differingPixels(baselinePath, candidatePath, join(outDir, `${name}.diff.png`));

    const mismatches = styleMismatches(baseline.styles, candidate.styles);
    if (mismatches.length) writeFileSync(join(outDir, `${name}.styles.txt`), mismatches.map(formatMismatch).join("\n"));

    const size = sameSize
      ? `${baselineSize.width}x${baselineSize.height}`
      : `${baselineSize.width}x${baselineSize.height} vs ${candidateSize.width}x${candidateSize.height}`;
    results.push({ name, size, pixels, styleMismatches: mismatches.length, mismatchedProperties: mismatches.map((m) => m.property) });
  }

  await context.close();
}

await browser.close();
console.table(results.map(({ mismatchedProperties, ...row }) => row));

const mismatchedProperties = new Set(
  results.flatMap((result) => result.mismatchedProperties)
);
if (mismatchedProperties.size) {
  console.log(`Computed-style differences to review (render-equivalent unless pixels differ): ${[...mismatchedProperties].sort().join(", ")}`);
}

const failed = results.filter((result) => result.pixels !== 0);
console.log(failed.length ? `FAIL: ${failed.length} of ${results.length} shots differ` : `PASS: ${results.length} shots identical`);
process.exit(failed.length ? 1 : 0);
