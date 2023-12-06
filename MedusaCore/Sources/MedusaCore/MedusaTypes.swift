//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 05/12/2023.
//

import Foundation

public struct Medusa
    {
    //
    // Types defined by Medusa
    //
    public typealias            Address = Medusa.Unsigned64
    public typealias               Atom = Medusa.Integer64
    public typealias            Boolean = Swift.Bool
    public typealias               Byte = Swift.UInt8
    public typealias           Checksum = Medusa.Unsigned64
//    public typealias Enumeration = MOPEnumeration
    public typealias            Float64 = Swift.Double
    public typealias            Float32 = Swift.Float
    public typealias            Float16 = Swift.Int16
    public typealias             Header = MedusaCore.Header
    public typealias          Integer64 = Swift.Int                 // We keep Integer64 defined as Int rather than Int64 for ease of use since Swift uses Int as the deafult type for integer values,ideally it should be Int64 not Int.
    public typealias          Integer32 = Swift.Int32
    public typealias          Integer16 = Swift.Int16
    public typealias        MagicNumber = Medusa.Unsigned64
    public typealias           ObjectID = Medusa.Integer64
    public typealias      ObjectPointer = Medusa.Unsigned64
    public typealias         RawPointer = UnsafeMutableRawPointer
    public typealias             String = Swift.String
    public typealias      UnicodeScalar = Unicode.Scalar
    public typealias         Unsigned64 = UInt64
    public typealias         Unsigned32 = UInt32
    public typealias         Unsigned16 = UInt16
    public typealias               Word = Medusa.Unsigned64
    }

public typealias                Address = Medusa.Address
public typealias                   Atom = Medusa.Atom
public typealias                Boolean = Medusa.Boolean
public typealias                   Byte = Medusa.Byte
public typealias               Checksum = Medusa.Checksum
public typealias                Float64 = Medusa.Float64
public typealias                Float32 = Medusa.Float32
public typealias                Float16 = Medusa.Float16
public typealias              Integer64 = Medusa.Integer64
public typealias              Integer32 = Medusa.Integer32
public typealias              Integer16 = Medusa.Integer16
public typealias            MagicNumber = Medusa.MagicNumber
public typealias               ObjectID = Medusa.ObjectID
public typealias             RawPointer = Medusa.RawPointer
public typealias                 String = Medusa.String
public typealias          UnicodeScalar = Medusa.UnicodeScalar
public typealias             Unsigned64 = Medusa.Unsigned64
public typealias             Unsigned32 = Medusa.Unsigned32
public typealias             Unsigned16 = Medusa.Unsigned16
public typealias                   Word = Medusa.Word


