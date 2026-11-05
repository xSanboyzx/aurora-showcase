const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve("aurora_app/build/web");
const types = {
  ".html": "text/html",
  ".js": "text/javascript",
  ".json": "application/json",
  ".wasm": "application/wasm",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".otf": "font/otf",
  ".ttf": "font/ttf",
  ".woff2": "font/woff2",
  ".svg": "image/svg+xml",
};
const headers = fs
  .readFileSync(path.join(root, "_headers"), "utf8")
  .split("\n")
  .filter((x) => x.startsWith("  "))
  .map((x) => {
    const i = x.indexOf(":");
    return [x.slice(2, i), x.slice(i + 1).trim()];
  });
http
  .createServer((req, res) => {
    const file = path.resolve(
      root,
      "." + decodeURIComponent(new URL(req.url, "http://localhost").pathname),
    );
    if (!file.startsWith(root + path.sep) && file !== root) {
      res.writeHead(403).end();
      return;
    }
    const target =
      fs.existsSync(file) && fs.statSync(file).isFile()
        ? file
        : path.join(root, "index.html");
    for (const [key, value] of headers) res.setHeader(key, value);
    res.setHeader(
      "Content-Type",
      types[path.extname(target)] || "application/octet-stream",
    );
    fs.createReadStream(target).pipe(res);
  })
  .listen(8790, "127.0.0.1", () =>
    console.log("Aurora preview http://127.0.0.1:8790"),
  );
