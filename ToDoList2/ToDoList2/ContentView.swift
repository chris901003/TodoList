//
//  ContentView.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/5.
//

import SwiftUI
import UserNotifications


struct ContentView: View {
    @ObservedObject var toDoData = ToDoData(isLoadStoage: true, storeKey: "ToDoList2")
    @State var tabSelection: Int = 0
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                return
            }
        }
    }
    var body: some View {
        TabView(selection: $tabSelection) {
            ToDayView().tabItem {
                Image(systemName: "checkmark.square.fill")
                Text("Today")
            }.tag(0)
                .environmentObject(toDoData)
            CalendarView().tabItem {
                Image(systemName: "calendar")
                Text("Calendar")
            }.tag(1)
                .environmentObject(toDoData)
            SettingView().tabItem {
                Image(systemName: "gearshape")
                Text("Setting")
            }.tag(2)
        }
        .animation(.easeInOut, value: tabSelection)
        .onAppear() { requestNotificationAuthorization() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
