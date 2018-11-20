SOURCE := $(addprefix source/, $(notdir $(SOURCELIST)))
STAGE0 := $(addprefix stage0/, $(notdir $(SOURCELIST)))
DEST := $(addprefix destination/, $(addsuffix .jpg, $(notdir $(basename $(SOURCELIST)))))

$(info source $(SOURCE))
$(info stage0 $(STAGE0))
$(info destination $(DEST))

.PHONY: all clean FORCE

all: $(DEST)

FORCE:

clean: FORCE
	$(RM) destination/* stage0/* tage1/* stage2/* stage3/* stage4/* stage5/*

stage0/%.*: $(SOURCE)
	@mkdir -p stage0
	@echo cp "$(addprefix source/, $(notdir $(@)))" stage0/
	cp $(addprefix ./source/, $(notdir $(@))) stage0/
	
stage1/%.tif: stage0/%.*
	@mkdir -p stage1
	@echo stage1: autotrim "$<"
	autotrim -c southwest -f 5 "$<" "$@"

stage2/%.jpg: stage1/%.tif
	@mkdir -p stage2
	@echo stage1: deskew "$<"
	deskew -c black -n 40 -t 10 -a 100 -r 20 "$<" "$@"

stage3/%.jpg: stage2/%.jpg
	@mkdir -p stage3
	@echo stage3: autotrim "$<"
	autotrim -c southwest -f 35 "$<" "$@"

stage4/%.jpg: stage3/%.jpg
	@mkdir -p stage4
	@echo stage4: notch "$<"
	notch -c 200 -v 3 -h 2 -d 30 -s 25 "$<" "$@"

stage5/%.tif: stage4/%.jpg
	@mkdir -p stage5
	@echo stage5: autocolor "$<"
	autocolor "$<" "$@"

stage6/%.tif: stage5/%.tif
	@mkdir -p stage6
	@echo stage6: autotrim "$<"
	autotrim -c southwest -f 40 "$<" "$@"

.ONESHELL:
stage7/%.jpg: stage6/%.tif
	@mkdir -p stage7
	@echo stage7: aspect resize "$<"
	WIDTH=`convert "$<" -ping -format "%w" info:` && echo $$WIDTH
	HEIGHT=`convert "$<" -ping -format "%h" info:`
	if [ "$$WIDTH" -gt "$$HEIGHT" ]; then \
		aspect 600x423 -m pad -f Cosine "$<" "$@"; \
	else \
		aspect 423x600 -m pad -f Cosine "$<" "$@"; \
	fi

destination/%.jpg: stage7/%.jpg
	${RM} source/%.*
	mv -f "$<" "$@"
