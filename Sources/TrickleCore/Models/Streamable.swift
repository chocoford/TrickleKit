//
//  Streamable.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/1/29.
//

import Foundation
import ChocofordEssentials

public struct AnyStreamable<T>: Codable, Equatable where T: Codable, T: Equatable {
    public var items: [T]
    public let nextTs: Date?
    
    public init() {
        self.items = []
        self.nextTs = .now
    }
    
    public init(items: [T], nextTs: Date?) {
        self.items = items
        self.nextTs = nextTs
    }
    
    public func appending(_ contentsOf: Self, replace: Bool = false) -> Self where T: Hashable {
        let items = self.items + contentsOf.items
        return .init(items: items.removingDuplicate(replace: replace), nextTs: contentsOf.nextTs)
    }
    public func prepending(_ contentsOf: Self, replace: Bool = false) -> Self where T: Hashable {
        if self.items.isEmpty { return contentsOf }
        let items = contentsOf.items + self.items
        return .init(items: items.removingDuplicate(replace: replace), nextTs: self.nextTs)
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
    
    /// Returns the array by appending the contents of the spcific array without modifying the original array.
    /// - Parameters:
    ///   - contentsOf: The contents of the spcific array
    ///   - replace: Indicates the incoming items should replace the original items if duplicated.
    public func appending(_ contentsOf: Self, replace: Bool = true) -> Self where T: Hashable {
        let items = self.items + contentsOf.items
        return .init(items: items.removingDuplicate(replace: replace), nextQuery: contentsOf.nextQuery)
    }
    
    /// Returns the array by prepending the contents of the spcific array without modifying the original array.
    /// - Parameters:
    ///   - contentsOf: The contents of the spcific array
    ///   - replace: Indicates the incoming items should replace the original items if duplicated.
    public func prepending(_ contentsOf: Self, replace: Bool = true) -> Self where T: Hashable {
        let items = contentsOf.items + self.items
        return .init(items: items.removingDuplicate(replace: !replace), nextQuery: self.nextQuery)
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
    
    public init(memberID: String, limit: Int, filters: [GroupData.ViewInfo.FilterData]?, sorts: [Sort], groupByFilters: GroupData.ViewInfo.FilterData?, filterLogicalOperator: GroupData.ViewInfo.FilterLogicalOperator) {
        self.memberID = memberID
        self.limit = limit
        self.filters = filters
        self.sorts = sorts
        self.groupByFilters = groupByFilters
        self.filterLogicalOperator = filterLogicalOperator
    }

    
    enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case limit, sorts, groupByFilters
        case filters, filterLogicalOperator
    }

    public static func mock(workspace: WorkspaceData, view: GroupData.ViewInfo,
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
    
    public static func morkFeed(workspace: WorkspaceData,
                                isDescent: Bool,
                                since: Date,
                                limit: Int) -> NextQuery {
        NextQuery(memberID: workspace.userMemberInfo.memberID,
                  limit: limit,
                  filters: nil,
                  sorts: [.init(type: "create_on",
                                fieldID: nil,
                                isDescent: isDescent,
                                next: .int(Int(since.timeIntervalSince1970)))],
                  groupByFilters: nil,
                  filterLogicalOperator: .and)
    }
}
extension NextQuery {
    public struct Sort: Codable, Hashable {
        let type: String
        let fieldID: String?
        let isDescent: Bool
        let next: Next?
        
        public init(type: String, fieldID: String?, isDescent: Bool, next: Next?) {
            self.type = type
            self.fieldID = fieldID
            self.isDescent = isDescent
            self.next = next
        }

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
