import Foundation

// MARK: - Task

public final class Task   {

    /// Task description.
    let description: String

    /// Task dependencies (other tasks)
    let dependencies: [String]

    /// Task action closure.
    let action: (Utils) throws -> Void

    /// Initializes the task.
    ///
    /// - Parameters:
    ///   - description: task description.
    ///   - dependencies: task dependencies.
    ///   - action: action closure.
    init(description: String, dependencies: [String] = [], action: @escaping (Utils) throws -> Void) {
        self.description = description
        self.dependencies = dependencies
        self.action = action
    }
    
}

// MARK: - Tasks

public final class Tasks<T: RawRepresentable & CustomStringConvertible> where T.RawValue == String {
    
    /// Tasks.
    var tasks: [String: Task] = [:]
    
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
        tasks[type.rawValue] = Task(description: type.description, dependencies: dependencies.map({$0.rawValue}), action: action)
    }
    
    /// Adds a new task.
    ///
    /// - Parameter task: task to be added.
    public func task(_ type: T, task: Task) throws {
        if tasks[type.rawValue] != nil {
            throw "Trying to register task \(type.rawValue) that is already registered"
        }
        tasks[type.rawValue] = task
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
