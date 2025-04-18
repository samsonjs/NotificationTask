import Foundation
import Testing
@testable import NotificationTask

@MainActor class NotificationTaskTests {
    let center = NotificationCenter()
    let name = Notification.Name("a random notification")

    private var subject: NotificationTask?

    @Test func callsBlockWhenNotificationsArePosted() async throws {
        await withCheckedContinuation { [center, name] continuation in
            subject = NotificationTask(name: name, center: center) { notification in
                #expect(notification.name == name)
                continuation.resume()
            }
            Task {
                center.post(name: name, object: nil)
            }
        }
    }

    @Test func doesNotCallBlockWhenOtherNotificationsArePosted() async throws {
        subject = NotificationTask(name: name, center: center) { notification in
            Issue.record("Called for irrelevant notification \(notification.name)")
        }
        Task {
            center.post(name: Notification.Name("something else"), object: nil)
        }
        try await Task.sleep(for: .milliseconds(10))
    }

    @Test func stopsCallingBlockWhenDeallocated() async throws {
        subject = NotificationTask(name: name, center: center) { notification in
            Issue.record("Called after deallocation")
        }

        Task {
            subject = nil
            center.post(name: name, object: nil)
        }

        try await Task.sleep(for: .milliseconds(10))
    }

    class Owner {
        let deinitHook: () -> Void

        private var task: NotificationTask?

        @MainActor init(center: NotificationCenter, deinitHook: @escaping () -> Void) {
            self.deinitHook = deinitHook
            let name = Notification.Name("irrelevant name")
            self.task = NotificationTask(name: name, context: self, center: center) { _, _ in }
        }

        deinit {
            deinitHook()
        }
    }

    private var owner: Owner?

    @Test(.timeLimit(.minutes(1))) func doesNotCreateReferenceCyclesWithContext() async throws {
        await withCheckedContinuation { continuation in
            self.owner = Owner(center: center) {
                continuation.resume()
            }
            self.owner = nil
        }
    }

    @Test func stopsCallingBlockWhenContextIsDeallocated() async throws {
        var context: NSObject? = NSObject()
        subject = NotificationTask(name: name, context: context!, center: center) { context, notification in
            Issue.record("Called after context was deallocated")
        }
        context = nil
        Task {
            center.post(name: name, object: nil)
        }
        try await Task.sleep(for: .milliseconds(10))
    }
}
