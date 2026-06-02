# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

"Kiedy śmieci" is a small Sinatra web app (Polish: "When is trash day?") that fetches trash collection schedules from the ecoharmonogram.pl API and displays them as a calendar. It also exposes a `/calendar.ics` endpoint for subscribing via webcal.

## Commands

```bash
# Install dependencies
bundle install

# Run development server (port 4567, auto-reloads)
make server
# or directly:
bundle exec rackup --host 0.0.0.0 -p 4567

# Run tests
bundle exec rspec
# or via Rake
bundle exec rake spec

# Run a single spec file
bundle exec rspec spec/trash_date_parser_spec.rb

# Lint (StandardRB)
bundle exec standardrb

# Deploy to Fly.io
make deploy

# Clear schedule cache
make clean_data
```

## Environment Variables

Required (in `.env` for local dev):

- `COMMUNITY_ID` — ID for the trash collection community/area
- `STREET_NAME` — Street name for filtering schedules
- `TOWN_ID` — Town ID for the API query
- `CACHE_DIR` — Optional; defaults to `tmp/`, set to `/data` in production (Fly.io persistent volume)

## Architecture

**Data flow:**

1. `Downloader` fetches schedule data from `api.ecoharmonogram.pl/v1/plugin/v1` — iterates over schedule periods → streets → schedules, and merges results.
2. `main.rb` (Server class) caches the result as JSON in `CACHE_FILE` for up to 30 days. Cache is invalidated by deleting the file or after 30 days.
3. `TrashDateParser` wraps the raw JSON, constructing `Schedule` objects (one per trash type per month) and `TrashDay` objects (one per calendar date, potentially with multiple trash types). It filters out "Terminy płatności" entries.
4. Views (`views/index.erb`, `views/layout.erb`) render the schedule using the parsed data.
5. `CalendarGenerator` uses the `icalendar` gem to produce an `.ics` feed from `TrashDay` objects, with all-day events and an 8-hour pre-alarm.

**Key model classes** (all in `lib/`):

- `Schedule` — one trash type for one month; parses semicolon-delimited day numbers
- `TrashDay` — one date with one or more trash types; provides `days_from_today`
- `TrashDateParser` — aggregates schedules into sorted `TrashDay` list
- `Downloader` — HTTP client for ecoharmonogram.pl API
- `CalendarGenerator` — produces iCal output

**i18n:** Polish locale strings live in `config/locales/pl.yml`, loaded at startup. The `CalendarGenerator` has additional hardcoded Polish strings (calendar name, description, URL) that reference "Turew" specifically — these would need manual edits if reusing for a different community.

**Production:** Deployed on Fly.io (`waw` region). The persistent volume is mounted at `/data` and used as `CACHE_DIR`.

## Testing

Specs live in `spec/`. Test data is loaded from `spec/test_data.json` (real API response fixture). No mocking of the API — tests parse the fixture directly.
