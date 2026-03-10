# Contributing

Thanks for contributing.

## Before opening a PR

1. Test changes on hardware when possible.
2. Keep machine-specific values documented (offsets, limits, temperatures).
3. Avoid committing sensitive values (tokens, local IPs if private, hostnames if private).
4. Update docs when behavior changes (`README.md`, `CHANGELOG.md`, or macro docs).

## Branch and commit style

- Use short, clear branch names.
- Keep commits focused and descriptive.
- Preferred commit style:
  - `feat: add ...`
  - `fix: correct ...`
  - `docs: update ...`

## Pull request checklist

- [ ] I tested this change in a realistic workflow.
- [ ] I updated docs if needed.
- [ ] I did not include unrelated changes.
- [ ] I described risks and rollback steps.
