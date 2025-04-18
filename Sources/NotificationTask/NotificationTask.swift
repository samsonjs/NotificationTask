public import Foundation

extension Notification: @unchecked @retroactive Sendable {}

/// Manages a task that observes notifications. The tasks's lifetime is tied to the lifetime of the `NotificationTask` instance, so you
/// don't need to explicitly cancel anything. As long as you don't create a reference cycle in the given closure/block then everything will
/// work smoothly.
///
/// When you don't need to worry about reference cycles because the closure is dead simple then just pass in the notification name to
/// ``init(name:center:performing:)`` and then do your work in the closure.
///
/// In other cases you need to be more careful, and there's a second initializer that accepts a context object (typically self) and holds a
/// weak reference to it. Whenever that context object is deallocated then everything stops and is cleaned up automatically. Your closure
/// always receives a strong reference. This one is called ``init(name:context:center:performing:)``.
///
/// ``NotificationTask`` is bound to the main actor and is intended to be used in your view layer. This keeps it simple
@MainActor public final class NotificationTask {
    var task: Task<Void, Never>?

    init(task: Task<Void, Never>) {
        self.task = task
    }

    public init(
        name: Notification.Name,
        center: NotificationCenter = .default,
        performing block: @escaping (Notification) async -> Void
    ) {
        self.task = Task {
            for await notification in center.notifications(named: name) {
                await block(notification)
            }
        }
    }

    /// Manages the weak reference to your context so you don't leak by mistake.
    public init<Context: AnyObject>(
        name: Notification.Name,
        context: Context,
        center: NotificationCenter = .default,
        performing block: @escaping (Context, Notification) async -> Void
    ) {
        self.task = Task { [weak context] in
            for await notification in center.notifications(named: name) {
                guard let context else { break }
                await block(context, notification)
            }
        }
    }

    deinit {
        task?.cancel()
        task = nil
    }
}
