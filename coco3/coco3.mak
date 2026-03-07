PORT ?= coco3
CPU ?= 6809
MACHINE ?= Tandy Color Computer 3
include ../../rules.mak
RECIPE ?= coco3
-include recipe.mak
vpath %.asm $(LEVEL1)/coco1/modules

DSKIMAGE ?= l$(LEVEL)_$(RECIPE).dsk

AFLAGS += -I.
AFLAGS += -I$(L2MD)/kernel -I$(L2PMD)
AFLAGS += -I$(L1MD)/kernel -I$(L1MD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) -lcoco3 -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1

RBF = rbf.mn rb1773.dr ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd
SCF = scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw
PIPE = pipeman.mn piper.dr pipe.dd
CLOCK = clock_60hz clock2_soft
KERNEL_TRACK = rel_80 boot_1773_6ms krn
KERNELFILE = kerneltrack
STARTUP ?= $(NITROS9DIR)/level2/$(PORT)/startup

BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	sysgo_dd shell_21 \
	$(BOOTMODS_EXTRA)

SHELLMODS = shellplus date deiniz echo iniz link load save unlink
UTILPAK1 = attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode

CMDS += $(STDCMDS) grfdrv shell utilpak1 \
	$(CMDS_EXTRA)

all: libs $(DSKIMAGE)

LIB_NAMES = libnos96809l2.a libnet.a libalib.a libcoco3.a
include ../../libs.mak

kernelfile: $(KERNEL_TRACK)
	$(MERGE) $(KERNEL_TRACK)>$(KERNELFILE)

bootfile: $(BOOTMODS)
	$(MERGE) $(BOOTMODS)>$@

$(DSKIMAGE): kernelfile bootfile $(CMDS) $(STARTUP)
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup

# Command rules
pwd: pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

pxd: pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

xmode: xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

tmode: xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

shell: $(SHELLMODS)
	$(MERGE) $(SHELLMODS) >$@

utilpak1: $(UTILPAK1)
	$(MERGE) $(UTILPAK1) >$@

# CoCo 3 kernel/booter variants
boot_1773_6ms: boot_1773.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSTEP=0

sysgo_dd: sysgo.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1

clock_60hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=60

# CoCo 3 rel variant
rel_80: rel.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DWidth=80

# CoCo 3 floppy descriptors
ddd0_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0 -DDD=1

d0_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0

d1_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=1

d2_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=2

clean:
	$(RM) $(KERNEL_TRACK) $(BOOTMODS) $(CMDS) *.list *.map bootfile $(KERNELFILE) *.dsk
	-rm -rf $(OBJDIR) $(LIBDIR)

.PHONY: all clean libs
