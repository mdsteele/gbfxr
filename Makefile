#=============================================================================#

SRCDIR = src
OUTDIR = out
BINDIR = $(OUTDIR)/bin
DATADIR = $(OUTDIR)/data
OBJDIR = $(OUTDIR)/obj
ROMFILE = $(OUTDIR)/gbfxr.gb
AHI_TO_2BPP = $(BINDIR)/ahi_to_2bpp

ASMFILES := $(shell find $(SRCDIR) -name '*.asm')
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

define convert-ahi
	@mkdir -p $(@D)
	$(AHI_TO_2BPP) < $< > $@
endef

$(DATADIR)/font.2bpp: $(SRCDIR)/font.ahi $(AHI_TO_2BPP)
	$(convert-ahi)

$(DATADIR)/sprites.2bpp: $(SRCDIR)/sprites.ahi $(AHI_TO_2BPP)
	$(convert-ahi)

#=============================================================================#

$(ROMFILE): $(OBJFILES)
	@mkdir -p $(@D)
	rgblink -o $@ $^
	rgbfix -v -p 0 $@

define compile-asm
	@mkdir -p $(@D)
	rgbasm -o $@ $<
endef

$(OBJDIR)/data.o: $(SRCDIR)/data.asm $(SRCDIR)/consts.inc \
                  $(DATADIR)/font.2bpp $(DATADIR)/sprites.2bpp
	$(compile-asm)

$(OBJDIR)/header.o: $(SRCDIR)/header.asm $(SRCDIR)/hardware.inc
	$(compile-asm)

$(OBJDIR)/interrupt.o: $(SRCDIR)/interrupt.asm $(SRCDIR)/hardware.inc
	$(compile-asm)

$(OBJDIR)/main.o: $(SRCDIR)/main.asm $(SRCDIR)/consts.inc \
                  $(SRCDIR)/hardware.inc $(SRCDIR)/macros.inc
	$(compile-asm)

$(OBJDIR)/memory.o: $(SRCDIR)/memory.asm
	$(compile-asm)

$(OBJDIR)/nrvalues.o: $(SRCDIR)/nrvalues.asm
	$(compile-asm)

$(OBJDIR)/util.o: $(SRCDIR)/util.asm $(SRCDIR)/hardware.inc
	$(compile-asm)

#=============================================================================#
