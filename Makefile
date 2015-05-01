doc := doc
test := test


all: doc test

clean:
	$(RM) -R $(doc)

.PHONY: doc
doc:
	luadoc -d $(doc) mods/worldgen_utils

.SILENT .PHONY: test
test: $(test)/*.lua
	$(foreach file,$^,lua $(file);)

