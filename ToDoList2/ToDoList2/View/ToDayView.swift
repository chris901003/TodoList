//
//  ToDayView.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/6.
//

import SwiftUI
import UserNotifications
import AudioToolbox

struct NothingToDoView: View {
    var timeState: TimeState
    var body: some View {
        ZStack {
            Circle().stroke(.linearGradient(
                colors: timeState == .早晨 ? [.green, .orange] : timeState == .下午 ? [.yellow, .red] : [.indigo, .teal],
                startPoint: .leading, endPoint: .trailing), lineWidth: 5).padding(40)
            Image(timeState == .早晨 ? "morning" : timeState == .下午 ? "afternoon" : "night")
                .resizable().aspectRatio(contentMode: .fit)
                .clipShape(Circle())
        }
        Text("今天的事情都做完了")
            .bold()
            .padding(1)
        Text(timeState == .早晨 ? "享受美好的一天吧" : timeState == .下午 ? "有個愉快的下午茶" : "祝您度過寧靜的夜晚")
            .foregroundColor(.secondary)
    }
}

struct ToDayToDoView: View {
    @EnvironmentObject var toDoData: ToDoData
    var body: some View {
        VStack {
            ForEach(toDoData.toDoList.indices, id: \.self) { index in
                if toDoData.checkToDoThingIsToDay(toDoData.toDoList[index]) && (toDoData.toDoList[index].isDeleted == false) {
                    SingleToDoCardView(index: index)
                        .padding()
                }
            }
        }
        .onAppear() { toDoData.checkAddRepeatToDo(Date()) }
        .animation(.easeIn, value: toDoData.toDoList.count)
    }
}

struct SingleToDoCardView: View {
    @EnvironmentObject var toDoData: ToDoData
    @State var showSheet: Bool = false
    var index: Int = 0
    var cardColorList: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    var body: some View {
        HStack {
            Rectangle()
                .frame(maxWidth: 6)
                .foregroundColor(cardColorList[index % cardColorList.count])
            Text(toDoData.toDoList[index].title)
                .font(.headline)
                .bold()
                .padding(.leading)
            Spacer()
            Group {
                Text("\(toDoData.toDoList[index].todoDay.formatted(.dateTime.hour()))")
                Text("\(toDoData.toDoList[index].todoDay.formatted(.dateTime.minute(.twoDigits))) Min")
            }.foregroundColor(.secondary)
            Image(systemName: toDoData.toDoList[index].isFinish ? "checkmark.shield.fill" : "shield")
                .padding()
                .foregroundColor(cardColorList[index % cardColorList.count])
                .onTapGesture {
                    toDoData.changeIsFinishState(index)
                }.animation(.easeInOut, value: toDoData.toDoList[index].isFinish)
        }
        .frame(height: 80)
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 10, x: 0, y: 10)
        .onTapGesture {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SingleCardDetailView(showSheet: $showSheet, index: index)
                .environmentObject(toDoData)
                .presentationDetents([.fraction(0.5)])
        }
    }
}

struct TopBar: View {
    var body: some View {
        HStack {
            Spacer()
            Text("今天")
                .font(.title3).bold()
            Spacer()
        }.overlay() {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "line.3.horizontal")
                }.padding(.leading)
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                }.padding(.trailing)
            }
        }
    }
}

struct AddToDoButtonView: View {
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
                AddToDoView()
                    .presentationDetents([.medium])
            }
        }
    }
}

struct ToDayView: View {
    @EnvironmentObject var toDoData: ToDoData
    var body: some View {
        VStack {
            TopBar()
            Spacer()
            ScrollView {
                if toDoData.toDayToDoCount == 0 {
                    NothingToDoView()
                        .transition(.opacity)
                } else {
                    ToDayToDoView()
                        .environmentObject(toDoData)
                }
                Spacer()
                Text("\n\n")
            }.overlay() {
                VStack {
                    Spacer()
                    AddToDoButtonView()
                        .environmentObject(toDoData)
                }
            }
        }.animation(.easeInOut, value: toDoData.toDayToDoCount == 0)
    }
}
