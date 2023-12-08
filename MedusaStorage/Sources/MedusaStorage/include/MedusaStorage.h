//
//  Header.h
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

#ifndef MedusaStorage_h
#define MedusaStorage_h

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

//
// An ObjectAddress is used by Medusa to store and ferry around addresses
// that point to an object. They are defined here but have extra functionality
// added in the MedusaObjectModel module.
//

typedef struct _ObjectAddress
    {
    uint64_t       address;
    }
    ObjectAddress;
    
//
// Functions for reading primitive Medusa datatypes
//
_Bool readBoolean(void* buffer,long offset);
_Bool readBooleanWithOffset(void* buffer,long* offset);
uint8_t readByte(void* buffer,long offset);
uint8_t readByteWithOffset(void* buffer,long* offset);
double readFloat64(void* buffer,long offset);
long readInteger64(void* buffer,long offset);
long readInteger64WithOffset(void* buffer,long* offset);
int32_t readInteger32(void* buffer,long offset);
int16_t readInteger16(void* buffer,long offset);
ObjectAddress readObjectAddress(void *buffer,long offset);
ObjectAddress readObjectAddressWithOffset(void *buffer,long* offset);
void readUnicodeScalarWithOffset(void* buffer,void* pointer,long* offset);
uint64_t readUnsigned64(void* buffer,long offset);
uint32_t readUnsigned32(void* buffer,long offset);
uint16_t readUnsigned16(void* buffer,long offset);
//
// Functions to write primitive Medusa datatypes
//
void writeBoolean(void* buffer,const _Bool data,long offset);
void writeBooleanWithOffset(void* buffer,_Bool data,long* offset);
void writeByte(void* buffer,const uint8_t data,long offset);
void writeByteWithOffset(void* buffer,uint8_t data,long* offset);
void writeFloat64(void* buffer,const double data,long offset);
void writeFloat64WithOffset(void* buffer,const double data,long* offset);
void writeInteger64(void* buffer,const long data,long offset);
void writeInteger64WithOffset(void* buffer,const long data,long* offset);
void writeObjectAddress(void* buffer,const ObjectAddress address,long offset);
void writeObjectAddressWithOffset(void* buffer,const ObjectAddress address,long* offset);
void writeUnsigned64(void* buffer,const uint64_t data,long offset);
void writeUnsigned64WithOffset(void* buffer,const uint64_t data,long* offset);
void writeUnicodeScalarWithOffset(void* buffer,void* data,long* offset);


#endif /* Header_h */
