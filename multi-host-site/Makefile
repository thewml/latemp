
RSYNC = rsync --progress --verbose --rsh=ssh

DEVEL_VER_USE_CACHE = 1

D = dest

DOCS_COMMON_DEPS = template.wml lib/MyNavData.pm

WML_FLAGS = -DLATEMP_THEME=better-scm

all: dummy

%.show:
	@echo "$* = $($*)"

include include.mak
include rules.mak



WML_FLAGS += --passoption=2,-X3074 --passoption=3,-I../../lib/ \
	--passoption=3,-w -I../../lib/ -I../../ -DROOT~.

dummy : $(T2_TARGETS) $(VIPE_TARGETS)

.PHONY: 

upload_beta: all
	cd $(D) && \
	$(RSYNC) -r * shlomif@shell.berlios.de:/home/groups/web-cpan/htdocs/__LaTemp-Beta-Site-f67bu9o/
