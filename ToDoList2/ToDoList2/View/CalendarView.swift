//
//  CalendarView.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/6.
//

import SwiftUI
import AudioToolbox

struct TopBarView: View {
    @Binding var chooseDate: Date
    var body: some View {
        HStack {
            Text("\(getCurrentDate())")
                .font(.title3).bold()
        }
    }
}

extension TopBarView {
    func getCurrentDate() -> String {
        let month = chooseDate.formatted(.dateTime.month(.defaultDigits))
        let day = chooseDate.formatted(.dateTime.day())
        return month + "/" + day
    }
}

struct DateChooseView: View {
    @EnvironmentObject var toDoData: ToDoData
    @Binding var chooseDate: Date
    var body: some View {
        VStack {
            DatePicker("選擇日期，獲取該日期的工作", selection: $chooseDate, displayedComponents: .date)
                .accentColor(Color.indigo)
                .datePickerStyle(.graphical)
                .padding()
                .background()
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.leading)
                .padding(.trailing)
                .onChange(of: chooseDate) { newValue in
                    toDoData.checkAddRepeatToDo(newValue)
                }
        }
    }
}

struct SpecifyDayToDoListView: View {
    @Binding var chooseDate: Date
    @EnvironmentObject var toDoData: ToDoData
    var body: some View {
        List {
            ForEach(toDoData.toDoList.indices, id: \.self) { index in
                if !toDoData.toDoList[index].isDeleted && toDoData.checkToDoThingIsToDay(toDoData.toDoList[index], nowDate: chooseDate) {
                    SpecifySingleToDoCard(index: index)
                        .environmentObject(toDoData)
                }
            }
        }
        .animation(.easeInOut, value: chooseDate)
        .animation(.easeInOut, value: toDoData.toDayToDoCount)
        .background(.white)
        .scrollContentBackground(.hidden)
    }
}

struct SpecifySingleToDoCard: View {
    @EnvironmentObject var toDoData: ToDoData
    @State var showSheet: Bool = false
    var index: Int
    var body: some View {
        HStack {
            Image(systemName: toDoData.toDoList[index].isFinish ? "checkmark.shield.fill" : "shield")
                .onTapGesture { toDoData.changeIsFinishState(index) }
                .foregroundStyle(LinearGradient(colors: [.pink, .indigo, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(alignment: .leading) {
                Text("\(toDoData.toDoList[index].title)")
                    .font(.title3)
                    .bold()
                Text("\(toDoData.toDoList[index].detail)")
                    .font(.subheadline)
                    .frame(height: 30)
            }
            .padding(.leading, 5)
            Spacer()
            Text("\(toDoData.toDoList[index].todoDay.formatted(.dateTime.hour().minute()))")
                .bold()
        }
        .background(.white)
        .onTapGesture { showSheet = true }
        .sheet(isPresented: $showSheet) {
            SingleCardDetailView(showSheet: $showSheet, index: index)
                .environmentObject(toDoData)
                .presentationDetents([.fraction(0.5)])
        }
    }
}
struct CalendarAddToDoButtonView: View {
    @Binding var chooseDate: Date
    @State var showAddSheet: Bool = false
    var body: some View {
        HStack {
            Spacer()
            Button {
                AudioServicesPlaySystemSound(1519)
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(.orange)
                    .clipShape(Circle())
                    .padding(.trailing)
                    .padding(.bottom)
            }
            .sheet(isPresented: $showAddSheet) {
                AddToDoView(toDoDay: chooseDate)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct CalendarView: View {
    @State var chooseDate: Date = Date()
    @EnvironmentObject var toDoData: ToDoData
    var body: some View {
        VStack {
            TopBarView(chooseDate: $chooseDate)
            DateChooseView(chooseDate: $chooseDate)
                .environmentObject(toDoData)
            SpecifyDayToDoListView(chooseDate: $chooseDate)
                .environmentObject(toDoData)
            Spacer()
            CalendarAddToDoButtonView(chooseDate: $chooseDate)
        }
    }
}

//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView()
//    }
//}
