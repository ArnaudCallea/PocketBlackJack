//
//  Item.swift
//  PocketBlackJack
//
//  Created by Arnaud Callea on 13/04/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
