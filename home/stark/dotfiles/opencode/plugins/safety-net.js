// ~/.config/opencode/plugins/safety-net.js
// Blocks catastrophic commands and .env reads before they execute.
// Loaded automatically from the global plugin directory.
export const SafetyNet = async ({ client }) => {
  const log = (level, message) => {
    try {
      client.app.log({ body: { service: "safety-net", level, message } })
    } catch {
      /* logging is best-effort */
    }
  }

  return {
    "tool.execute.before": async (input) => {
      // ── Guard 1: never read secrets ──────────────────────────────
      if (input.tool === "read" && input.args?.filePath?.match(/\.env(\.|$)/)) {
        log("warn", `Blocked read of ${input.args.filePath}`)
        throw new Error(
          `[safety-net] Refusing to read ${input.args.filePath}: it may contain secrets. Use env vars or gitignored local config instead.`
        )
      }

      // ── Guard 2: block catastrophic bash commands ────────────────
      if (input.tool === "bash") {
        const cmd = String(input.args?.command ?? "")
        const catastrophes = [
          // rm -rf on anything that looks like a root or home path
          /\brm\s+-r?f\s+(['"])?\/(['"])?\b/,
          /\brm\s+-r?f\s+(['"])?~(\/|['"])/,
          /\brm\s+-r?f\s+\$HOME\b/,
          /\brm\s+-r?f\s+\*\s*$/,
          // disk-level destruction
          /\bmkfs\.\w+/,
          /\bdd\s+if=.+of=\/dev\//,
          /\bshred\b/,
          // system state nukes
          /\bgit\s+clean\s+-[a-z]*[fdx]/,
          /\bgit\s+reset\s+--hard\s+HEAD~?[0-9]*\b.*(--force)?/,
          /\bsudo\s+rm\s+-r?\s*\/\b/,
          /\bchmod\s+-R\s+000\b/,
        ]
        for (const re of catastrophes) {
          if (re.test(cmd)) {
            log("warn", `Blocked destructive command: ${cmd.slice(0, 120)}`)
            throw new Error(
              `[safety-net] Blocked potentially destructive command: "${cmd.trim()}"\nIf this is intentional, run it manually in a terminal.`
            )
          }
        }
      }
    },
  }
}
