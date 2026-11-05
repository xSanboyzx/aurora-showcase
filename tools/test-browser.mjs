import { spawn } from "node:child_process";

const server = process.env.AURORA_SERVER_RUNNING
  ? null
  : spawn(process.execPath, ["tools/serve-demo.cjs"], { stdio: "inherit" });
try {
  for (let attempt = 0; attempt < 30; attempt++) {
    try {
      if ((await fetch("http://127.0.0.1:8790")).ok) break;
    } catch {
      /* server is starting */
    }
    if (attempt === 29) throw new Error("Preview server did not start.");
    await new Promise((resolve) => setTimeout(resolve, 200));
  }
  const test = spawn(process.execPath, ["tools/browser-smoke.cjs"], {
    stdio: "inherit",
  });
  process.exitCode = await new Promise((resolve) =>
    test.on("exit", (code) => resolve(code ?? 1)),
  );
} finally {
  server?.kill();
}
