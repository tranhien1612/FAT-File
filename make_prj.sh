#!/bin/bash

# Danh sách các thư mục cần thiết
required_dirs=(
    "project"
    "project/src"
    "project/src/ip_driver"
    "project/src/hal"
    "project/src/fat_driver"
    "project/src/middleware"
    "project/src/application"
    "project/src/utilities"
    "project/src/utilities/log"
    "project/src/utilities/linkedlist"
    "project/src/common"
    "project/obj"
    "project/bin"
)

echo "=== Tạo cấu trúc dự án FAT File System Manager ==="

# Tạo các thư mục
echo "1. Tạo cấu trúc thư mục..."
for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "  + Tạo: $dir"
        mkdir -p "$dir"
    else
        echo "  * Đã tồn tại: $dir"
    fi
done

# Tạo các file trong ip_driver
echo "2. Tạo files cho IP Driver..."
cat > project/src/ip_driver/ip_driver.h << 'EOF'
#ifndef IP_DRIVER_H
#define IP_DRIVER_H

#include <stdio.h>
#include <stdint.h>
#include "../common/common_types.h"

typedef struct {
    FILE* img_file;
    uint32_t sector_size;
} IPDriver;

int ip_driver_init(IPDriver* driver, const char* img_path);
int ip_driver_read_sector(IPDriver* driver, uint32_t sector_number, void* buffer);
int ip_driver_write_sector(IPDriver* driver, uint32_t sector_number, const void* buffer);
void ip_driver_close(IPDriver* driver);

#endif
EOF

cat > project/src/ip_driver/ip_driver.c << 'EOF'
#include "ip_driver.h"
#include "ip_driver_private.h"
#include <string.h>

int ip_driver_init(IPDriver* driver, const char* img_path) {
    if (!driver || !img_path) return -1;
    
    const char* ext = strrchr(img_path, '.');
    if (!ext || strcmp(ext, ".img") != 0) return -1;
    
    driver->img_file = fopen(img_path, "rb+");
    if (!driver->img_file) return -1;
    
    driver->sector_size = 512;
    return 0;
}

int ip_driver_read_sector(IPDriver* driver, uint32_t sector_number, void* buffer) {
    if (!driver || !driver->img_file || !buffer) return -1;
    
    fseek(driver->img_file, sector_number * driver->sector_size, SEEK_SET);
    return fread(buffer, 1, driver->sector_size, driver->img_file);
}

int ip_driver_write_sector(IPDriver* driver, uint32_t sector_number, const void* buffer) {
    if (!driver || !driver->img_file || !buffer) return -1;
    
    fseek(driver->img_file, sector_number * driver->sector_size, SEEK_SET);
    return fwrite(buffer, 1, driver->sector_size, driver->img_file);
}

void ip_driver_close(IPDriver* driver) {
    if (driver && driver->img_file) {
        fclose(driver->img_file);
        driver->img_file = NULL;
    }
}
EOF

# Tạo các file trong hal
echo "3. Tạo files cho HAL..."
touch project/src/hal/hal.h
touch project/src/hal/hal.c

# Tạo các file trong fat_driver
echo "4. Tạo files cho FAT Driver..."
touch project/src/fat_driver/fat_driver.h
touch project/src/fat_driver/fat_driver.c
touch project/src/fat_driver/fat_driver_private.h
touch project/src/fat_driver/fat_driver_types.h
touch project/src/fat_driver/README.md

# Tạo các file trong middleware
echo "5. Tạo files cho Middleware..."
touch project/src/middleware/middleware.h
touch project/src/middleware/middleware.c

# Tạo các file trong application
echo "6. Tạo files cho Application..."
touch project/src/application/application.h
touch project/src/application/application.c

# Tạo các file trong utilities
echo "7. Tạo files cho Utilities..."
# Log module
touch project/src/utilities/log/print_color.h
touch project/src/utilities/log/print_color.c
# Linkedlist module
touch project/src/utilities/linkedlist/linkedlist.h
touch project/src/utilities/linkedlist/linkedlist.c

# Tạo các file trong common
echo "8. Tạo files cho Common..."
touch project/src/common/common_types.h

# Tạo Makefile
echo "9. Tạo Makefile..."
cat > project/Makefile << 'EOF'
# Compiler và flags
CC = gcc
CFLAGS = -Wall -Wextra -I./src
LDFLAGS = 

# Thư mục
SRC_DIR = src
OBJ_DIR = build/obj
BIN_DIR = build/bin
DEP_DIR = build/dep

# Danh sách các source files
SRCS = $(wildcard $(SRC_DIR)/*.c) \
       $(wildcard $(SRC_DIR)/ip_driver/*.c) \
       $(wildcard $(SRC_DIR)/hal/*.c) \
       $(wildcard $(SRC_DIR)/fat_driver/*.c) \
       $(wildcard $(SRC_DIR)/middleware/*.c) \
       $(wildcard $(SRC_DIR)/application/*.c) \
       $(wildcard $(SRC_DIR)/utilities/log/*.c) \
       $(wildcard $(SRC_DIR)/utilities/linkedlist/*.c)

# Chuyển .c thành .o và .d
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
DEPS = $(SRCS:$(SRC_DIR)/%.c=$(DEP_DIR)/%.d)

# Tên executable
TARGET = $(BIN_DIR)/fat_filesystem

# Phần build chính
all: directories $(TARGET)

# Tạo thư mục cần thiết
directories:
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(OBJ_DIR)/ip_driver
	@mkdir -p $(OBJ_DIR)/hal
	@mkdir -p $(OBJ_DIR)/fat_driver
	@mkdir -p $(OBJ_DIR)/middleware
	@mkdir -p $(OBJ_DIR)/application
	@mkdir -p $(OBJ_DIR)/utilities/log
	@mkdir -p $(OBJ_DIR)/utilities/linkedlist
	@mkdir -p $(DEP_DIR)/ip_driver
	@mkdir -p $(DEP_DIR)/hal
	@mkdir -p $(DEP_DIR)/fat_driver
	@mkdir -p $(DEP_DIR)/middleware
	@mkdir -p $(DEP_DIR)/application
	@mkdir -p $(DEP_DIR)/utilities/log
	@mkdir -p $(DEP_DIR)/utilities/linkedlist

# Link các object files thành executable
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)

# Compile các source files thành object files và tạo dependency files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@mkdir -p $(dir $(DEP_DIR)/$*.d)
	$(CC) $(CFLAGS) -MMD -MP -MF $(DEP_DIR)/$*.d -c $< -o $@

# Include dependency files
-include $(DEPS)

# Clean
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) $(DEP_DIR)

# Rebuild
rebuild: clean all

.PHONY: all clean rebuild directories
EOF

# Tạo README
echo "10. Tạo README..."
cat > project/README.md << 'EOF'
# FAT File System Manager

## Cấu trúc dự án
EOF

echo "=== Hoàn thành tạo cấu trúc dự án ==="
echo "Cấu trúc thư mục:"
tree project/

echo "
Lưu ý:
1. Các file header (.h) và source (.c) đã được tạo
2. Cần thêm nội dung cho các file
3. Cập nhật Makefile để build dự án
4. Xem README.md để biết thêm chi tiết"

# Cấp quyền thực thi cho script
chmod +x standardize.sh

# 2. Chạy script để tạo cấu trúc project
./standardize.sh

# 3. Build project
make clean     # Xóa các file build cũ
make all       # Build toàn bộ project
make rebuild   # Rebuild toàn bộ project

# 4. Kiểm tra kết quả build
ls -l bin/fat_filesystem

# Cấp quyền thực thi cho các file trong thư mục src
chmod -R 755 src/

./bin/fat_filesystem <đường_dẫn_tới_file_img>
