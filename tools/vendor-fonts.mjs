import { readFile, mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

const sdk = process.argv[2];
if (!sdk)
  throw new Error("Usage: node tools/vendor-fonts.mjs PATH_TO_FLUTTER_SDK");
const engine = path.join(sdk, "bin/cache/flutter_web_sdk/lib/_engine/engine");
const data = await readFile(
  path.join(engine, "font_fallback_data.dart"),
  "utf8",
);
const paths = [
  ...data.matchAll(
    /'(notocoloremoji\/[^']+|notosanssymbols\/[^']+|notosanssymbols2\/[^']+)'/g,
  ),
].map((match) => match[1]);
paths.push("roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2");
for (const fontPath of [...new Set(paths)]) {
  const response = await fetch("https://fonts.gstatic.com/s/" + fontPath);
  if (!response.ok)
    throw new Error(`Font download failed: ${fontPath} (${response.status})`);
  const target = new URL(
    "../aurora_app/web/fonts/" + fontPath,
    import.meta.url,
  );
  await mkdir(new URL(".", target), { recursive: true });
  await writeFile(target, Buffer.from(await response.arrayBuffer()));
}
for (const family of [
  "roboto",
  "notocoloremoji",
  "notosanssymbols",
  "notosanssymbols2",
]) {
  const response = await fetch(
    `https://raw.githubusercontent.com/google/fonts/main/ofl/${family}/OFL.txt`,
  );
  if (!response.ok) throw new Error(`Font license download failed: ${family}`);
  await writeFile(
    new URL(`../aurora_app/web/fonts/${family}-OFL.txt`, import.meta.url),
    await response.text(),
  );
}
console.log(
  `Vendored ${new Set(paths).size} local font files and their licenses.`,
);
