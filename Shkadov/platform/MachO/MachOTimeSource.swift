//
//  MachTimeSource.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

import MachO

public final class MachOTimeSource : TimeSource {
    fileprivate let timeBaseNumerator: TimeType
    fileprivate let timeBaseDenominator: TimeType
    
    public init() {
        var timeBaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeBaseInfo)
        self.timeBaseNumerator = TimeType(timeBaseInfo.numer)
        self.timeBaseDenominator = TimeType(timeBaseInfo.denom)
    }
    
    public var currentTime: Time {
        return Time(nanoseconds: mach_absolute_time() * timeBaseNumerator / timeBaseDenominator)
    }
}
