//
//  Fletcher32.h
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

#ifndef Fletcher_h
#define Fletcher_h

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

uint32_t fletcher32(const uint16_t *data, size_t len);
uint64_t fletcher64(const uint32_t *data, size_t len);

void writeInteger(void* buffer,const long data,long offset);
void writeIntegerWithOffset(void* buffer,const long data,long* offset);
void writeByteWithOffset(void* buffer,uint8_t data,long* offset);
void writeByte(void* buffer,uint8_t data,long offset);
void writeUnicodeScalarWithOffset(void* buffer,void* data,long* offset);
void writeUnsigned64(void* buffer,const uint64_t data,long offset);
long readInteger(void* buffer,long offset);
int32_t readInteger32(void* buffer,long offset);
int16_t readInteger16(void* buffer,long offset);
double readFloat(void* buffer,long offset);
unsigned long readUnsigned(void* buffer,long offset);
uint32_t readUnsigned32(void* buffer,long offset);
uint16_t readUnsigned16(void* buffer,long offset);
long readIntegerWithOffset(void* buffer,long* offset);
void readUnicodeScalarWithOffset(void* buffer,void* pointer,long* offset);
uint8_t readByteWithOffset(void* buffer,long* offset);
uint8_t readByte(void* buffer,long offset);
uint64_t readUnsigned64(void* buffer,long offset);

#endif /* Fletcher_h */
