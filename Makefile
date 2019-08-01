buildDir = build

scalaVersion = 2.12
scalaMinorVersion = 6

www-src = \
	$(shell find docs/src/main/tut/ -name *.md) \
	$(shell find docs/src/main/resources)
chisel-src = $(shell find chisel3/ chisel-testers/ -name *.scala)

# Get all semantic version tags for a git project in a given directory
# Usage: $(call getTags,foo)
define getTags
	$(shell cd $(1) && git tag | grep "^v\([0-9]\+\.\)\{2\}[0-9]\+$$")
endef

firrtlTags = $(call getTags,firrtl)
chiselTags = $(call getTags,chisel3)
testersTags = $(call getTags,chisel-testers)
treadleTags = $(call getTags,treadle)
diagrammerTags = $(call getTags,diagrammer)

# Build all API docs
api = \
	chisel3/target/scala-$(scalaVersion)/unidoc/index.html \
	firrtl/target/scala-$(scalaVersion)/unidoc/index.html \
	chisel-testers/target/scala-$(scalaVersion)/api/index.html \
	treadle/target/scala-$(scalaVersion)/api/index.html \
	diagrammer/target/scala-$(scalaVersion)/api/index.html \
	$(chiselTags:%=$(buildDir)/chisel3/%/target/scala-$(scalaVersion)/unidoc/index.html) \
	$(firrtlTags:%=$(buildDir)/firrtl/%/target/scala-$(scalaVersion)/unidoc/index.html) \
	$(testersTags:%=$(buildDir)/chisel-testers/%/target/scala-$(scalaVersion)/api/index.html) \
	$(treadleTags:%=$(buildDir)/treadle/%/target/scala-$(scalaVersion)/api/index.html) \
	$(diagrammerTags:%=$(buildDir)/diagrammer/%/target/scala-$(scalaVersion)/api/index.html)

api-copy = \
	docs/target/site/api/chisel3/latest/index.html \
	docs/target/site/api/firrtl/latest/index.html \
	docs/target/site/api/chisel-testers/latest/index.html \
	docs/target/site/api/treadle/latest/index.html \
	docs/target/site/api/diagrammer/latest/index.html \
	$(chiselTags:%=docs/target/site/api/chisel3/%/index.html) \
	$(firrtlTags:%=docs/target/site/api/firrtl/%/index.html) \
	$(testersTags:%=docs/target/site/api/chisel-testers/%/index.html) \
	$(treadleTags:%=docs/target/site/api/treadle/%/index.html) \
	$(diagrammerTags:%=docs/target/site/api/diagrammer/%/index.html)

.PHONY: all clean info mrproper serve
.PRECIOUS: \
	$(buildDir)/chisel3/%/.git $(buildDir)/chisel3/%/target/scala-$(scalaVersion)/unidoc/index.html \
	$(buildDir)/firrtl/%/.git $(buildDir)/firrtl/%/target/scala-$(scalaVersion)/unidoc/index.html \
	$(buildDir)/chisel-testers/%/.git $(buildDir)/chisel-testers/%/target/scala-$(scalaVersion)/api/index.html \
	$(buildDir)/treadle/%/.git $(buildDir)/treadle/%/target/scala-$(scalaVersion)/api/index.html \
	$(buildDir)/diagrammer/%/.git $(buildDir)/diagrammer/%/target/scala-$(scalaVersion)/api/index.html

# Build the site into the default directory (docs/target/site)
all: docs/target/site/index.html

info:
	@echo FIRRTL tags: $(call getTags,firrtl)
	@echo Chisel tags: $(call getTags,chisel3)
	@echo Testers tags: $(call getTags,chisel-testers)
	@echo Diagrammer tags: $(call getTags,diagrammer)
	@echo Treadle tags: $(call getTags,treadle)

# Remove the output of all build targets
clean:
	rm -rf $(buildDir)/api docs/target

# Remove everything
mrproper:
	rm -rf $(buildDir) target project/target firrtl/target treadle/target diagrammer/target

# Start a Jekyll server for the site
serve: all
	(cd docs/target/site && jekyll serve)

# Build the sbt-microsite
docs/target/site/index.html: build.sbt $(www-src) $(chisel-src) $(api-copy)
	sbt ++$(scalaVersion).$(scalaMinorVersion) docs/makeMicrosite

# Build API of subprojects
chisel3/target/scala-$(scalaVersion)/unidoc/index.html: $(shell find chisel3/src chisel-testers/src -name *.scala) | chisel3/.git chisel-testers/.git
	(cd chisel3/ && sbt ++$(scalaVersion).$(scalaMinorVersion) unidoc)
firrtl/target/scala-$(scalaVersion)/unidoc/index.html: $(shell find firrtl/src -name *.scala) | firrtl/.git
	(cd firrtl/ && sbt ++$(scalaVersion).$(scalaMinorVersion) unidoc)
chisel-testers/target/scala-$(scalaVersion)/api/index.html: $(shell find chisel-testers/src -name *.scala) | chisel-testers/.git
	(cd chisel-testers/ && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)
treadle/target/scala-$(scalaVersion)/api/index.html: $(shell find treadle/src -name *.scala) | treadle/.git
	(cd treadle/ && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)
diagrammer/target/scala-$(scalaVersion)/api/index.html: $(shell find diagrammer/src -name *.scala) | diagrammer/.git
	(cd diagrammer/ && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)

# Copy built API into site
docs/target/site/api/chisel3/latest/index.html: chisel3/target/scala-$(scalaVersion)/unidoc/index.html | docs/target/site/api/chisel3/
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/firrtl/latest/index.html: firrtl/target/scala-$(scalaVersion)/unidoc/index.html | docs/target/site/api/firrtl/
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/treadle/latest/index.html: treadle/target/scala-$(scalaVersion)/api/index.html | docs/target/site/api/treadle/
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/chisel-testers/latest/index.html: chisel-testers/target/scala-$(scalaVersion)/api/index.html | docs/target/site/api/chisel-testers/
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/diagrammer/latest/index.html: diagrammer/target/scala-$(scalaVersion)/api/index.html | docs/target/site/api/diagrammer/
	cp -r $(dir $<) $(dir $@)

# Build *old* API of subprojects
$(buildDir)/chisel3/%/target/scala-$(scalaVersion)/unidoc/index.html: $(buildDir)/chisel3/%/.git
	(cd $(buildDir)/chisel3/$* && sbt ++$(scalaVersion).$(scalaMinorVersion) unidoc)
$(buildDir)/firrtl/%/target/scala-$(scalaVersion)/unidoc/index.html: $(buildDir)/firrtl/%/.git
	(cd $(buildDir)/firrtl/$* && sbt ++$(scalaVersion).$(scalaMinorVersion) unidoc)
$(buildDir)/chisel-testers/%/target/scala-$(scalaVersion)/api/index.html: $(buildDir)/chisel-testers/%/.git
	(cd $(buildDir)/chisel-testers/$* && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)
$(buildDir)/treadle/%/target/scala-$(scalaVersion)/api/index.html: $(buildDir)/treadle/%/.git
	(cd $(buildDir)/treadle/$* && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)
$(buildDir)/diagrammer/%/target/scala-$(scalaVersion)/api/index.html: $(buildDir)/diagrammer/%/.git
	(cd $(buildDir)/diagrammer/$* && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)

# Copy *old* API of subprojects
docs/target/site/api/chisel3/%/index.html: $(buildDir)/chisel3/%/target/scala-$(scalaVersion)/unidoc/index.html
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/firrtl/%/index.html: $(buildDir)/firrtl/%/target/scala-$(scalaVersion)/unidoc/index.html
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/chisel-testers/%/index.html: $(buildDir)/chisel-testers/%/target/scala-$(scalaVersion)/api/index.html
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/treadle/%/index.html: $(buildDir)/treadle/%/target/scala-$(scalaVersion)/api/index.html
	cp -r $(dir $<) $(dir $@)
docs/target/site/api/diagrammer/%/index.html: $(buildDir)/diagrammer/%/target/scala-$(scalaVersion)/api/index.html
	cp -r $(dir $<) $(dir $@)

# Utilities to either fetch submodules or create directories
%/.git:
	git submodule update --init $*
$(buildDir)/chisel3/%/.git:
	git clone "https://github.com/freechipsproject/chisel3.git" --depth 1 --branch $* $(dir $@)
$(buildDir)/firrtl/%/.git:
	git clone "https://github.com/freechipsproject/firrtl.git" --depth 1 --branch $* $(dir $@)
$(buildDir)/chisel-testers/%/.git:
	git clone "https://github.com/freechipsproject/chisel-testers.git" --depth 1 --branch $* $(dir $@)
$(buildDir)/treadle/%/.git:
p	git clone "https://github.com/freechipsproject/treadle.git" --depth 1 --branch $* $(dir $@)
$(buildDir)/diagrammer/%/.git:
	git clone "https://github.com/freechipsproject/diagrammer.git" --depth 1 --branch $* $(dir $@)
docs/target/site/api/%/:
	mkdir -p $@
