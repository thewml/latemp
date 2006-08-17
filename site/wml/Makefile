
RSYNC = rsync --progress --verbose --rsh=ssh

ALL_DEST_BASE = dest

DOCS_COMMON_DEPS = template.wml lib/MyNavData.pm lib/MyManageNews.pm

COMMON_PREPROC_FLAGS = -I $$HOME/conf/wml/Latemp/lib -I lib
WML_FLAGS = -DLATEMP_THEME=better-scm
WML_FLAGS += $(COMMON_PREPROC_FLAGS)
TTML_FLAGS += $(COMMON_PREPROC_FLAGS)

LATEMP_WML_FLAGS =$(shell latemp-config --wml-flags)

WML_FLAGS += --passoption=2,-X3074 --passoption=3,-I../../lib/ \
	--passoption=3,-w $(LATEMP_WML_FLAGS) -I../../ -DROOT~. \
    -I../../lib/ -I/home/shlomi/conf/wml/Latemp/lib

all: dummy

%.show:
	@echo "$* = $($*)"

include include.mak
include rules.mak

dummy : latemp_targets news_feeds

RSS_FEED = $(MYSITE_DEST)/rss.xml

news_feeds: $(RSS_FEED)

$(RSS_FEED): gen-feeds.pl lib/MyManageNews.pm
	perl -Ilib gen-feeds.pl --rss2-out="$@"

.PHONY: dummy news_feeds upload upload_beta upload_iglu all

upload: all
	cd $(ALL_DEST_BASE)/mysite && \
	$(RSYNC) -r * shlomif@shell.berlios.de:/home/groups/web-cpan/htdocs/latemp/

upload_beta: all
	cd $(ALL_DEST_BASE)/mysite && \
	$(RSYNC) -r * shlomif@shell.berlios.de:/home/groups/web-cpan/htdocs/latemp/__Beta-Site/

upload_iglu: all
	cd $(ALL_DEST_BASE)/mysite && \
	$(RSYNC) -r * shlomif@iglu.org.il:Home-Site/__Latemp-Beta-Site/

