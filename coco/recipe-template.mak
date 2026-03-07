# Optional per-recipe overrides for coco/coco.mak.
#
# Usage:
#   1) Copy 40d/ to a new recipe folder (for example myrecipe/).
#   2) Copy this file to myrecipe/recipe.mak.
#   3) Edit only what you need.

# Used in output name: l<LEVEL>_<RECIPE>.dsk
# Example: l1_mykit.dsk
RECIPE ?= coco

# Append additional compiler/linker flags
# AFLAGS_EXTRA += -DMY_FEATURE=1
# LFLAGS_EXTRA += -L /path/to/extra/libdir

# Append modules to the default bootfile merge
# BOOTMODS_EXTRA += mybootmod

# Append commands copied into the disk image
# CMDS_EXTRA += mycmd
