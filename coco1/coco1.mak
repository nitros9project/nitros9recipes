RECIPE ?= coco1
-include recipe.mak

DSKIMAGE ?= l$(LEVEL)_$(RECIPE).dsk

AFLAGS += -I.
AFLAGS += -I$(L1MD)/kernel -I$(L1PMD)
AFLAGS += -I$(L1MD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) -lcoco -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

SSDD35 = -DCyls=35 -DSides=1 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
DSDD80 = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1 -DD35

RBF = rbf rb1773 ddd0_40d d0_40d d1_40d d2_40d
SCF = scf vtio covdg term_vdg
PIPE = pipeman piper pipe
CLOCK = clock_60hz clock2_soft
KERNEL_TRACK = rel krn krnp2 init boot_1773
KERNELFILE = kerneltrack

BOOTMODS = ioman \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	sysgo_dd shell_21 \
	$(BOOTMODS_EXTRA)

CMDS += $(STDCMDS) \
	$(CMDS_EXTRA)

all: libs $(DSKIMAGE)

LIB_NAMES = libnos96809l1.a libnet.a libalib.a libcoco.a
include ../libs.mak

kernelfile: $(KERNEL_TRACK)
	$(MERGE) $(KERNEL_TRACK)>$(KERNELFILE)

bootfile: $(BOOTMODS)
	$(MERGE) $(BOOTMODS)>$@

$(DSKIMAGE): kernelfile bootfile $(CMDS)
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))

# Command rules
pwd: pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

pxd: pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

xmode: xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

tmode: xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

# CoCo 1 floppy descriptors
boot_1773: boot_1773.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0 -DSTEP=0

sysgo_dd: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DDD=1

clock_60hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=60

clock_50hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=50

ddd0_35s: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=0 -DDD=1

d0_35s: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=0

d1_35s: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=1

d2_35s: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=2

d3_35s: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=3

ddd0_40d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0 -DDD=1

d0_40d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0

d1_40d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=1

d2_40d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=2

ddd0_80d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0 -DDD=1

d0_80d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0

d1_80d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=1

d2_80d: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=2

clean:
	$(RM) $(KERNEL_TRACK) $(BOOTMODS) $(CMDS) *.list *.map bootfile $(KERNELFILE) *.dsk
	-rm -rf $(OBJDIR) $(LIBDIR)

.PHONY: all clean libs
