////
////  MOPAddress.swift
////  Medusa
////
////  Created by Vincent Coetzee on 04/12/2023.
////
//
//import Foundation
//
////
//// A pointer in Medusa terms is the address of the page that contains an object
//// or'ed with the offset of the object within the page. Remember that because the
//// data file for the database has been mmapped into memory, all these addresses
//// are actually memory addresses not only disk addresses. The data file is mapped into memory
//// at 0x0x4000000000000000 but Medusa page addresses only start at 0x4000000000000000
//// which means there is a one to one correspondence between the address of an object on disk
//// and its address in memory. The page base address can have a value between
//// 16,384 ( 0x4000 ) and 
////
//public struct MOMPointer
//    {
//    private let _base: Unsigned64
//    private let _offset: Unsigned64
//    
//    public var base: Integer64
//        {
//        Integer64(self._base)
//        }
//
//    public var offset: Integer64
//        {
//        Integer64(self._offset)
//        }
//        
//    
//    public var address: Address
//        {
//        Integer64(bitPattern: Unsigned64(self._base) | Unsigned64(self.offset))
//        }
//
//    public init(address: Address)
//        {
//        self._base = Unsigned64(bitPattern: address) & Unsigned64(bitPattern: Medusa.kPointerBaseMask)
//        self._offset = Unsigned64(bitPattern: address) & Unsigned64(bitPattern: Medusa.kPointerOffsetMask)
//        }
//    }
