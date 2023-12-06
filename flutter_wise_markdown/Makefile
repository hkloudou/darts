.PHONY: default
.DEFAULT_GOAL := default
init:
	flutter create --org com.hkloudou.richappbar  -i objc -a java --template=plugin ./
default:
	-git autotag -commit 'modify' -f -p
	@echo current version:`git describe`
git:
	- git autotag -commit 'auto commit' -t -f -i -p
	@echo current version:`git describe`
retag:
	-git autotag -commit 'modify $(shell git describe)' -t -f -p
	@echo current version:`git describe`