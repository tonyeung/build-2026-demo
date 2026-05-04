# Copilot instructions

This repo is a GitHub BUILD 2026 demo. Keep generated code:

- **Minimal** — demo audiences read the diff live; favor short, obvious snippets over abstractions.
- **Runnable end-to-end** — every code path shown on stage must execute without a hidden setup step.
- **Annotated** — comments explain the *why* of demo-specific choices (e.g. "using direct REST instead of an SDK to keep the call shape visible").

When suggesting changes, prefer the patterns already in `examples/`. The two demo paths are:

1. **Copilot CLI / agent flows** via the `@github/copilot-sdk` family (npm, PyPI, Go, NuGet).
2. **GitHub Models direct API** at `https://models.github.ai/inference` with `Authorization: Bearer $GITHUB_TOKEN`.
