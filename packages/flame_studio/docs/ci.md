# CI

Flame Studio has no workflow of its own: it is checked by `.github/workflows/cicd.yml`, like the
other packages of the monorepo.

| Job                            | What it checks                                     |
| ------------------------------ | -------------------------------------------------- |
| `format`                       | Everything is formatted (`melos run format-check`) |
| `analyze`, `analyze-latest`    | No analyzer issues, infos included                 |
| `dcm`                          | The DCM rules from `flame_lint`                    |
| `test`                         | Tests pass (`melos run test:select`)               |
| `markdown-lint`                | The Markdown files follow the repository rules     |

Notes:

- CI doesn't run `bloc lint` or enforce a coverage minimum, so run `bloc lint .` locally, after
  `dart pub global activate bloc_tools`, when changing blocs.
- The repository-wide spell check also covers this folder. Add legitimate project words to the
  sorted dictionaries in `.github/.cspell/` instead of rewording code.
- PR titles are validated by `title-validation.yml`.
