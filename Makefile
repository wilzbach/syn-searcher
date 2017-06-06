DMD=bin/dmd2/linux/bin64/dmd
DMD_VERSION=2.074.1
LDC=bin/ldc2-$(LDC_VERSION)-linux-$(PLATFORM)/bin/ldc2
LDC_VERSION=1.2.0
DFLAGS=-g
LDC_RELEASE_FLAGS=-O4 -mcpu=native -release
PLATFORM=x86_64

################################################################################
# Auto-bootstrap DMD & LDC for outdated Debian/Ubuntu
################################################################################

bin:
	mkdir -p $@

bin/dmd2: | bin
	curl -fSL --retry 3 "http://downloads.dlang.org/releases/2.x/$(DMD_VERSION)/dmd.$(DMD_VERSION).linux.tar.xz" | tar -Jxf - -C $|
bin/dmd2/linux/bin64/dmd: | bin/dmd2

bin/ldc2-$(LDC_VERSION)-linux-$(PLATFORM): | bin
	curl -fSL --retry 3 "https://github.com/ldc-developers/ldc/releases/download/v$(LDC_VERSION)/ldc2-$(LDC_VERSION)-linux-$(PLATFORM).tar.xz" \
	| tar -Jxf - -C $|

bin/ldc2-$(LDC_VERSION)-linux-$(PLATFORM)/bin/ldc2: | bin/ldc2-$(LDC_VERSION)-linux-$(PLATFORM)

################################################################################
# Auto-bootstrap DMD & LDC for outdated Debian/Ubuntu
################################################################################

D_FILES = $(addsuffix .d , $(addprefix src/syngrep/, main data))

bin/syngrep: $(D_FILES) $(DMD) | bin
	$(DMD) $(DFLAGS) $(D_FILES) -of$@

bin/syngrep_opt: $(D_FILES) $(LDC) | bin
	$(LDC) $(DFLAGS) $(LDC_RELEASE_FLAGS) $(D_FILES) -of$@

