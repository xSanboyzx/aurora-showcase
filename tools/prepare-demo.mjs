import { writeFile } from "node:fs/promises";

// This standalone policy applies only to the Flutter demo, not the portfolio.
const policy =
  "default-src 'none'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self'; worker-src 'self' blob:; object-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'none'";
await writeFile(
  new URL("../aurora_app/build/web/_headers", import.meta.url),
  `/*
  Content-Security-Policy: ${policy}
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  Cache-Control: no-cache
`,
);
