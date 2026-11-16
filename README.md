# Kiedy śmieci

Prosta apka pokazująca kiedy w danym miesiącu wywożone są śmieci.

Domyślnie używamy [mise](https://mise.jdx.dev/) i Ruby 4.0.9.

```sh
mise trust
mise install
mise run setup
mise run test
mise run server
```

Lint: `mise run lint`. Pojedynczy plik testów:
`mise exec -- bundle exec rspec spec/trash_date_parser_spec.rb`.

Konfiguracja środowiska lokalnego znajduje się w `.env` (patrz `CLAUDE.md`).
Wersja Ruby w `mise.toml`, `.ruby-version`, `Gemfile` i `Dockerfile` powinna być zgodna.
