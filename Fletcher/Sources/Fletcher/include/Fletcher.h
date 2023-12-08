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

//
//
// Fletcher's checksum algorithms implemented for 32 and 64 bits
//
uint32_t fletcher32(const uint16_t *data, size_t len);
uint64_t fletcher64(const uint32_t *data, size_t len);
    
#endif /* Fletcher_h */
