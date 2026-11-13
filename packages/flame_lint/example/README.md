# flame_lint example

Add `flame_lint` as a development dependency:

```shell
dart pub add dev:flame_lint
```

Then include the lint rules in the `analysis_options.yaml` file of your project:

```yaml
include: package:flame_lint/analysis_options.yaml
```

The analyzer and your IDE will now report anything that doesn't follow the rules, which you can
also check from the command line:

```shell
dart analyze
```
