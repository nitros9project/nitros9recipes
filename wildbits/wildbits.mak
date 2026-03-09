PORT ?= wildbits
RECIPE ?= wildbits
include ../../rules.mak
-include recipe.mak

ifeq ($(PLATFORM), jr2)
  KEYSUB = keydrv_ps2
else
  KEYSUB = keydrv_k2
  PLATFORM = k2
endif

DSKIMAGE ?= l$(LEVEL)_$(RECIPE)$(PLATFORM).dsk

AFLAGS += -I.
ifeq ($(LEVEL),2)
AFLAGS += -I$(L2MD)/kernel -I$(L2PMD)
endif
AFLAGS += -I$(L1MD)/kernel -I$(L1PMD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) -lwildbitsl$(LEVEL) -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

RBF = rbf rbsuper llwbsd rbmem dds0 s1 f0 f1
SCF = scf vtio $(KEYSUB) term bannerfont palette
DRIVEWIRE_RBF = rbdw x0 x1 x2 x3
DRIVEWIRE_SCF = scdwv n1 n2 n3 n4 n5
DRIVEWIRE = dwio_serial $(DRIVEWIRE_RBF) $(DRIVEWIRE_SCF)
PIPE = pipeman piper pipe
SC16550 = sc16550 t0_sc16550
CLOCK = clock clock2_wildbits

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the text and CLUT blocks into $E000-$FFFF.
ifeq ($(LEVEL),2)
BOOTMODS = krnp2 ioman init \
	$(SCF) \
	$(RBF) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA) \
	krn
else
BOOTMODS = krn krnp2 ioman init \
	$(SCF) \
	$(RBF) \
	$(CLOCK) \
	sysgo shell_21 \
	$(BOOTMODS_EXTRA)
endif

CMDS += $(STDCMDS) \
	bootos9 wbinfo wbreset modem \
	inetd telnet dw httpd $(BASIC09) $(BF) \
	$(CMDS_EXTRA)

all: libs $(DSKIMAGE)

include ../../libs.mak

ifeq ($(LEVEL),2)
	PADUP ?= ./padup256 bootfile
endif
bootfile: $(BOOTMODS)
	$(MERGE) $(BOOTMODS)>$@
	$(PADUP)

$(DSKIMAGE): bootfile $(CMDS)
	$(RM) $@
	$(OS9FORMAT_SD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfile $@,OS9Boot
ifeq ($(LEVEL),2)
	$(OS9COPY) sysgo $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
endif
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/shellplus shell
#	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
#	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
#	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
#	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
#	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
#	$(CPL) $(STARTUP) $@,startup
#	$(OS9ATTR_TEXT) $@,startup
#	$(MAKDIR) $@,BASIC09
#	$(CPL) $(BASIC09_FILES) $@,BASIC09
#	$(MAKDIR) $@,BF
#	$(CPL) $(BF_FILES) $@,BF
#	$(MAKDIR) $@,SOUNDS
#	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
#	$(MAKDIR) $@,SCRIPTS
#	$(CD) scripts; $(CPL) $(SCRIPTS) ../$@,SCRIPTS
#	$(MAKDIR) $@,TESTS
#	$(CD) tests; $(CPL) $(TESTS) ../$@,TESTS

# Command rules
pwd:    pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

pxd:    pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

xmode:  xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1
                
tmode:  xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

# Descriptor rules
# SD card descriptors
dds0: rbwbsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(WBSDFLAGS) -DSD=0 -DDD=1

s0: rbwbsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(WBSDFLAGS) -DSD=0

s1: rbwbsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(WBSDFLAGS) -DSD=1

# rbmem descriptors
f0: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

f1: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1 -DF1=1

c0: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2 -DC0=1

c1: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3 -DC1=1

ddc0: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2 -DDD=1 -DC0=1

# DriveWire dwio modules
dwio_wizfi: dwio.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDWIO_WIZFI

dwio_serial: dwio.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDWIO_SERIAL

# DriveWire 3 RBF descriptors
ddx0: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0

x0: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

x1: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

x2: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2

x3: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# 16550 descriptors
t0_sc16550: sc16550desc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)

# DriveWire 3 SCF descriptors
term_n.dt: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0

n: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=255

n0: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0

n1: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=1

n2: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=2

n3: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=3

n4: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=4

n5: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=5

n6: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=6

n7: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=7

n8: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=8

n9: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=9

n10: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=10

n11: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=11

n12: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=12

n13: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=13

midi: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=14

term_z.dt: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=16

z1: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=17

z2: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=18

z3: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=19

z4: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=20

z5: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=21

z6: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=22

z7: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=23

z8: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=24

z9: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=25

z10: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=26

z11: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=27

z12: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=28

z13: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=29

z14: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=30

clean:
	$(RM) $(BOOTMODS) $(CMDS) *.list *.map bootfile *.dsk
	-rm -rf $(OBJDIR) $(LIBDIR)

.PHONY: all clean libs
