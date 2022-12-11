//
//  ToDoProtocal.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/8.
//

import Foundation

protocol TimeOperation {
    func getTimeDiff(startTime: Date, endTime: Date,
                     filters: [Calendar.Component]) -> [Int]
    func getDateComponents(nowDate: Date) -> DateComponents
    func changeHourFormatTo24(inputTime: String) -> String
}

extension TimeOperation {
    func getTimeDiff(startTime: Date, endTime: Date,
                     filters: [Calendar.Component]) -> [Int] {
        var componentsFilter: Set<Calendar.Component> = []
        for filter in filters {
            componentsFilter.insert(filter)
        }
        let diff = Calendar.current.dateComponents(componentsFilter, from: startTime, to: endTime)
        var res: [Int] = []
        for filter in filters {
            switch filter {
                case .year:
                    res.append(diff.year!)
                case .month:
                    res.append(diff.month!)
                case .weekOfMonth:
                    res.append(diff.weekOfMonth!)
                case .day:
                    res.append(diff.day!)
                case .hour:
                    res.append(diff.hour!)
                case .minute:
                    res.append(diff.minute!)
                case .second:
                    res.append(diff.second!)
                default:
                    fatalError("時間差為提供該差值類型，如果有需要請自行複寫")
            }
        }
        return res
    }
    
    func getDateComponents(nowDate: Date) -> DateComponents {
        var res: DateComponents = DateComponents()
        res.year = Int(nowDate.formatted(.dateTime.year()))!
        res.month = Int(nowDate.formatted(.dateTime.month(.defaultDigits)))!
        res.day = Int(nowDate.formatted(.dateTime.day()))!
        return res
    }
    
    func changeHourFormatTo24(inputTime: String) -> String {
        let firstIndex = inputTime.startIndex
        let firstHour = inputTime[firstIndex]
        let secondHour = inputTime[inputTime.index(firstIndex, offsetBy: 1)]
        let firstAlpha = inputTime[inputTime.index(firstIndex, offsetBy: 3)]
        var hours = Int(String(firstHour))! * 10 + Int(String(secondHour))!
        if firstAlpha == "P" { hours += 12 }
        else if inputTime.contains("evening") { hours += 12}
        return String(hours)
    }
}
