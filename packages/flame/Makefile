
.PHONY: test
test:
	@flutter test

.PHONY: format
format:
	@flutter analyze
	@flutter format .

.PHONY: coverage
coverage:
	@flutter test --coverage
	@genhtml coverage/lcov.info --output-directory=coverage/
