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

