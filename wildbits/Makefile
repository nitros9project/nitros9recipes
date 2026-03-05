# Wildbits Top-Level Makefile
# Builds both Level 1 (WildbitsJr) and Level 2 (WildbitsK2) disk images

.PHONY: all l1 l2 clean

all: clean l1 l2
	@echo ""
	@echo "Build complete. Disk images:"
	@ls -la disk_images/*.dsk

l1:
	$(MAKE) -C l1 PLATFORM=jr

l2:
	$(MAKE) -C l2 PLATFORM=k2

clean:
	rm -f disk_images/*.dsk
