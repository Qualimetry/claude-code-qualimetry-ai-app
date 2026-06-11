---
description: Configure the Qualimetry MCP server URL and access token. Runs once per machine.
argument-hint: (no arguments — interactive)
---

# Qualimetry: Setup

Walk the user through configuring the Qualimetry MCP server. Follow this exact procedure:

1. Ask the user, in plain language: **"What is your Qualimetry server URL? (default: `https://myorg.qualimetry.io/mcp/`)"**. If they reply with an empty message or "default", use `https://myorg.qualimetry.io/mcp/`.

2. Ask the user: **"Paste your Qualimetry access token. The text will be visible in the chat — clear the chat afterwards if you want to keep it private."**. (Claude Code does not natively hide pasted text in chat; flag this honestly so the user can choose to clear after.)

3. Validate the URL ends in `/mcp/` (or `/mcp`); if not, append `/mcp/` and tell the user what you adjusted.

4. Run **exactly one** of the following Bash commands to register or update the MCP server (both are idempotent — `add` removes and re-adds when the name already exists):

   ```bash
   claude mcp remove qualimetry --scope user 2>/dev/null
   claude mcp add qualimetry --scope user --transport http --url "<URL>" --header "qualimetry-access-token: <TOKEN>"
   ```

   Substitute `<URL>` and `<TOKEN>` with the values the user provided.

5. Verify by running:

   ```bash
   claude mcp list | grep qualimetry
   ```

   It should show the `qualimetry` server connected with status `✓ Connected`. If it does not, ask the user to **restart Claude Code** so the new MCP entry is loaded, then re-run `claude mcp list`.

6. Once connected, run a smoke check by invoking the MCP tool `get_policies` (no arguments). If it returns a JSON array of policies, the setup is complete. If it returns an authentication error, the token is wrong — ask the user to re-run `/qualimetry-setup` with the correct token.

7. End with the verbatim message:

   > ✓ Qualimetry configured. You can now `/compliance-check`, `/compliance-fix`, or just open a reviewed file and Qualimetry will surface any open issues automatically.

## Notes for the agent

- The token must never be displayed back in any subsequent chat message. Echo only `****` in any quote-back.
- If `claude mcp` is not on PATH, fall back to `~/.claude.json` direct edit: read the file, locate or create the `mcpServers.qualimetry` entry with `{"type": "http", "url": "<URL>", "headers": {"qualimetry-access-token": "<TOKEN>"}}`, write it back. Tell the user they may need to restart Claude Code.
- If the user re-runs this command, treat it as a re-config: remove first, add fresh.
