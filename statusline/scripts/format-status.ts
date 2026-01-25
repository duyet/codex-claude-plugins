/**
 * Compact one-line status formatter for Claude Code sessions
 * Hides empty values, shows only relevant metrics
 * Includes rate limit tracking (5h/7d for Anthropic, dual quotas for z.ai)
 */

import { dirname, join } from "path";
import { fileURLToPath } from "url";
import { readFileSync, existsSync } from "fs";
import { execFileSync } from "child_process";

// ===========================================================================
// TYPE DEFINITIONS
// ===========================================================================

interface ZaiDetails {
  tokens_pct: number;
  token_reset: string;
  monthly_pct: number;
  monthly_remaining: number;
  monthly_reset: string;
  search: number;
  web: number;
  zread: number;
}

interface RateLimits {
  provider?: string;  // "anthropic" or "zai"
  five_hour: number;
  seven_day: number;
  resets_at?: string;
  error?: string;
  zai?: ZaiDetails;  // Extended data for z.ai provider
}

interface SessionMetrics {
  context?: {
    used: number;
    total: number;
    percentage: number;
  };
  model?: string;
  tools?: Record<string, number>;
  agents?: Record<string, { elapsed: number; description: string }>;
  tasks?: {
    pending: number;
    inProgress: number;
    completed: number;
    total: number;
  };
  duration?: string;
  systemPrompts?: string[];
  rateLimits?: RateLimits;
}

interface FormattedStatus {
  line: string;
  parts: string[];
}

// ===========================================================================
// RATE LIMIT FETCHING
// ===========================================================================

/**
 * Detect model provider from environment variables
 */
function detectProvider(): "zai" | "anthropic" {
  const model = process.env.CLAUDE_MODEL ?? process.env.ANTHROPIC_MODEL ?? "";
  return model.startsWith("glm-") ? "zai" : "anthropic";
}

/**
 * Read z.ai API key from multiple sources
 */
function getZaiApiKey(): string | null {
  // 1. Try environment variables
  const envKey = process.env.ZAI_API_KEY ?? process.env.ZAI_CODING_PLAN_KEY;
  if (envKey) return envKey;

  // 2. Try macOS Keychain
  if (process.platform === "darwin") {
    try {
      const keychainNames = ["z.ai", "zai", "opencode", "zai-coding-plan"];
      for (const name of keychainNames) {
        const result = execFileSync("security", [
          "find-generic-password", "-s", name, "-w"
        ], { encoding: "utf-8", stdio: ["ignore", "pipe", "ignore"] });
        if (result) {
          try {
            const parsed = JSON.parse(result);
            if (parsed.key || parsed.apiKey || parsed.token) {
              return parsed.key || parsed.apiKey || parsed.token;
            }
          } catch {
            return result.trim(); // Raw value
          }
        }
      }
    } catch {
      // Keychain access failed, continue to other methods
    }
  }

  // 3. Try configuration files
  const homeDir = process.env.HOME ?? process.env.USERPROFILE ?? "";
  const authPaths = [
    join(homeDir, ".local", "share", "opencode", "auth.json"),
    join(homeDir, ".config", "opencode", "auth.json"),
    join(homeDir, ".opencode", "auth.json"),
    join(homeDir, ".zai", "auth.json"),
  ];

  for (const authPath of authPaths) {
    if (existsSync(authPath)) {
      try {
        const content = readFileSync(authPath, "utf-8");
        const auth = JSON.parse(content);
        // Try multiple possible key paths
        return auth["zai-coding-plan"]?.key
          ?? auth.zai?.key
          ?? auth.apiKey
          ?? auth.key
          ?? null;
      } catch {
        // File read or parse failed, continue
      }
    }
  }

  return null;
}

/**
 * Fetch Anthropic OAuth token from keychain or credentials files
 */
function getAnthropicToken(): string | null {
  // 1. Try macOS Keychain (primary on macOS)
  if (process.platform === "darwin") {
    try {
      const result = execFileSync("security", [
        "find-generic-password", "-s", "Claude Code-credentials", "-w"
      ], { encoding: "utf-8", stdio: ["ignore", "pipe", "ignore"] });
      if (result) {
        try {
          const parsed = JSON.parse(result);
          const token = parsed.claudeAiOauth?.accessToken;
          if (token) return token;
        } catch {
          // Not JSON or doesn't have expected structure
        }
      }
    } catch {
      // Keychain access failed
    }
  }

  // 2. Try file-based credentials
  const homeDir = process.env.HOME ?? "";
  const credPaths = [
    join(homeDir, ".claude", ".credentials.json"),
    join(homeDir, ".config", "claude", ".credentials.json"),
    join(homeDir, ".config", "claude-code", ".credentials.json"),
  ];

  for (const credPath of credPaths) {
    if (existsSync(credPath)) {
      try {
        const content = readFileSync(credPath, "utf-8");
        const creds = JSON.parse(content);
        const token = creds.claudeAiOauth?.accessToken;
        if (token) return token;
      } catch {
        // File read or parse failed
      }
    }
  }

  return null;
}

/**
 * Calculate human-readable time until reset
 */
function formatTimeUntil(resetTimestampMs: number): string {
  const now = Math.floor(Date.now() / 1000);
  const reset = Math.floor(resetTimestampMs / 1000);
  const diff = Math.max(0, reset - now);

  const hours = Math.floor(diff / 3600);
  const minutes = Math.floor((diff % 3600) / 60);
  const days = Math.floor(diff / 86400);

  if (days > 0) return `${days}d`;
  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}

/**
 * Fetch z.ai usage statistics
 */
async function fetchZaiUsage(): Promise<RateLimits> {
  const apiKey = getZaiApiKey();
  if (!apiKey) {
    return { provider: "zai", five_hour: 0, seven_day: 0, error: "no_credentials" };
  }

  try {
    const response = await fetch("https://api.z.ai/api/monitor/usage/quota/limit", {
      method: "GET",
      headers: {
        "Authorization": apiKey,
        "Content-Type": "application/json",
      },
      signal: AbortSignal.timeout(5000),
    });

    if (!response.ok) {
      return { provider: "zai", five_hour: 0, seven_day: 0, error: "api_error" };
    }

    const data = await response.json();

    if (!data.success) {
      return { provider: "zai", five_hour: 0, seven_day: 0, error: "api_error" };
    }

    // Parse TOKENS_LIMIT (5-hour rolling window)
    const tokenLimit = data.data.limits.find((l: any) => l.type === "TOKENS_LIMIT");
    const tokens_pct = tokenLimit?.percentage ?? 0;
    const token_reset = tokenLimit?.nextResetTime
      ? formatTimeUntil(tokenLimit.nextResetTime)
      : "";

    // Parse TIME_LIMIT (monthly tool quota)
    const timeLimit = data.data.limits.find((l: any) => l.type === "TIME_LIMIT");
    const monthly_pct = timeLimit?.percentage ?? 0;
    const monthly_remaining = timeLimit?.remaining ?? 0;
    const monthly_reset = timeLimit?.nextResetTime
      ? formatTimeUntil(timeLimit.nextResetTime)
      : "";

    // Extract tool usage details
    const search = timeLimit?.usageDetails?.find((d: any) => d.modelCode === "search-prime")?.usage ?? 0;
    const web = timeLimit?.usageDetails?.find((d: any) => d.modelCode === "web-reader")?.usage ?? 0;
    const zread = timeLimit?.usageDetails?.find((d: any) => d.modelCode === "zread")?.usage ?? 0;

    return {
      provider: "zai",
      five_hour: tokens_pct,
      seven_day: 0,
      zai: {
        tokens_pct,
        token_reset,
        monthly_pct,
        monthly_remaining,
        monthly_reset,
        search,
        web,
        zread,
      },
    };
  } catch {
    return { provider: "zai", five_hour: 0, seven_day: 0, error: "api_timeout" };
  }
}

/**
 * Fetch Anthropic usage statistics
 */
async function fetchAnthropicUsage(): Promise<RateLimits> {
  const token = getAnthropicToken();
  if (!token) {
    return { provider: "anthropic", five_hour: 0, seven_day: 0, error: "no_credentials" };
  }

  try {
    const response = await fetch("https://api.anthropic.com/api/oauth/usage", {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${token}`,
        "anthropic-beta": "oauth-2025-04-20",
      },
      signal: AbortSignal.timeout(5000),
    });

    if (!response.ok) {
      return { provider: "anthropic", five_hour: 0, seven_day: 0, error: "api_error" };
    }

    const data = await response.json();

    if (data.error) {
      if (data.error.message?.toLowerCase().includes("scope")) {
        return { provider: "anthropic", five_hour: 0, seven_day: 0, error: "scope_required" };
      }
      return { provider: "anthropic", five_hour: 0, seven_day: 0, error: "api_error" };
    }

    const five_hour = data.five_hour?.utilization ?? 0;
    const seven_day = data.seven_day?.utilization ?? 0;
    const resets_at = data.five_hour?.resets_at ?? "";

    return {
      provider: "anthropic",
      five_hour,
      seven_day,
      resets_at,
    };
  } catch {
    return { provider: "anthropic", five_hour: 0, seven_day: 0, error: "api_timeout" };
  }
}

/**
 * Fetch rate limits from appropriate API based on model provider
 */
export async function fetchRateLimits(): Promise<RateLimits | null> {
  try {
    const provider = detectProvider();
    return provider === "zai" ? await fetchZaiUsage() : await fetchAnthropicUsage();
  } catch {
    return null;
  }
}

// ===========================================================================
// FORMATTING FUNCTIONS
// ===========================================================================

function formatContext(metrics: SessionMetrics): string | null {
  if (!metrics.context) return null;
  const { percentage } = metrics.context;

  let color = "🟢";
  if (percentage > 85) color = "🔴";
  else if (percentage > 60) color = "🟡";

  return `${color} ${percentage}%`;
}

function formatTools(metrics: SessionMetrics): string | null {
  if (!metrics.tools || Object.keys(metrics.tools).length === 0) return null;

  const toolsStr = Object.entries(metrics.tools)
    .map(([name, count]) => `${name}×${count}`)
    .join(" ");

  return `Tools: ${toolsStr}`;
}

function formatAgents(metrics: SessionMetrics): string | null {
  if (!metrics.agents || Object.keys(metrics.agents).length === 0) return null;

  const agentsStr = Object.entries(metrics.agents)
    .map(([name, { elapsed }]) => `${name}(${elapsed}s)`)
    .join(" ");

  return `Agents: ${agentsStr}`;
}

function formatTasks(metrics: SessionMetrics): string | null {
  if (!metrics.tasks || metrics.tasks.total === 0) return null;

  const { pending, inProgress, completed } = metrics.tasks;
  const parts = [];

  if (inProgress > 0) parts.push(`🔄 ${inProgress}`);
  if (pending > 0) parts.push(`⏳ ${pending}`);
  if (completed > 0) parts.push(`✓ ${completed}`);

  return parts.length > 0 ? `Tasks: ${parts.join(" ")}` : null;
}

function formatModel(model?: string): string | null {
  if (!model) return null;
  return `Model: ${model}`;
}

function formatDuration(duration?: string): string | null {
  if (!duration) return null;
  return duration;
}

function formatRateLimits(rateLimits?: RateLimits): string | null {
  if (!rateLimits) return null;

  if (rateLimits.error === "scope_required") {
    return "5h: re-login | 7d: needed";
  }
  if (rateLimits.error) {
    return null;
  }

  const provider = rateLimits.provider ?? "anthropic";

  // z.ai format: 5-hour tokens + monthly tools
  if (provider === "zai" && rateLimits.zai) {
    const z = rateLimits.zai;
    const parts: string[] = [];

    parts.push(`Tokens: ${z.tokens_pct}%`);
    if (z.token_reset) {
      parts.push(`5h reset: ${z.token_reset}`);
    }

    if (z.monthly_remaining > 0) {
      parts.push(`Tools: ${z.monthly_pct}% (${z.monthly_remaining} left, ${z.monthly_reset})`);
    }

    const toolParts: string[] = [];
    if (z.search > 0) toolParts.push(`Search:${z.search}`);
    if (z.web > 0) toolParts.push(`Web:${z.web}`);
    if (z.zread > 0) toolParts.push(`ZRead:${z.zread}`);

    if (toolParts.length > 0) {
      parts.push(toolParts.join(" "));
    }

    return `z.ai ${parts.join(" | ")}`;
  }

  // Anthropic format (5h/7d)
  const u5h = Math.round(rateLimits.five_hour);
  const u7d = Math.round(rateLimits.seven_day);
  return `5h: ${u5h}% | 7d: ${u7d}%`;
}

export function formatStatus(metrics: SessionMetrics): FormattedStatus {
  const parts: string[] = [];

  const contextStr = formatContext(metrics);
  if (contextStr) parts.push(contextStr);

  const rateLimitsStr = formatRateLimits(metrics.rateLimits);
  if (rateLimitsStr) parts.push(rateLimitsStr);

  const modelStr = formatModel(metrics.model);
  if (modelStr) parts.push(modelStr);

  const durationStr = formatDuration(metrics.duration);
  if (durationStr) parts.push(durationStr);

  const toolsStr = formatTools(metrics);
  if (toolsStr) parts.push(toolsStr);

  const agentsStr = formatAgents(metrics);
  if (agentsStr) parts.push(agentsStr);

  const tasksStr = formatTasks(metrics);
  if (tasksStr) parts.push(tasksStr);

  const line = `📊 ${parts.join(" | ")}`;

  return { line, parts };
}

export function isShouldDisplay(metrics: SessionMetrics): boolean {
  return !!(
    metrics.context ||
    (metrics.tools && Object.keys(metrics.tools).length > 0) ||
    (metrics.agents && Object.keys(metrics.agents).length > 0) ||
    (metrics.tasks && metrics.tasks.total > 0)
  );
}

// ===========================================================================
// CLI MODE (for calling from session-start.sh hook)
// ===========================================================================

async function main() {
  const rateLimits = await fetchRateLimits();
  if (rateLimits) {
    console.log(JSON.stringify(rateLimits));
  } else {
    console.log(JSON.stringify({ error: "fetch_failed" }));
  }
}

// Run as CLI if this file is executed directly
const isCli = import.meta.url === `file://${process.argv[1]}`;
if (isCli) {
  main().catch(() => {
    console.log(JSON.stringify({ error: "fetch_failed" }));
    process.exit(1);
  });
}
