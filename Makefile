#=============================================================================#

SRCDIR = src
OUTDIR = out
BINDIR = $(OUTDIR)/bin
DATADIR = $(OUTDIR)/data
OBJDIR = $(OUTDIR)/obj
ROMFILE = $(OUTDIR)/gbfxr.gb
AHI_TO_2BPP = $(BINDIR)/ahi_to_2bpp

ASMFILES := $(shell find $(SRCDIR) -name '*.asm')
INCFILES := $(shell find $(SRCDIR) -name '*.inc')
OBJFILES := $(patsubst $(SRCDIR)/%.asm,$(OBJDIR)/%.o,$(ASMFILES))

#=============================================================================#

.PHONY: rom
rom: $(ROMFILE)

.PHONY: run
run: $(ROMFILE)
	open -a SameBoy $<

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

#=============================================================================#

$(AHI_TO_2BPP): build/ahi_to_2bpp.c
	@mkdir -p $(@D)
	cc -o $@ $<

$(DATADIR)/%.2bpp: $(SRCDIR)/%.ahi $(AHI_TO_2BPP)
	@mkdir -p $(@D)
	$(AHI_TO_2BPP) < $< > $@

#=============================================================================#

$(ROMFILE): $(OBJFILES)
	@mkdir -p $(@D)
	rgblink --dmg --tiny -o $@ $^
	rgbfix -v -p 0 $@

define compile-asm
	@mkdir -p $(@D)
	rgbasm -Wall -Werror -o $@ $<
endef

$(OBJDIR)/data.o: $(SRCDIR)/data.asm $(DATADIR)/font.2bpp \
                  $(DATADIR)/sprites.2bpp
	$(compile-asm)

$(OBJDIR)/%.o: $(SRCDIR)/%.asm $(INCFILES)
	$(compile-asm)

#=============================================================================#
