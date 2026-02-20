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

## Tech Stack

See `gleam.toml` for version details.

- **Gleam** targeting JavaScript
- **Lustre** for reactive UI
- **Erlang/OTP** + Rebar3 for build tooling
- **Devbox/Nix** for reproducible dev environment
- **gleeunit** for testing
