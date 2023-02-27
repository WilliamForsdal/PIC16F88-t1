/**
 * \file
 * Functions and types for CRC checks.
 *
 * Generated on Mon Feb 27 07:46:36 2023
 * by pycrc v0.10.0, https://pycrc.org
 * using the configuration:
 *  - Width         = 8
 *  - Poly          = 0x07
 *  - XorIn         = 0x00
 *  - ReflectIn     = False
 *  - XorOut        = 0x00
 *  - ReflectOut    = False
 *  - Algorithm     = bit-by-bit
 */
#include "crc.h"     /* include the header file generated with pycrc */
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>



crc_t crc_update(crc_t crc, const void *data, size_t data_len)
{
    const unsigned char *d = (const unsigned char *)data;
    unsigned int i;
    bool bit;
    unsigned char c;

    while (data_len--) {
        c = *d++;
        for (i = 0; i < 8; i++) {
            bit = crc & 0x80;
            crc = (crc << 1) | ((c >> (7 - i)) & 0x01);
            if (bit) {
                crc ^= 0x07;
            }
        }
        crc &= 0xff;
    }
    return crc & 0xff;
}


crc_t crc_finalize(crc_t crc)
{
    unsigned int i;
    bool bit;

    for (i = 0; i < 8; i++) {
        bit = crc & 0x80;
        crc <<= 1;
        if (bit) {
            crc ^= 0x07;
        }
    }
    return crc & 0xff;
}
