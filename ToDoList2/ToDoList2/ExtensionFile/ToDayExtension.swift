//
//  ToDayExtension.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/6.
//

import Foundation
import SwiftUI


enum TimeState {
    case 早晨, 下午, 晚上
}

extension NothingToDoView {
    init() {
        // 這裡需要處理
        let currentDate = Date()
        let currentHour = currentDate.formatted(.dateTime.hour(.conversationalTwoDigits(amPM: .wide)))
        let firstIndex = currentHour.startIndex
        let firstHour = currentHour[firstIndex]
        let secondHour = currentHour[currentHour.index(firstIndex, offsetBy: 1)]
        var hours = Int(String(firstHour))! * 10 + Int(String(secondHour))!
        if currentHour.count == 5 {
            let firstAlpha = currentHour[currentHour.index(firstIndex, offsetBy: 3)]
            if firstAlpha == "P" { hours += 12 }
        } else {
            if currentHour.contains("evening") || currentHour.contains("afternoon") { hours += 12 }
        }
        if 6 <= hours && hours <= 12 {
            timeState = .早晨
        } else if 13 <= hours && hours <= 18 {
            timeState = .下午
        } else {
            timeState = .晚上
        }
        return
    }
}
