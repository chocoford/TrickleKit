//
//  Streamable.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/1/29.
//

import Foundation

public struct AnyStreamable<T: Codable>: Codable {
    public var items: [T]
    public let nextTs: Int?
    
    public init() {
        self.items = []
        self.nextTs = Int(Date.now.timeIntervalSince1970)
    }
    
    public init(items: [T], nextTs: Int?) {
        self.items = items
        self.nextTs = nextTs
    }
    
    public func appending(_ contentsOf: Self) -> Self where T: Hashable {
        let items = self.items + contentsOf.items
        return .init(items: items.removingDuplicate(), nextTs: contentsOf.nextTs)
    }
    public func prepending(_ contentsOf: Self) -> Self where T: Hashable {
        let items = contentsOf.items + self.items
        return .init(items: items.removingDuplicate(), nextTs: self.nextTs)
    }
    
    public func map<V>(_ transform: (T) -> V) -> AnyStreamable<V> {
        .init(items: items.map{ transform($0) }, nextTs: nextTs)
    }
    public func compactMap<V>(_ transform: (T) -> V?) -> AnyStreamable<V> {
        .init(items: items.compactMap{ transform($0) }, nextTs: nextTs)
    }
    
    public mutating func updateItem(_ item: T) where T: Identifiable {
        guard let index = self.items.firstIndex(where: {
            $0.id == item.id
        }) else { return }
        self.items[index] = item
    }
    
    public func updatingItem(_ item: T) -> Self where T: Identifiable {
        return .init(items: items.updatingItem(item), nextTs: self.nextTs)
    }
    public func updatingItem(from item: T, to newItem: T) -> Self where T: Hashable {
        return .init(items: items.updatingItem(from: item, to: newItem), nextTs: self.nextTs)
    }
    public func removingItem(_ item: T) -> Self where T: Hashable {
        return .init(items: items.removingItem(of: item), nextTs: self.nextTs)
    }
}

public struct AnyQueryStreamable<T: Codable>: Codable {
    public var items: [T]
    public let nextQuery: NextQuery?
    
    public init(items: [T], nextQuery: NextQuery? = nil) {
        self.items = items
        self.nextQuery = nextQuery
    }
    
    public func appending(_ contentsOf: Self) -> Self {
        let items = self.items + contentsOf.items
        let nextQuery = contentsOf.nextQuery
        return .init(items: items, nextQuery: nextQuery)
    }
    
    public func prepending(_ contentsOf: Self) -> Self {
        let items = contentsOf.items + self.items
        return .init(items: items, nextQuery: self.nextQuery)
    }
    
    public func map<V>(_ transform: (T) -> V) -> AnyQueryStreamable<V> {
        .init(items: items.map{ transform($0) }, nextQuery: nextQuery)
    }
}

public struct NextQuery: Codable {
    public let memberID: String
    public let limit: Int
    public let filters: [GroupData.ViewInfo.FilterData]?
    public let sorts: [Sort]
    public let groupByFilters: GroupData.ViewInfo.FilterData?
    public let filterLogicalOperator: GroupData.ViewInfo.FilterLogicalOperator
    
    enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case limit, sorts, groupByFilters
        case filters, filterLogicalOperator
    }

    static func mock(workspace: WorkspaceData, view: GroupData.ViewInfo,
                     groupByID: FieldOptions.FieldOptionInfo.ID? = nil,
                     limit: Int) -> NextQuery {
        if let groupBy = view.groupBy {
            let groupByID = groupByID ?? "NULL"
            return .init(memberID: workspace.userMemberInfo.memberID,
                         limit: limit,
                         filters: view.filters,
                         sorts: view.sorts ?? [],
                         groupByFilters: .init(fieldID: groupBy.fieldID,
                                               type: groupBy.type,
                                               value: groupByID == "NULL" ? .null : (groupBy.type.isMulti ? .strings([groupByID]) : .string(groupByID)),
                                               operatorID: nil,
                                               filterOperator: groupBy.type.isMulti ? .contains : .eq),
                         filterLogicalOperator: .and)
        } else {
            return .init(memberID: workspace.userMemberInfo.memberID,
                         limit: limit,
                         filters: view.filters,
                         sorts: view.sorts ?? [],
                         groupByFilters: nil,
                         filterLogicalOperator: .and)
        }
    }
}
extension NextQuery {
    public struct Sort: Codable, Hashable {
        let type: String
        let fieldID: String?
        let isDescent: Bool
        let next: Next?

        enum CodingKeys: String, CodingKey {
            case type
            case fieldID = "fieldId"
            case isDescent, next
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: NextQuery.Sort.CodingKeys.self)
            try container.encode(self.type, forKey: NextQuery.Sort.CodingKeys.type)
            if self.fieldID == nil {
                try container.encodeNil(forKey: NextQuery.Sort.CodingKeys.fieldID)
            } else {
                try container.encode(self.fieldID, forKey: NextQuery.Sort.CodingKeys.fieldID)
            }
            try container.encode(self.isDescent, forKey: NextQuery.Sort.CodingKeys.isDescent)
            try container.encodeIfPresent(self.next, forKey: NextQuery.Sort.CodingKeys.next)
        }
    }

}

extension NextQuery.Sort {
    public enum Next: Codable, Hashable {
        case string(String)
        case int(Int)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let v = try? container.decode(String.self) {
                self = .string(v)
                return
            }
            if let v = try? container.decode(Int.self) {
                self = .int(v)
                return
            }
            
            throw DecodingError.typeMismatch(
                AnyDictionaryValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "[AnyQueryStreamable.NextQuery.Sort] Type is not matched", underlyingError: nil))
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .string(let value):
                    try container.encode(value)
                case .int(let value):
                    try container.encode(value)
            }
        }
    }
}
