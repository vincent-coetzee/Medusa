//
//  MedusaStorage.c
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

#include <MedusaStorage.h>

void writeInteger64(void* buffer,const long data,long offset)
    {
    char* pointer = ((char*)buffer) + offset;
    *((long*)pointer) = data;
    }
    
void writeInteger64WithOffset(void* buffer,const long data,long* offset)
    {
    char* pointer = ((char*)buffer) + *offset;
    *((long*)pointer) = data;
    *offset += sizeof(long);
    }
    
void writeFloat64WithOffset(void* buffer,const double data,long* offset)
    {
    char* pointer = ((char*)buffer) + *offset;
    *((double*)pointer) = data;
    *offset += sizeof(double);
    }
    
void writeUnsigned64WithOffset(void* buffer,const uint64_t data,long* offset)
    {
    char* pointer = ((char*)buffer) + *offset;
    *((uint64_t*)pointer) = data;
    *offset += sizeof(uint64_t);
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
    
void writeBooleanWithOffset(void* buffer,const _Bool data,long* offset)
    {
    *((_Bool *)((char*)buffer + *offset)) = data;
    *offset += sizeof(_Bool);
    }
    
void writeBoolean(void* buffer,const _Bool data,long offset)
    {
    *((_Bool *)((char*)buffer + offset)) = data;
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
    
void writeFloat64(void* buffer,const double data,long offset)
    {
    *((double *)((char*)buffer + offset)) = data;
    }

long readInteger64(void* buffer,long offset)
    {
    long* from = (long*)(((char*)buffer) + offset);
    return(*from);
    }
    
int32_t readInteger32(void* buffer,long offset)
    {
    int32_t* from = (int32_t*)(((char*)buffer) + offset);
    return(*from);
    }
    
int16_t readInteger16(void* buffer,long offset)
    {
    int16_t* from = (int16_t*)(((char*)buffer) + offset);
    return(*from);
    }
    
double readFloat64(void* buffer,long offset)
    {
    double* from = (double*)(((char*)buffer) + offset);
    return(*from);
    }
    
uint64_t readUnsigned64(void* buffer,long offset)
    {
    uint64_t* from = (uint64_t*)(((char*)buffer) + offset);
    return(*from);
    }
    
uint32_t readUnsigned32(void* buffer,long offset)
    {
    uint32_t* from = (uint32_t*)(((char*)buffer) + offset);
    return(*from);
    }
    
uint16_t readUnsigned16(void* buffer,long offset)
    {
    uint16_t* from = (uint16_t*)(((char*)buffer) + offset);
    return(*from);
    }
long readInteger64WithOffset(void* buffer,long* offset)
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
    
_Bool readBooleanWithOffset(void* buffer,long* offset)
    {
    _Bool byte = *((_Bool *)((char*)buffer + *offset));
    *offset += sizeof(_Bool);
    return(byte);
    }
    
_Bool readBoolean(void* buffer,long offset)
    {
    return(*((_Bool *)((char*)buffer + offset)));
    }

//void writeObjectAddress(void* buffer,const ObjectAddress address,long offset)
//    {
//    *((uint64_t*)((char*)buffer + offset)) = address.address;
//    }
//    
//void writeObjectAddressWithOffset(void* buffer,const ObjectAddress address,long* offset)
//    {
//    *((uint64_t *)((char*)buffer + *offset)) = address.address;
//    *offset += sizeof(uint64_t);
//    }
    
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
    
//ObjectAddress readObjectAddress(void *buffer,long offset)
//    {
//    ObjectAddress address;
//    
//    address.address = *((uint64_t*)(((char*)buffer) + offset));
//    return(address);
//    }
//    
//ObjectAddress readObjectAddressWithOffset(void *buffer,long* offset)
//    {
//    ObjectAddress address;
//    
//    address.address = *((uint64_t*)(((char*)buffer) + *offset));
//    offset += sizeof(uint64_t);
//    return(address);
//    }
