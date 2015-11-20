//
//  ArrayExtensions.swift
//  SKDownloader
//
//  Created by liupeng on 11/20/15.
//  Copyright © 2015 liupeng. All rights reserved.
//


import Foundation

extension RangeReplaceableCollectionType where Generator.Element: Equatable {
    mutating func remove(object: Generator.Element) {
        guard let index = indexOf(object)
            else { return }

        self.removeAtIndex(index)
    }
}