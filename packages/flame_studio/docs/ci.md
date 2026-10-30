# CI

Flame Studio has its own GitHub Actions workflow, `.github/workflows/flame_studio.yml`, at the root
of the monorepo. It only runs when files under `packages/flame_studio/` or the workflow itself
change.

It has a single job for `packages/flame_studio`, which runs:

| Step                      | What it checks                         |
| ------------------------- | -------------------------------------- |
| `dart format`             | `lib` and `test` are formatted         |
| `flutter analyze`         | No analyzer issues in `lib` and `test` |
| `dcm analyze`             | The DCM rules from `flame_lint`        |
| `bloc lint`               | Bloc best practices                    |
| `flutter test --coverage` | Tests pass, in random order            |
| `very_good_coverage`      | **At least 50% line coverage**         |

Notes:

- The format, analyze, DCM and test jobs in `cicd.yml` skip Flame Studio, so a change in Flame that
  breaks it is only caught the next time this workflow runs.
- The repository-wide markdown lint and spell check do cover this folder. Add legitimate project
  words to the sorted dictionaries in `.github/.cspell/` instead of rewording code.
- PR titles are validated by `title-validation.yml`.
- Run `bloc lint .` locally after `dart pub global activate bloc_tools`.
