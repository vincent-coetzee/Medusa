//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation

public struct Medusa
    {
    public static let kMedusaServiceType = "_medusa._tcp."
    public static let kHostName = Host.current().localizedName!
    public static let kPrimaryServicePort: Int32 = 52000
    public static let kDefaultBufferSize: Int = 4096
    public static let kSocketReadBufferSize = 16 * 1024
    
    public static var timeInMicroseconds: Integer64
        {
        var time:timeval = timeval()
        time.tv_sec = 0
        time.tv_usec = 0
        gettimeofday(&time,nil)
        let micros = time.tv_sec * 1_000_000 + Int(time.tv_usec)
        return(micros)
        }
    
    public static var memoryUsedInProcessInBytes: Integer64?
        {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        guard let offset = MemoryLayout.offset(of: \task_vm_info_data_t.min_address) else
            {
            return(nil)
            }
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(offset / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info)
            {
            infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count))
                {
                intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
                }
            }
        guard kr == KERN_SUCCESS, count >= TASK_VM_INFO_REV1_COUNT else
            {
            return(nil)
            }
        return(Integer64(info.phys_footprint))
        }
    }
