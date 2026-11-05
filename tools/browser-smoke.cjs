const { chromium } = require("playwright");
const assert = require("node:assert/strict");
const fs = require("node:fs/promises");
(async () => {
  await fs.mkdir(".artifacts/screenshots", { recursive: true });
  const browser = await chromium.launch({
    ...(process.env.AURORA_BROWSER_CHANNEL
      ? { channel: process.env.AURORA_BROWSER_CHANNEL }
      : {}),
    headless: true,
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 900 },
    recordVideo: {
      dir: ".artifacts/video",
      size: { width: 1280, height: 900 },
    },
  });
  await context.addInitScript(() => {
    window.__csp = [];
    document.addEventListener("securitypolicyviolation", (e) =>
      window.__csp.push(e.effectiveDirective + ": " + e.blockedURI),
    );
  });
  const page = await context.newPage();
  const errors = [];
  const external = new Set();
  page.on("pageerror", (e) => errors.push(String(e)));
  page.on("console", (m) => {
    if (m.type() === "error") errors.push(m.text());
  });
  page.on("request", (r) => {
    if (
      /^https?:/.test(r.url()) &&
      !r.url().startsWith("http://127.0.0.1:8790")
    )
      external.add(r.url());
  });
  const pause = () => page.waitForTimeout(650);
  async function typeInto(locator, text) {
    await locator.click();
    await pause();
    await page.keyboard.press("ControlOrMeta+A");
    await page.waitForTimeout(100);
    await page.keyboard.type(text, { delay: 10 });
    await page.keyboard.press("Tab");
    await pause();
  }
  try {
    await page.goto("http://127.0.0.1:8790");
    await page.locator("flt-semantics-placeholder").waitFor();
    await page.locator("flt-semantics-placeholder").evaluate((e) => e.click());
    await page
      .getByRole("button", { name: "Open Journal Write and reflect" })
      .waitFor();
    await pause();
    await page
      .getByRole("button", { name: "Open Journal Write and reflect" })
      .click();
    await pause();
    await typeInto(
      page.getByRole("textbox", { name: "Grateful for today..." }),
      "A little progress",
    );
    await typeInto(
      page.getByRole("textbox", {
        name: "Write about your day, thoughts, feelings...",
      }),
      "I broke a big task into smaller steps and made time for a walk. This is a fictional demo entry.",
    );
    await page.getByRole("button", { name: "😊 happy", exact: true }).click();
    await pause();
    await page.screenshot({ path: ".artifacts/screenshots/journal.png" });
    await page.getByRole("button", { name: "Save entry", exact: true }).click();
    await page.waitForTimeout(3000);
    await page.getByRole("button", { name: "Timeline", exact: true }).click();
    await pause();
    assert.match(await page.locator("body").innerText(), /8 entries/);
    await page.screenshot({ path: ".artifacts/screenshots/timeline.png" });
    await page.getByRole("button", { name: "Change range" }).click();
    await pause();
    await page.getByText("Last 30 days", { exact: true }).click();
    await pause();
    assert.match(await page.locator("body").innerText(), /31 entries/);
    console.log("PASS journal creation updates 7- and 30-day charts");
    await page.getByRole("tab", { name: "Resources", exact: true }).click();
    await pause();
    await page.getByRole("button", { name: /ADHD Help/ }).click();
    await pause();
    await page.getByRole("button", { name: "Start", exact: true }).click();
    await page.waitForTimeout(1500);
    await page.screenshot({ path: ".artifacts/screenshots/focus.png" });
    await page.getByRole("button", { name: "Stop", exact: true }).click();
    await pause();
    console.log("PASS focus timer starts and stops");
    await page
      .getByRole("button", { name: /^Back$|^$/ })
      .first()
      .click();
    await pause();
    await page.getByRole("tab", { name: "Journal", exact: true }).click();
    await pause();
    await page.getByRole("button", { name: "Entries", exact: true }).click();
    await pause();
    await typeInto(
      page.getByRole("textbox", { name: "Search by title…" }),
      "A little progress",
    );
    await page.getByRole("button", { name: /^A little progress/ }).click();
    await pause();
    await typeInto(page.getByRole("textbox").first(), "Progress, edited");
    await page
      .getByRole("button", { name: "Save changes", exact: true })
      .click();
    await pause();
    await typeInto(page.getByRole("textbox").last(), "Progress, edited");
    assert.equal(
      await page.getByRole("button", { name: /^Progress, edited/ }).count(),
      1,
    );
    console.log("PASS edit and search");
    await page.getByRole("button", { name: "Reset demo", exact: true }).click();
    await pause();
    await page.getByRole("button", { name: "Reset", exact: true }).click();
    await pause();
    await page
      .getByRole("button", { name: "Open Journal Write and reflect" })
      .click();
    await pause();
    await page.getByRole("button", { name: "Timeline", exact: true }).click();
    await pause();
    assert.match(await page.locator("body").innerText(), /7 entries/);
    console.log("PASS reset restores seeded data and shell state");
    await page.setViewportSize({ width: 390, height: 844 });
    await pause();
    await page.screenshot({ path: ".artifacts/mobile.png" });
    await page.getByRole("tab", { name: "Chat", exact: true }).click();
    await pause();
    assert.match(
      await page.locator("body").innerText(),
      /Prerecorded examples/,
    );
    await page.getByRole("tab", { name: "Settings", exact: true }).click();
    await pause();
    assert.match(
      await page.locator("body").innerText(),
      /Accounts and notifications are unavailable/,
    );
    assert.deepEqual(await page.evaluate(() => window.__csp), []);
    assert.deepEqual([...external], []);
    assert.deepEqual(errors, []);
    console.log(
      "PASS mobile navigation, no external requests, CSP violations, or browser errors",
    );
  } catch (e) {
    console.log(
      "FAILURE_ARIA",
      (await page.locator("body").ariaSnapshot()).slice(0, 4500),
    );
    console.log("ERRORS", errors.slice(0, 5));
    throw e;
  } finally {
    const video = page.video();
    await context.close();
    console.log("VIDEO", await video.path());
    await browser.close();
  }
})().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
