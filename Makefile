ifdef DEBUG
	TARGET_DIR := bin/debug
	OPT_FLAG := -debug
	GDB := gdb
else
	TARGET_DIR := bin/release
	OPT_FLAG := -o:speed
	GDB:=
endif

TARGET   := $(TARGET_DIR)/matrix
PACKAGES := $(shell find -mindepth 2 -name "*.odin")

.PHONY : all run clean

all: $(TARGET)

$(TARGET) : main.odin $(PACKAGES) | $(TARGET_DIR)
	odin build main.odin -file $(OPT_FLAG) -out:$@

$(TARGET_DIR) :
	@mkdir -p $(TARGET_DIR)

run :
	@$(GDB) ./$(TARGET)

clean :
	@rm -rf bin
