//
//  SpinLock.swift
//  HexMatch
//
//  Originally by Wade Tregaskis, from comment on https://www.mikeash.com/pyblog/friday-qa-2015-02-06-locks-thread-safety-and-swift.html
//  Modified by Josh McKee
//

import Foundation

class Spinlock { 
    private var _lock : OSSpinLock = OS_SPINLOCK_INIT 

    func around(code: Void -> Void) { 
        OSSpinLockLock(&self._lock) 
        defer {
            OSSpinLockUnlock(&self._lock)
        }
        code()
    } 

    func around<T>(code: Void -> T) -> T { 
        OSSpinLockLock(&self._lock)
        defer {
            OSSpinLockUnlock(&self._lock)
        }
        return code()
    } 
}