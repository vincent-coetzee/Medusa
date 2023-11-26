//
//  Fletcher32.c
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

#include "Fletcher.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

uint32_t fletcher32(const uint16_t *data, size_t len)
    {
	uint32_t c0, c1;
	len = (len + 1) & ~1;      /* Round up len to words */

	/* We similarly solve for n > 0 and n * (n+1) / 2 * (2^16-1) < (2^32-1) here. */
	/* On modern computers, using a 64-bit c0/c1 could allow a group size of 23726746. */
	for (c0 = c1 = 0; len > 0; )
        {
		size_t blocklen = len;
		if (blocklen > 360*2)
            {
			blocklen = 360*2;
            }
		len -= blocklen;
		do
            {
			c0 = c0 + *data++;
			c1 = c1 + c0;
            }
        while ((blocklen -= 2));
		c0 = c0 % 65535;
		c1 = c1 % 65535;
        }
	return (c1 << 16 | c0);
    }
    
uint64_t fletcher64(const uint32_t *data, size_t len)
    {
	uint64_t c0, c1;
	len = (len + 1) & ~1;      /* Round up len to words */

	/* We similarly solve for n > 0 and n * (n+1) / 2 * (2^16-1) < (2^32-1) here. */
	/* On modern computers, using a 64-bit c0/c1 could allow a group size of 23726746. */
	for (c0 = c1 = 0; len > 0; )
        {
		size_t blocklen = len;
		if (blocklen > 360*2)
            {
			blocklen = 360*2;
            }
		len -= blocklen;
		do
            {
			c0 = c0 + *data++;
			c1 = c1 + c0;
            }
        while ((blocklen -= 2));
		c0 = c0 % 4294967295;
		c1 = c1 % 4294967295;
        }
	return (c1 << 32 | c0);
    }

void writeInteger(void* buffer,const long data,long offset)
    {
    char* pointer = ((char*)buffer) + offset;
    *((long*)pointer) = data;
    }
    
void writeIntegerWithOffset(void* buffer,const long data,long* offset)
    {
    char* pointer = ((char*)buffer) + *offset;
    *((long*)pointer) = data;
    *offset += sizeof(long);
    }
    
void writeByteWithOffset(void* buffer,uint8_t data,long* offset)
    {
    *((uint8_t *)((char*)buffer + *offset)) = data;
    *offset += sizeof(uint8_t);
    }
    
void writeByte(void* buffer,uint8_t data,long offset)
    {
    *((uint8_t *)((char*)buffer + offset)) = data;
    }
    
void writeUnicodeScalarWithOffset(void* buffer,void* data,long* offset)
    {
    char* to = ((char*)buffer) + *offset;
    char* from = (char*)data;
    *to++ = *from++;
    *to++ = *from++;
    *to++ = *from++;
    *to++ = *from++;
    *offset += 4;
    }
    
void writeUnsigned64(void* buffer,const uint64_t data,long offset)
    {
    *((unsigned long *)((char*)buffer + offset)) = data;
    }

long readInteger(void* buffer,long offset)
    {
    long* from = (long*)(((char*)buffer) + offset);
    return(*from);
    }
    
long readIntegerWithOffset(void* buffer,long* offset)
    {
    long* from = (long*)(((char*)buffer) + *offset);
    *offset += sizeof(long);
    return(*from);
    }
    
uint8_t readByteWithOffset(void* buffer,long* offset)
    {
    uint8_t byte = *((uint8_t *)((char*)buffer + *offset));
    *offset += 1;
    return(byte);
    }
    
uint8_t readByte(void* buffer,long offset)
    {
    return(*((uint8_t *)((char*)buffer + offset)));
    }
    
void readUnicodeScalarWithOffset(void* buffer,void* pointer,long* offset)
    {
    char* from = ((char*)buffer) + *offset;
    char* to = (char*)pointer;
    *to++ = *from++;
    *to++ = *from++;
    *to++ = *from++;
    *to++ = *from++;
    *offset += 4;
    }
    
uint64_t readUnsigned64(void* buffer,long offset)
    {
    return(*((uint64_t *)((char*)buffer + offset)));
    }
