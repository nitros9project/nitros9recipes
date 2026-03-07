# CoCo 3 Build Recipes

This document covers building shared CoCo 3 targets from this repository.

## Creating Your Own Recipe (Copy Workflow)

You can clone the base recipe folder with minimal makefile edits.

Example from [`coco3/`](./). The template file is [`recipe-template.mak`](recipe-template.mak).

```sh
cp -R l2 myrecipe
cp recipe-template.mak myrecipe/recipe.mak
cd myrecipe
make
```

Only edit `myrecipe/recipe.mak` for common customization:

- `RECIPE` to change output name
- `CMDS_EXTRA` to add disk commands
- `BOOTMODS_EXTRA` to add boot modules
- `AFLAGS_EXTRA` / `LFLAGS_EXTRA` for extra flags

## Prerequisites

From the repository root, ensure:

- `NITROS9DIR` is set to your NitrOS-9 source tree
- toolchain is on `PATH`: `make`, `lwasm`, `lwlink`, `lwar`, `os9`

## Build Directories

- [`l2/`](l2/) builds CoCo 3 Level 2 40-track double-sided disk images

Each build directory keeps intermediate artifacts local:

- `.obj/` object files
- `.lib/` static libraries

## Level 2 Build ([`coco3/l2`](l2/))

```sh
cd l2
make
```

Primary output:

- `l2_coco3.dsk` (default)

## Notes

- Shared build logic is in [`coco3.mak`](coco3.mak).
- This recipe targets a practical default CoCo 3 floppy boot configuration.
- Use `recipe.mak` to extend command/module selections without editing shared makefiles.
