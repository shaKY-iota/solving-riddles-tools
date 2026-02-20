# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Gleam/Lustre web application targeting JavaScript. A collection of interactive tools for solving riddles/puzzles.

## Commands

```bash
gleam run -m lustre/dev start   # Start dev server (or: devbox run dev)
gleam test                      # Run tests (gleeunit)
gleam format --check src test   # Check formatting
gleam deps download             # Download dependencies
```

## Architecture

Uses **The Elm Architecture (TEA)** via Lustre. The app mounts to `#app` in the DOM.

- **`src/solving_riddles_tools.gleam`** — App entry point. Wraps child component models/messages and delegates to each tool component.

Pattern: parent app delegates init/update/view to child components, wrapping their `Model` and `Msg` types. Each tool lives in its own module under `src/`.

## Styling

This project uses **Tailwind CSS v4** via `lustre_dev_tools` built-in support.

**Rules:**
- **Do NOT add CSS classes or rules to `src/solving_riddles_tools.css`.**
  - The file must contain only `@import "tailwindcss";` and the `--cell-size` custom property.
  - `--cell-size` uses `min()` with viewport units — this is the only CSS that cannot be expressed as a Tailwind utility.
  - There is also a `@media (orientation: portrait)` block that overrides `--cell-size` for portrait layout (5 columns × 11 rows instead of 11 × 5). This is part of the `--cell-size` definition, not a new CSS class.
- **All styling must use `attribute.class()` with Tailwind utility classes in Gleam source files.**
- For dynamic values based on `--cell-size`, use Tailwind arbitrary value syntax: `w-[var(--cell-size)]`, `text-[calc(var(--cell-size)*0.5)]`, etc.

## Tech Stack

See `gleam.toml` for version details.

- **Gleam** targeting JavaScript
- **Lustre** for reactive UI
- **Erlang/OTP** + Rebar3 for build tooling
- **Devbox/Nix** for reproducible dev environment
- **gleeunit** for testing
