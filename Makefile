#=============================================================================#

SRCDIR = src
OUTDIR = out
OBJDIR = $(OUTDIR)/obj
ROMFILE = $(OUTDIR)/gbfxr.gb

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

$(ROMFILE): $(OBJFILES)
	@mkdir -p $(@D)
	rgblink -o $@ $^
	rgbfix -v -p 0 $@

define compile-asm
	@mkdir -p $(@D)
	rgbasm -o $@ $<
endef

$(OBJDIR)/header.o: $(SRCDIR)/header.asm $(SRCDIR)/hardware.inc
	$(compile-asm)

$(OBJDIR)/interrupt.o: $(SRCDIR)/interrupt.asm $(SRCDIR)/hardware.inc
	$(compile-asm)

$(OBJDIR)/main.o: $(SRCDIR)/main.asm $(SRCDIR)/hardware.inc \
                  $(SRCDIR)/macros.inc
	$(compile-asm)

$(OBJDIR)/memory.o: $(SRCDIR)/memory.asm
	$(compile-asm)

$(OBJDIR)/util.o: $(SRCDIR)/util.asm $(SRCDIR)/hardware.inc
	$(compile-asm)

#=============================================================================#
