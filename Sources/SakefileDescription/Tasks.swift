import Foundation

// MARK: - Task

public final class Task<T: RawRepresentable & CustomStringConvertible> where T.RawValue == String   {

    /// Task dependencies (other tasks)
    let dependencies: [String]

    /// Task action closure.
    let action: (Utils) throws -> Void
    
    /// Task type
    let type: T

    /// Initializes the task.
    ///
    /// - Parameters:
    ///   - type: task type.
    ///   - dependencies: task dependencies.
    ///   - action: action closure.
    public init(type: T, dependencies: [String] = [], action: @escaping (Utils) throws -> Void) {
        self.type = type
        self.dependencies = dependencies
        self.action = action
    }
    
}

// MARK: - Tasks

public final class Tasks<T: RawRepresentable & CustomStringConvertible> where T.RawValue == String {
    
    /// Tasks.
    var tasks: [String: Task<T>] = [:]
    
    /// Hooks
    var beforeAll: [(Utils) -> Void] = []
    var beforeEach: [(Utils) -> Void] = []
    var afterAll: [(Utils) -> Void] = []
    var afterEach: [(Utils) -> Void] = []

    /// Adds a new task.
    ///
    /// - Parameters:
    ///   - name: task name.
    ///   - description: task description.
    ///   - dependencies: task dependencies.
    ///   - action: task action.
    public func task(_ type: T, dependencies: [T] = [], action: @escaping (Utils) throws -> Void) throws {
        if tasks[type.rawValue] != nil {
            throw "Trying to register task \(type.rawValue) that is already registered"
        }
        tasks[type.rawValue] = Task(type: type,
                                    dependencies: dependencies.map({$0.rawValue}),
                                    action: action)
    }
    
    /// Adds a new task.
    ///
    /// - Parameter task: task to be added.
    public func task(task: Task<T>) throws {
        if tasks[task.type.rawValue] != nil {
            throw "Trying to register task \(task.type.rawValue) that is already registered"
        }
        tasks[task.type.rawValue] = task
    }
    
    /// Adds a before all hook.
    ///
    /// - Parameter closure: closure that will be executed before all the tasks.
    public func beforeAll(_ closure: @escaping (Utils) -> Void) {
        beforeAll.append(closure)
    }
    
    /// Adds a before each hook.
    ///
    /// - Parameter closure: closure that will be executed before each task.
    public func beforeEach(_ closure: @escaping (Utils) -> Void) {
        beforeEach.append(closure)
    }
    
    /// Adds an after all hook.
    ///
    /// - Parameter closure: closure that will be executed after all the tasks.
    public func afterAll(_ closure: @escaping (Utils) -> Void) {
        afterAll.append(closure)
    }
    
    /// Adds an after each hook.
    ///
    /// - Parameter closure: closure that will be executed after each task.
    public func afterEach(_ closure: @escaping (Utils) -> Void) {
        afterEach.append(closure)
    }
    
}
