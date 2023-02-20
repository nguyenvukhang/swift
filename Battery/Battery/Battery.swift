//
// Battery.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import IOKit
import Foundation

/**
Battery statistics for OS X, read-only.

http://www.apple.com/batteries/

TODO: None of this will work for iOS as I/O Kit is a private framework there
*/
public struct Battery {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /// Temperature units
    public enum TemperatureUnit {
        case celsius
        case fahrenheit
        case kelvin
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE ENUMS
    //--------------------------------------------------------------------------
    
    
    /// Battery property keys. Sourced via 'ioreg -brc AppleSmartBattery'
    fileprivate enum Key: String {
        case ACPowered        = "ExternalConnected"
        case Amperage         = "Amperage"
        /// Current charge
        case CurrentCapacity  = "CurrentCapacity"
        case CycleCount       = "CycleCount"
        /// Originally DesignCapacity == MaxCapacity
        case DesignCapacity   = "DesignCapacity"
        case DesignCycleCount = "DesignCycleCount9C"
        case FullyCharged     = "FullyCharged"
        case IsCharging       = "IsCharging"
        /// Current max charge (this degrades over time)
        case MaxCapacity      = "MaxCapacity"
        case Temperature      = "Temperature"
        /// Time remaining to charge/discharge
        case TimeRemaining    = "TimeRemaining"
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /// Name of the battery IOService as seen in the IORegistry
    fileprivate static let IOSERVICE_BATTERY = "AppleSmartBattery"
    
    
    fileprivate var service: io_service_t = 0
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() { }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - BATTERY
    //--------------------------------------------------------------------------
    

    public mutating func open() -> kern_return_t {
       if (service != 0) {
           #if DEBUG
               print("WARNING - \(#file):\(#function) - " +
                       "\(Battery.IOSERVICE_BATTERY) connection already open")
           #endif
           return kIOReturnStillOpen
       }
       
       
       // TODO: Could there be more than one service? serveral batteries?
       service = IOServiceGetMatchingService(kIOMainPortDefault,
                 IOServiceNameMatching(Battery.IOSERVICE_BATTERY))
       
       if (service == 0) {
           #if DEBUG
               print("ERROR - \(#file):\(#function) - " +
                       "\(Battery.IOSERVICE_BATTERY) service not found")
           #endif
           return kIOReturnNotFound
       }
       
       return kIOReturnSuccess
   }
       
       
       public mutating func close() -> kern_return_t {
           let result = IOObjectRelease(service)
           service    = 0     // Reset this incase open() is called again
           
           #if DEBUG
               if (result != kIOReturnSuccess) {
                   print("ERROR - \(#file):\(#function) - Failed to close")
               }
           #endif
           
           return result
       }
       
    
    public func currentCapacity() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.CurrentCapacity.rawValue as CFString?,
                                                   kCFAllocatorDefault,0)
        return prop!.takeUnretainedValue() as! Int
    }
    
    
    public func maxCapactiy() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.MaxCapacity.rawValue as CFString?,
                                                   kCFAllocatorDefault, 0)
        return prop!.takeUnretainedValue() as! Int
    }
    
    
    public func isACPowered() -> Bool {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.ACPowered.rawValue as CFString?,
                                                   kCFAllocatorDefault, 0)
        return prop!.takeUnretainedValue() as! Bool
    }
    

    public func isCharging() -> Bool {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.IsCharging.rawValue as CFString?,
                                                   kCFAllocatorDefault, 0)
        return prop!.takeUnretainedValue() as! Bool
    }
    
    
    public func isCharged() -> Bool {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.FullyCharged.rawValue as CFString?,
                                                   kCFAllocatorDefault, 0)
        return prop!.takeUnretainedValue() as! Bool
    }
    
    
    public func charge() -> Int {
        return Int(floor(Double(currentCapacity()) / Double(maxCapactiy()) * 100.0))
    }

}
