//
//  NewToDoData.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/7.
//

import Foundation

enum RemainMode: String, CaseIterable, Codable {
    case 無, 前一天, 前兩天, 前三天, 一週
}

extension RemainMode {
    func getRemainTime(_ endDate: Date) -> Double {
        switch self {
            case .無:
                return -1
            case .前一天:
                return endDate.timeIntervalSinceNow - 86400
            case .前兩天:
                return endDate.timeIntervalSinceNow - 86400 * 2
            case .前三天:
                return endDate.timeIntervalSinceNow - 86400 * 3
            case .一週:
                return endDate.timeIntervalSinceNow - 86400 * 7
        }
    }
}

enum RepeatTime: String, CaseIterable, Codable, TimeOperation {
    case 無, 每天, 每週, 每月, 每年
}

extension RepeatTime {
    func getToDoInterval() -> DateComponents {
        var result: DateComponents = DateComponents()
        switch self {
            case .無:
                break
            case .每天:
                result.day = 1
            case .每週:
                result.day = 7
            case .每月:
                result.month = 1
            case .每年:
                result.year = 1
        }
        return result
    }
    
    func checkNeedToAdd(nowDate: Date, endDate: Date) -> Bool {
        let sDateComponents: DateComponents = getDateComponents(nowDate: nowDate)
        let eDateComponents: DateComponents = getDateComponents(nowDate: endDate)
        let sDate = Calendar.current.date(from: sDateComponents)!
        let eDate = Calendar.current.date(from: eDateComponents)!
        let filterPastDay = getTimeDiff(startTime: sDate, endTime: eDate, filters: [.year, .month, .weekOfMonth, .day])
        if let _ = filterPastDay.firstIndex(where: { $0 < 0 }) {
            return false
        }
        switch self {
        case .無:
            return false
        case .每天:
            let timeDiff = getTimeDiff(startTime: sDate, endTime: eDate,
                                       filters: [.year, .month, .weekOfMonth, .day])
            if let _ = timeDiff.firstIndex(where: { $0 != 0}) {
                return true
            }
        case .每週:
            let timeDiff = getTimeDiff(startTime: sDate, endTime: eDate,
                                       filters: [.weekOfMonth, .day])
            if timeDiff[1] == 0 {
                return true
            }
        case .每月:
            let timeDiff = getTimeDiff(startTime: sDate, endTime: eDate,
                                       filters: [.month, .weekOfMonth, .day])
            if timeDiff[1] == 0 && timeDiff[2] == 0 {
                return true
            }
        case .每年:
            let timeDiff = getTimeDiff(startTime: sDate, endTime: eDate,
                                       filters: [.year, .month, .weekOfMonth, .day])
            if timeDiff[1] == 0 && timeDiff[2] == 0 && timeDiff[3] == 0 {
                return true
            }
        }
        return false
    }
}

enum CardColor {
    case 紅, 橙, 黃, 綠, 藍, 紫
}

class NewToDoData: ObservableObject {
    @Published var title: String
    @Published var detail: String
    @Published var todoDay: Date
    @Published var remainMode: [RemainMode] {
        didSet {
            if remainMode.count == 0 {
                remainMode.append(.無)
            } else if remainMode.count >= 2 && remainMode.last == .無 {
                remainMode = [.無]
            } else if remainMode.count >= 2 && remainMode.contains(.無) {
                remainMode.remove(at: remainMode.firstIndex(where: { mode in
                    mode == .無
                })!)
            }
        }
    }
    @Published var repeatTime: RepeatTime
    init() {
        title = ""
        detail = ""
        todoDay = Date()
        remainMode = [.無]
        repeatTime = .無
    }
}
