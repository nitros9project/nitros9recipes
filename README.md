# NitrOS-9 Build Recipes

The goal of this repository is to decouple the build process and resulting build artifacts from the NitrOS-9 repository itself. Anyone is free to use whatever build tool (e.g. make, ninja) they choose to build for their particular port (CoCo, Dragon, Wildbits, etc.) 

## Structure

At the top folder are two files:

- `rules.mak`: contains rules for various file types
- `libs.mak`: a makefile for building libraries

Port-specific makefiles include these files.

