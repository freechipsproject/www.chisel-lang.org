buildDir = build

scalaVersion = 2.12
scalaMinorVersion = 6

www-src = \
	$(shell find docs/src/main/tut/ -name *.md) \
	$(shell find docs/src/main/resources)
chisel-src = $(shell find chisel3/ chisel-testers/ -name *.scala)

# Build all API docs
api = \
	firrtl/target/scala-$(scalaVersion)/unidoc/index.html \
	treadle/target/scala-$(scalaVersion)/api/index.html \
	chisel3/target/scala-$(scalaVersion)/unidoc/index.html \
	diagrammer/target/scala-$(scalaVersion)/api/index.html

api-copy = \
	docs/target/site/api/firrtl/index.html \
	docs/target/site/api/treadle/index.html \
	docs/target/site/api/chisel3/index.html \
	docs/target/site/api/diagrammer/index.html

.PHONY: all clean mrproper serve

# Build the site into the default directory (docs/target/site)
all: docs/target/site/index.html

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
	sbt docs/makeMicrosite

# Build API of subprojects
firrtl/target/scala-$(scalaVersion)/unidoc/index.html: $(shell find firrtl/src -name *.scala) | firrtl/.git
	(cd firrtl/ && sbt ++$(scalaVersion).$(scalaMinorVersion) unidoc)
treadle/target/scala-$(scalaVersion)/api/index.html: $(shell find treadle/src -name *.scala) | treadle/.git
	(cd treadle/ && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)
chisel3/target/scala-$(scalaVersion)/unidoc/index.html: $(shell find chisel3/src chisel-testers/src -name *.scala) | chisel3/.git chisel-testers/.git
	sbt ++$(scalaVersion).$(scalaMinorVersion) unidoc
diagrammer/target/scala-$(scalaVersion)/api/index.html: $(shell find diagrammer/src -name *.scala) | diagrammer/.git
	(cd diagrammer/ && sbt ++$(scalaVersion).$(scalaMinorVersion) doc)

# Copy built API into site
docs/target/site/api/firrtl/index.html: firrtl/target/scala-$(scalaVersion)/unidoc/index.html | docs/target/site/api/firrtl/
	cp -r firrtl/target/scala-$(scalaVersion)/unidoc/* docs/target/site/api/firrtl/.
docs/target/site/api/treadle/index.html: treadle/target/scala-$(scalaVersion)/api/index.html | docs/target/site/api/treadle/
	cp -r treadle/target/scala-$(scalaVersion)/api/* docs/target/site/api/treadle/.
docs/target/site/api/chisel3/index.html: chisel3/target/scala-$(scalaVersion)/unidoc/index.html | docs/target/site/api/chisel3/
	cp -r chisel3/target/scala-$(scalaVersion)/unidoc/* docs/target/site/api/chisel3/.
docs/target/site/api/diagrammer/index.html: diagrammer/target/scala-$(scalaVersion)/api/index.html | docs/target/site/api/diagrammer/
	cp -r diagrammer/target/scala-$(scalaVersion)/api/* docs/target/site/api/diagrammer/.

# Utilities to either fetch submodules or create directories
%/.git:
	git submodule update --init $*
docs/target/site/api/%/:
	mkdir -p $@
