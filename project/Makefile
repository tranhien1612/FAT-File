# Makefile cho FAT File System Project
# Author: Ducson9112k

#------------------
# Tên project
#------------------
PROJECT_NAME := application

#------------------
# Công cụ build
#------------------
# Phát hiện hệ điều hành
ifeq ($(OS),Windows_NT)
    # Windows
    CC := C:/cygwin64/bin/gcc.exe
    # Các cài đặt Windows khác...
else
    # Linux/Unix
    CC := /mnt/c/cygwin64/bin/gcc.exe
    # Các cài đặt Linux khác...
endif

RM        := rm -rf
MKDIR     := mkdir -p

#------------------
# Thư mục
#------------------
ROOT_DIR  := .
SRC_DIR   := $(ROOT_DIR)/src
BUILD_DIR := $(ROOT_DIR)/build
OBJ_DIR   := $(BUILD_DIR)/obj
BIN_DIR   := $(BUILD_DIR)/bin
DEP_DIR   := $(BUILD_DIR)/dep
IMAGE_DIR := $(ROOT_DIR)/images
#------------------
# Các file nguồn
#------------------
# Tìm tất cả các file .c trong thư mục src và thư mục con
SRCS := $(shell find $(SRC_DIR) -type f -name "*.c")

# Tạo danh sách file object tương ứng
OBJS := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

# Tạo danh sách file dependency
DEPS := $(SRCS:$(SRC_DIR)/%.c=$(DEP_DIR)/%.d)

#------------------
# Cờ biên dịch
#------------------
# Include paths
INC_DIRS := $(SRC_DIR) \
            $(SRC_DIR)/common \
            $(SRC_DIR)/ip_driver \
            $(SRC_DIR)/hal \
            $(SRC_DIR)/fat_driver \
            $(SRC_DIR)/middleware \
            $(SRC_DIR)/application \
            $(SRC_DIR)/utilities/linkedlist \
            $(SRC_DIR)/utilities/log

# Convert include directories to -I flags
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# Basic flags
CFLAGS := -Wall -Wextra -Werror \
          -Wno-unused-parameter \
          -Wno-unused-variable \
          -Wno-unused-function \
          -Wno-maybe-uninitialized \
          -std=c11 \
          -fdiagnostics-color=always \
          -g \
          -O2 \
          -MMD -MP \
          $(INC_FLAGS)

# Linker flags
LDFLAGS := -lm -lpthread -v

# Thêm cờ debug nếu cần
ifeq ($(DEBUG), ON)
CFLAGS += -g -DDEBUG
endif

# Thêm cờ verbose nếu cần
ifeq ($(VERBOSE), ON)
CFLAGS += -v
endif

#------------------
# File đích
#------------------
TARGET := $(BIN_DIR)/$(PROJECT_NAME).exe

#------------------
# File ảnh
#------------------
IMAGE_FILES := $(wildcard $(subst \\,/,$(IMAGE_DIR))/*.img)

# Đánh số để truy cập image
IMAGE_NUM ?= 1

# Chọn file ảnh theo IMAGE_NUM tự động (hỗ trợ nhiều file)
FILE_IMAGE := $(word $(IMAGE_NUM), $(IMAGE_FILES))

$(info Using image file: $(FILE_IMAGE))

#------------------
# Chế độ
#------------------
# Chế độ mặc định
BUILD_MODE ?= release
MODE ?= read-only

#------------------
# Các target
#------------------
.PHONY: all clean run debug release help

# Target mặc định
all: release

# Build bản release (có tối ưu)
release: CFLAGS += -O2 -DNDEBUG
release: $(TARGET)
	@echo "Build release hoàn thành"

# Build bản debug
debug: CFLAGS += -g -DDEBUG
debug: $(TARGET)
	@echo "Build debug hoàn thành"

# Build file thực thi
$(TARGET): $(OBJS) | $(BIN_DIR)
	@echo "Linking $@..."
	@$(CC) $(OBJS) $(LDFLAGS) -o $@
	@echo "Build hoàn thành!"

# Compile các file nguồn
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	@echo "Compiling $<..."
	@$(MKDIR) $(dir $@)
	@$(MKDIR) $(dir $(DEP_DIR)/$*.d)
	@$(CC) $(CFLAGS) -c $< -o $@

# Tạo các thư mục cần thiết
$(BIN_DIR) $(OBJ_DIR):
	@$(MKDIR) $@

# Clean
clean:
	@echo "Cleaning..."
	@$(RM) $(BUILD_DIR)
	@echo "Clean hoàn thành!"

# Run
run: $(TARGET)
	@echo "Running $(TARGET)"
	@./$(TARGET) $(FILE_IMAGE) $(MODE)

# Print
print-%:
	@echo $* = $($*)

# Help
help:
	@echo "Các target có sẵn:"
	@echo "  all      - Build tất cả (mặc định)"
	@echo "  release  - Build bản release"
	@echo "  debug    - Build bản debug"
	@echo "  clean    - Xóa các file build"
	@echo "  run      - Chạy chương trình"
	@echo "  help     - Hiển thị help này"
	@echo "  print-%  - In giá trị của biến"

# Include dependency files
-include $(DEPS)