ifdef deb
	TARGET_DIR := bin/debug
	OPT_FLAG := -debug
else
	TARGET_DIR := bin/release
	OPT_FLAG := -o:aggressive -microarch:native -no-bounds-check -disable-assert -no-type-assert -vet -strict-style
endif

TARGET := $(TARGET_DIR)/matrix

.PHONY : $(TARGET_DIR) run clean

$(TARGET) : main.odin matrix_mxn/matrix_mxn.odin | $(TARGET_DIR)
	odin build main.odin -file $(OPT_FLAG) -out:$@

$(TARGET_DIR) :
	@ mkdir -p $(TARGET_DIR)

run :
	@ ./$(TARGET)

clean :
	@ rm -rf bin
