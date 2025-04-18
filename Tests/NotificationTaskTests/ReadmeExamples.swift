import Foundation
@testable import NotificationTask

@MainActor class SimplestVersion {
    let task = NotificationTask(name: .NSCalendarDayChanged) { _ in
        print("The date is now \(Date.now)")
    }
}

@MainActor class WithContext {
    var notificationTask: NotificationTask?

    init() {
        notificationTask = NotificationTask(name: .NSCalendarDayChanged, context: self) { _self, _ in
            _self.dayChanged()
        }
    }

    func dayChanged() {
        print("The date is now \(Date.now)")
    }
}
