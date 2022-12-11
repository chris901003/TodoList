//
//  ToDoData.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/7.
//

import Foundation
import UserNotifications

class ToDoData: ObservableObject {
    @Published var toDoList: [SingleToDoData]
    @Published var toDayToDoCount: Int
    let NotificationContent = UNMutableNotificationContent()
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    init() {
        toDoList = [SingleToDoData(title: "Test", detail: "Test detail"),
                    SingleToDoData(title: "Test2", detail: "Test2 detail", isFinish: true)]
        toDayToDoCount = 2
    }
    init(isLoadStoage: Bool, storeKey: String = "") {
        if isLoadStoage {
            let data: [SingleToDoData] = Self.loadToDoListFromStorage(storeKey)
            toDoList = data
            toDayToDoCount = 0
            toDayToDoCount = data.reduce(0, {
                $0 + (checkToDoThingIsToDay($1) ? 1 : 0)
            })
        } else {
            toDoList = []
            toDayToDoCount = 0
        }
    }
    
    func checkToDoThingIsToDay(_ toDoData: SingleToDoData, nowDate: Date = Date()) -> Bool {
        let current = nowDate.formatted(.dateTime.year().month().day())
        if current == toDoData.todoDay.formatted(.dateTime.year().month().day()) {
            return true
        }
        return false
    }
    
    func addToDoThing(_ newToDoData: NewToDoData) -> Void {
        var newSingleData = SingleToDoData()
        newSingleData.title = newToDoData.title
        newSingleData.detail = newToDoData.detail
        newSingleData.todoDay = newToDoData.todoDay
        newSingleData.remainMode = newToDoData.remainMode
        newSingleData.repeatTime = newToDoData.repeatTime
        if newSingleData.repeatTime == .無 {
            addNotification(newSingleData)
        } else {
            var toDoDayTime = newSingleData.todoDay
            for _ in 1..<4 {
                let toDoTimeInterval: DateComponents = newSingleData.repeatTime.getToDoInterval()
                toDoDayTime = Calendar.current.date(byAdding: toDoTimeInterval, to: toDoDayTime)!
                let subSingleToDoData = SingleToDoData(newSingleData, todoDay: toDoDayTime)
                toDoList.append(subSingleToDoData)
                let recordTime = String(toDoDayTime.formatted(.dateTime.year().month().day()))
                newSingleData.repeatData.insert(recordTime)
                addNotification(subSingleToDoData)
            }
            newSingleData.repeatData.insert(newToDoData.todoDay.formatted(.dateTime.year().month().day()))
        }
        toDoList.append(newSingleData)
        updateToDayToDoCount(newSingleData, 1)
        dataStore()
    }
    
    func checkAddRepeatToDo(_ chooseDate: Date) {
        var waitToAppend: [SingleToDoData] = []
        for (idx, toDo) in toDoList.enumerated() {
            if toDo.parent != "" || toDo.repeatTime == .無 || toDo.isDeleteAllRepeat { continue }
            if toDo.repeatData.contains(
                chooseDate.formatted(.dateTime.year().month().day())) { continue }
            let isNeedToAdd = toDo.repeatTime.checkNeedToAdd(nowDate: toDo.todoDay, endDate: chooseDate)
            if !isNeedToAdd { continue }
            var newToDoDateComponents: DateComponents = DateComponents()
            let eHourInfo = toDo.repeatTime.changeHourFormatTo24(inputTime: toDo.todoDay.formatted(.dateTime.hour(.conversationalTwoDigits(amPM: .wide))))
            let sHourInfo = toDo.repeatTime.changeHourFormatTo24(inputTime: chooseDate.formatted(.dateTime.hour(.conversationalTwoDigits(amPM: .wide))))
            newToDoDateComponents.hour = Int(eHourInfo)! - Int(sHourInfo)!
            newToDoDateComponents.minute = Int(toDo.todoDay.formatted(.dateTime.minute()))! - Int(chooseDate.formatted(.dateTime.minute()))!
            let newToDoDate: Date = Calendar.current.date(byAdding: newToDoDateComponents, to: chooseDate)!
            let subSingleToDoData = SingleToDoData(toDo, todoDay: newToDoDate)
            waitToAppend.append(subSingleToDoData)
            let recordTime = String(chooseDate.formatted(.dateTime.year().month().day()))
            toDoList[idx].repeatData.insert(recordTime)
        }
        for appendToDoData in waitToAppend {
            toDoList.append(appendToDoData)
            updateToDayToDoCount(appendToDoData, 1)
            addNotification(appendToDoData)
        }
        dataStore()
    }
    
    func changeIsFinishState(_ index: Int) {
        toDoList[index].isFinish.toggle()
        dataStore()
        if toDoList[index].isFinish {
            cancelNotification(toDoList[index])
        } else {
            addNotification(toDoList[index])
        }
    }
    
    func deleteToDoData(_ index: Int, deleteAllRepeat: Bool = false) -> Void {
        if deleteAllRepeat {
            let parentIndex = toDoList[index].parent == "" ? index : toDoList.firstIndex {
                $0.title + "|" + $0.todoDay.description == toDoList[index].parent
            }!
            let parentTarget = toDoList[parentIndex].title + "|" + toDoList[parentIndex].todoDay.description
            for idx in toDoList.indices {
                if idx == index { continue }
                if toDoList[idx].parent == parentTarget || toDoList[idx].title + "|" + toDoList[idx].todoDay.description == parentTarget {
                    toDoList[idx].isDeleted = true
                    cancelNotification(toDoList[idx])
                    updateToDayToDoCount(toDoList[idx], -1)
                }
            }
            toDoList[parentIndex].isDeleteAllRepeat = true
        }
        toDoList[index].isDeleted = true
        dataStore()
        cancelNotification(toDoList[index])
        updateToDayToDoCount(toDoList[index], -1)
    }
    
    func addSingleNotification(timeInterval interval: Double, identifier: String) -> Void {
        if interval <= 0 { return }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: NotificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func addNotification(_ singleToDoData: SingleToDoData) {
        NotificationContent.title = singleToDoData.title
        NotificationContent.body = singleToDoData.detail
        NotificationContent.badge = 0
        for remainMode in singleToDoData.remainMode {
            let timeInterval = remainMode.getRemainTime(singleToDoData.todoDay)
            addSingleNotification(timeInterval: timeInterval, identifier: singleToDoData.title + singleToDoData.todoDay.description + remainMode.rawValue)
        }
        addSingleNotification(timeInterval: singleToDoData.todoDay.timeIntervalSinceNow, identifier: singleToDoData.title + singleToDoData.todoDay.description)
    }
    
    func cancelNotification(_ singleToDoData: SingleToDoData) {
        var notificationIdentifier: [String] = [singleToDoData.title + singleToDoData.todoDay.description]
        for remainMode in singleToDoData.remainMode {
            notificationIdentifier.append(singleToDoData.title + singleToDoData.todoDay.description + remainMode.rawValue)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIdentifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notificationIdentifier)
    }
    
    func updateToDayToDoCount(_ toDoData: SingleToDoData, _ delta: Int) {
        if checkToDoThingIsToDay(toDoData) {
            toDayToDoCount += delta
        }
    }
    
    func dataStore() {
        let dataStored = try! Self.encoder.encode(toDoList)
        UserDefaults.standard.set(dataStored, forKey: "ToDoList2")
    }
}

extension ToDoData {
    static func loadToDoListFromStorage(_ storeKey: String) -> [SingleToDoData] {
        var output: [SingleToDoData] = []
        if let dataStored = UserDefaults.standard.object(forKey: storeKey) as? Data {
            let data = try! Self.decoder.decode([SingleToDoData].self, from: dataStored)
            for item in data {
                if !item.isDeleted {
                    output.append(item)
                }
            }
        }
        return output
    }
}

struct SingleToDoData: Codable, Equatable {
    var title: String = ""
    var detail: String = ""
    var todoDay: Date = Date()
    var remainMode: [RemainMode] = [.無]
    var repeatTime: RepeatTime = .無
    var isDeleted: Bool = false
    var isFinish: Bool = false
    // 重複代辦事項的內容
    var parent: String = ""
    var repeatData: Set<String> = []
    var isDeleteAllRepeat: Bool = false
    // 為實作重要標記，只是先開好空間
    var isImportant: Bool = false
    // 根據不同類別進行分類，可以標註成不同顏色
    var classify: Int = 0
}

extension SingleToDoData {
    init(_ singleToDoData: SingleToDoData, todoDay: Date) {
        title = singleToDoData.title
        detail = singleToDoData.detail
        self.todoDay = todoDay
        remainMode = singleToDoData.remainMode
        repeatTime = .無
        parent = singleToDoData.title + "|" + singleToDoData.todoDay.description
        repeatData = []
        isImportant = singleToDoData.isImportant
        classify = singleToDoData.classify
    }
}
