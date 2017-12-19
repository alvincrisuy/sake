import Foundation

// MARK: - Utils

public class Utils {}

// MARK: - Sake

public final class Sake<T: RawRepresentable & CustomStringConvertible> where T.RawValue == String {
    
    fileprivate let utils: Utils = Utils()
    fileprivate let tasks: Tasks<T> = Tasks<T>()
    fileprivate let tasksInitializer: (Tasks<T>) throws -> Void
    fileprivate let printer: (String) -> Void
    
    public init(tasksInitializer: @escaping (Tasks<T>) throws -> Void) {
        self.tasksInitializer = tasksInitializer
        self.printer = { print($0) }
    }
    
    init(printer: @escaping (String) -> Void,
         tasksInitializer: @escaping (Tasks<T>) throws -> Void) {
        self.tasksInitializer = tasksInitializer
        self.printer = printer
    }
    
}

// MARK: - Sake (Runner)

public extension Sake {
    
    public func run() {
        var arguments = CommandLine.arguments
        arguments.remove(at: 0)
        run(arguments: arguments)
    }
    
    func run(arguments: [String]) {
        do {
            try tasksInitializer(tasks)
        } catch {
            printer("> Error initializing tasks: \(error)")
            return
        }
        guard let argument = arguments.first else {
            printer("> Error: Missing argument")
            exit(1)
        }
        if argument == "tasks" {
            printTasks()
        } else if argument == "task" {
            if arguments.count != 2 {
                printer("> Error: Missing task name")
                exit(1)
            }
            do {
                try runTaskAndDependencies(task: arguments[1])
            } catch {
                printer("> Error: \(error)")
                exit(1)
            }
        } else {
            printer("> Error: Invalid argument")
            exit(1)
        }
    }
    
    // MARK: - Fileprivate
    
    fileprivate func printTasks() {
        printer(self.tasks.tasks
            .map({"\($0.key):      \($0.value.type.description)"})
            .joined(separator: "\n"))
    }
    
    fileprivate func runTaskAndDependencies(task taskName: String) throws {
        guard let task = tasks.tasks.first(where: {$0.key == taskName}).map({$0.value}) else {
            return
        }
        tasks.beforeAll.forEach({ $0(utils) })
        defer { tasks.afterAll.forEach({ $0(utils) }) }
        try task.dependencies.forEach { try runTask(task: $0) }
        try runTask(task: taskName)
    }
    
    fileprivate func runTask(task: String) throws {
        guard let task = tasks.tasks.first(where: {$0.key == task}) else {
            return
        }
        printer("> Running \"\(task.key)\"")
        tasks.beforeEach.forEach({$0(utils)})
        try task.value.action(self.utils)
        tasks.afterEach.forEach({$0(utils)})
    }
    
}

