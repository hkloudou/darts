.PHONY: default
.DEFAULT_GOAL := default

default:
	dart format ./
	dart pub publish --dry-run
pub:
	flutter packages pub publish --server=https://pub.dartlang.org