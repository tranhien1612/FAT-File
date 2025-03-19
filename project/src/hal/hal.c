/**
 * @file hal.c
 * @author Le Duc Son (sonld@hselab.com)
 * @date 2020-11-24
 * @brief HAL implementation
 */

#include "hal.h"
#include <string.h>

/**
 * Initialize HAL
 * @param hal Pointer to HAL structure
 * @param img_path Path to image file
 * @param sector_size Sector size
 * @return 0 if success, -1 if failed
 */
int hal_init(HAL* hal, const char* img_path, SectorSize sector_size) {
    if (!hal || !img_path) return -1;
    
    // Initialize IP Driver with specified sector size
    int result = ip_driver_init(&hal->ip_driver, img_path);
    if (result != 0) return -1;
    
    // Check sector size is valid (512, 1024, 2048, 4096)
    if (sector_size != SECTOR_SIZE_512 && 
        sector_size != SECTOR_SIZE_1024 && 
        sector_size != SECTOR_SIZE_2048 && 
        sector_size != SECTOR_SIZE_4096) {
        ip_driver_close(&(hal->ip_driver));
        hal->ip_driver.img_file = NULL;
        return -1;
    }
    
    hal->ip_driver.buffer_size = sector_size;
    hal->sector_size = sector_size;
    return 0;
}

/**
 * Deinitialize HAL
 * @param hal Pointer to HAL structure
 * @return 0 if success, -1 if failed
 */
int hal_deinit(HAL* hal) {
    if (!hal) return -1;
    // Close IP Driver
    ip_driver_close(&hal->ip_driver);
    return 0;
}

/**
 * Read a sector from image file
 * @param hal Pointer to HAL structure
 * @param sector_number Sector number to read
 * @param buffer Buffer to store read data
 * @return Number of bytes read if success, -1 if failed
 */
int hal_read_sector(HAL* hal, uint32_t sector_number, void* buffer) {
    if (!hal || !buffer) return -1;
    
    return ip_driver_read_sector(&hal->ip_driver, sector_number, buffer);
}

/**
 * Write a sector to image file
 * @param hal Pointer to HAL structure
 * @param sector_number Sector number to write
 * @param buffer Buffer containing data to write
 * @return Number of bytes written if success, -1 if failed
 */
int hal_write_sector(HAL* hal, uint32_t sector_number, const void* buffer) {
    if (!hal || !buffer) return -1;
    
    return ip_driver_write_sector(&hal->ip_driver, sector_number, buffer);
}

/**
 * Close HAL
 * @param hal Pointer to HAL structure
 */
void hal_close(HAL* hal) {
    if (hal) {
        ip_driver_close(&hal->ip_driver);
    }
}

/**
 * Get sector size
 * @param hal Pointer to HAL structure
 * @return Sector size
 */
uint32_t hal_get_sector_size(HAL* hal) {
    if (!hal) return 0;
    
    return (uint32_t)hal->sector_size;
}

