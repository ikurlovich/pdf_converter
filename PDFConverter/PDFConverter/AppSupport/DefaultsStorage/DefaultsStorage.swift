import Foundation

enum DefaultsStorageKey: String {
    case isOnboardingShown = "isOnboardingShown"
    case pdfItems = "pdfItems"
}

protocol KeyValueStorage {
    func bool(forKey key: DefaultsStorageKey) -> Bool
    func integer(forKey key: DefaultsStorageKey) -> Int
    func double(forKey key: DefaultsStorageKey) -> Double
    func string(forKey key: DefaultsStorageKey) -> String?
    func date(forKey key: DefaultsStorageKey) -> Date?
    func removeObject(forKey key: DefaultsStorageKey)
    func object(forKey key: DefaultsStorageKey) -> Any?
    func entity<T: Codable>(forKey key: DefaultsStorageKey) throws -> T?
    func set(_ value: Any?, forKey key: DefaultsStorageKey)
    func set<T: Codable>(entity: T, forKey key: DefaultsStorageKey) throws
}

struct DefaultsStorage: KeyValueStorage {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }

    public func bool(forKey key: DefaultsStorageKey) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }

    public func double(forKey key: DefaultsStorageKey) -> Double {
        return defaults.double(forKey: key.rawValue)
    }

    public func integer(forKey key: DefaultsStorageKey) -> Int {
        return defaults.integer(forKey: key.rawValue)
    }

    public func string(forKey key: DefaultsStorageKey) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    public func date(forKey key: DefaultsStorageKey) -> Date? {
        return defaults.object(forKey: key.rawValue) as? Date
    }

    public func removeObject(forKey key: DefaultsStorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    public func object(forKey key: DefaultsStorageKey) -> Any? {
        return defaults.object(forKey: key.rawValue)
    }

    public func entity<T: Codable>(forKey key: DefaultsStorageKey) throws -> T? {
        guard let saved = defaults.object(forKey: key.rawValue) as? Data else { return nil }
        return try JSONDecoder().decode(T.self, from: saved)
    }

    public func set(_ value: Any?, forKey key: DefaultsStorageKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    public func set<T: Codable>(entity: T, forKey key: DefaultsStorageKey) throws {
        let encoded = try JSONEncoder().encode(entity)
        defaults.set(encoded, forKey: key.rawValue)
    }
}
