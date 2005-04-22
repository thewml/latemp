
RSYNC = rsync --progress --verbose --rsh=ssh

ALL_DEST_BASE = dest

DOCS_COMMON_DEPS = template.wml lib/MyNavData.pm

WML_FLAGS = -DLATEMP_THEME=better-scm

LATEMP_WML_INCLUDE_PATH =$(shell latemp-config --wml-include-path)

WML_FLAGS += --passoption=2,-X3074 --passoption=3,-I../../lib/ \
	--passoption=3,-w -I$(LATEMP_WML_INCLUDE_PATH) -I../../ -DROOT~. \
    -I../../lib/

all: dummy

%.show:
	@echo "$* = $($*)"

include include.mak
include rules.mak

dummy : latemp_targets

.PHONY: 

upload_beta: all
	cd $(ALL_DEST_BASE)/mysite && \
	$(RSYNC) -r * shlomif@shell.berlios.de:/home/groups/web-cpan/htdocs/latemp/

