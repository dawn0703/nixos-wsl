import { exec } from "herdr";

const PLAIN_SHELL = "sh";
const WIN_ABS = /^([A-Za-z]):[\\/](.*)$/;
const GIT_CORE = /\/[^/]+\/libexec\/git-core$/;

let shell = PLAIN_SHELL;
let mode = "direct";

const run = (bin, args, opts) => (opts ? exec(bin, args, opts) : exec(bin, args));

const spawnMissing = (error) => {
  const msg = String(error?.message ?? error);
  return msg.includes("cannot run") || msg.includes("can not run") || msg.includes("program not found");
};

function toWslArg(arg) {
  if (typeof arg !== "string") return arg;
  const m = arg.match(WIN_ABS);
  return m ? `/mnt/${m[1].toLowerCase()}/${m[2].replace(/\\/g, "/")}` : arg;
}

const runWsl = (args, opts) =>
  run("wsl.exe", ["--", "bash", "-lc", 'exec sh "$@"', "_", ...args.map(toWslArg)], opts);

async function gitBundledShell() {
  const core = (await exec("git", ["--exec-path"]).catch(() => null))?.stdout.trim() ?? "";
  const root = core.replace(GIT_CORE, "");
  return root && root !== core ? `${root}/bin/sh.exe` : null;
}

export async function runSh(args, opts) {
  if (mode === "wsl") return runWsl(args, opts);

  try {
    return await run(shell, args, opts);
  } catch (error) {
    if (shell !== PLAIN_SHELL || !spawnMissing(error)) throw error;

    try {
      const wslRes = await runWsl(args, opts);
      mode = "wsl";
      return wslRes;
    } catch (wslErr) {
      if (!spawnMissing(wslErr)) throw wslErr;
    }

    const found = await gitBundledShell();
    const result = found && await run(found, args, opts).catch(() => null);
    if (!result) throw error;
    shell = found;
    return result;
  }
}
