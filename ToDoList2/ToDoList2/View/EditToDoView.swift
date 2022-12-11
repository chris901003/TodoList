//
//  EditToDoView.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/10.
//
import SwiftUI
import AudioToolbox


struct SingleCardDetailView: View {
    @EnvironmentObject var toDoData: ToDoData
    @Binding var showSheet: Bool
    @ObservedObject var editToDoData: NewToDoData = NewToDoData()
    var index: Int
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Title:")
                        .foregroundColor(.secondary)
                    TextField("記得加上標題喔", text: $editToDoData.title)
                        .bold()
                    Spacer()
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.top, -10)
                HStack {
                    Text("Detail:")
                        .foregroundColor(.secondary)
                    ScrollView {
                        HStack {
                            TextEditor(text: $editToDoData.detail)
                                .bold()
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                SingleCardDetailBottomView(showSheet: $showSheet, index: index)
                    .environmentObject(toDoData)
                    .environmentObject(editToDoData)
                    .padding(.top, 10)
                Spacer()
            }
            .padding()
            .background(Color(red: 196/255, green: 196/255, blue: 198/255, opacity: 0.5))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SingleCardDetailTopBarView()
                        .environmentObject(editToDoData)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    SingleCardDeleteTopBarView(showSheet: $showSheet, index: index)
                        .environmentObject(toDoData)
                }
            }
        }
        .onAppear() {
            editToDoData.title = toDoData.toDoList[index].title
            editToDoData.detail = toDoData.toDoList[index].detail
            editToDoData.todoDay = toDoData.toDoList[index].todoDay
            editToDoData.remainMode = toDoData.toDoList[index].remainMode
            editToDoData.repeatTime = toDoData.toDoList[index].repeatTime
        }
    }
}

struct SingleCardDetailTopBarView: View {
    @EnvironmentObject var editToDoData: NewToDoData
    @State var isShowCalender: Bool = false
    @State var isChoosingRemain: Bool = false
    @State var isChoosingRepeat: Bool = false
    var body: some View {
        HStack {
            Button {
                isShowCalender = true
            } label: {
                Image(systemName: "calendar")
                Text("日期")
            }
        }
        .foregroundColor(Color(red: 95/255, green: 158/255, blue: 160/255))
        .bold()
        .fullScreenCover(isPresented: $isShowCalender) {
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if isChoosingRemain { isChoosingRemain = false }
                        else if isChoosingRepeat { isChoosingRepeat = false }
                        else { isShowCalender = false }
                    }
                VStack {
                    Spacer()
                    SingleCardChoose(isShowCalender: $isShowCalender, isChoosingRemain: $isChoosingRemain, isChoosingRepeat: $isChoosingRepeat)
                        .environmentObject(editToDoData)
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.leading)
                        .padding(.trailing)
                        .background(TransparentBackground())
                    Spacer()
                }
            }
        }
    }
}

struct SingleCardChoose: View {
    @EnvironmentObject var editToDoData: NewToDoData
    @Binding var isShowCalender: Bool
    @State var chooseDate: Date = Date()
    @Binding var isChoosingRemain: Bool
    @Binding var isChoosingRepeat: Bool
    var body: some View {
        VStack {
            DatePicker("選擇日期", selection: $chooseDate)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale.init(identifier: "zh-tw"))
                .accentColor(Color(red: 100/255, green: 149/255, blue: 237/255))
            HStack {
                Button {
                    isChoosingRemain = true
                } label: {
                    Image(systemName: "alarm.fill")
                    Text("提醒")
                    Spacer()
                    Image(systemName: "arrowshape.forward.fill")
                }
            }
            .bold()
            .foregroundColor(Color(red: 147/255, green: 112/255, blue: 219/255))
            .padding()
            HStack {
                Button {
                    isChoosingRepeat = true
                } label: {
                    Image(systemName: "repeat.circle")
                    Text("重複")
                    Spacer()
                    Image(systemName: "arrowshape.forward.fill")
                }
            }
            .bold()
            .foregroundColor(Color(red: 106/255, green: 90/255, blue: 205/255))
            .padding()
            HStack {
                Button {
                    isShowCalender = false
                } label: {
                    Image(systemName: "xmark.shield.fill")
                        .foregroundStyle(LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.title)
                        .padding(.bottom)
                }.padding(.leading)
                Spacer()
                Button {
                    isShowCalender = false
                    editToDoData.todoDay = chooseDate
                } label: {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(LinearGradient(colors: [.red, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.title)
                        .padding(.bottom)
                }.padding(.trailing)
            }
        }
        .onAppear() { chooseDate = editToDoData.todoDay }
        .padding()
        .overlay() {
            if isChoosingRemain || isChoosingRepeat { Color.secondary }
        }
        .overlay() {
            if isChoosingRemain {
                SingleCardChooseRemainView(isChoosingRemain: $isChoosingRemain)
                    .environmentObject(editToDoData)
            } else if isChoosingRepeat {
                SingleCardChooseRepeatView(isChoosingRepeat: $isChoosingRepeat)
                    .environmentObject(editToDoData)
            }
        }
        .animation(.easeInOut, value: isChoosingRemain || isChoosingRepeat)
    }
}

struct SingleCardChooseRemainView: View {
    @EnvironmentObject var editToDoData: NewToDoData
    @Binding var isChoosingRemain: Bool
    var body: some View {
        List {
            ForEach(RemainMode.allCases, id: \.rawValue) { remainType in
                Button {
                    if editToDoData.remainMode.contains(remainType) {
                        editToDoData.remainMode.remove(at: editToDoData.remainMode.firstIndex(where: { mode in
                            mode == remainType
                        })!)
                    } else {
                        editToDoData.remainMode.append(remainType)
                    }
                } label: {
                    HStack {
                        Image(systemName: editToDoData.remainMode.contains(remainType) ? "record.circle" : "circle")
                            .foregroundStyle(.linearGradient(colors: [.yellow, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .padding(.trailing)
                        Text("\(remainType.rawValue)")
                    }
                    .bold()
                    .foregroundColor(Color.init(red: 70/255, green: 130/255, blue: 180/255))
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 10)
            HStack {
                Spacer()
                Button {
                    isChoosingRemain = false
                } label: {
                    Text("返回")
                        .foregroundColor(Color.init(red: 112/255, green: 128/255, blue: 144/255))
                        .bold()
                }
                Spacer()
            }
        }
        .scrollContentBackground(.hidden)
    }
}

struct SingleCardChooseRepeatView: View {
    @EnvironmentObject var editToDoData: NewToDoData
    @Binding var isChoosingRepeat: Bool
    var body: some View {
        VStack {
            List {
                ForEach(RepeatTime.allCases, id: \.rawValue) { repeatType in
                    Button {
                        editToDoData.repeatTime = repeatType
                    } label: {
                        HStack {
                            Image(systemName: editToDoData.repeatTime == repeatType ? "record.circle" : "circle")
                                .foregroundStyle(.linearGradient(colors: [.yellow, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            Text("\(repeatType.rawValue)")
                        }
                        .bold()
                        .foregroundColor(Color.init(red: 70/255, green: 130/255, blue: 180/255))
                    }
                }
                .padding(.top, 15)
                .padding(.trailing, 10)
                HStack {
                    Spacer()
                    Button {
                        isChoosingRepeat = false
                    } label: {
                        Text("返回")
                            .foregroundColor(Color.init(red: 112/255, green: 128/255, blue: 144/255))
                            .bold()
                    }
                    Spacer()
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

struct SingleCardDeleteTopBarView: View {
    @Binding var showSheet: Bool
    @EnvironmentObject var toDoData: ToDoData
    @State var isConfirmtionDialogShow: Bool = false
    var index: Int
    var body: some View {
        HStack {
            Button {
                if toDoData.toDoList[index].repeatTime == .無 && toDoData.toDoList[index].parent == "" {
                    toDoData.deleteToDoData(index)
                    AudioServicesPlaySystemSound(1519)
                    showSheet = false
                } else {
                    isConfirmtionDialogShow = true
                }
            } label: {
                Image(systemName: "trash")
                    .bold()
                    .foregroundColor(Color(red: 171/255, green: 132/255, blue: 105/255))
                    .padding(.leading)
            }
        }
        .confirmationDialog("是否需要刪除所有重複提醒", isPresented: $isConfirmtionDialogShow, titleVisibility: .visible) {
            Button {
                AudioServicesPlaySystemSound(1519)
                toDoData.deleteToDoData(index, deleteAllRepeat: false)
                showSheet = false
            } label: {
                Text("刪除單一提醒")
            }
            Button(role: .destructive) {
                AudioServicesPlaySystemSound(1519)
                toDoData.deleteToDoData(index, deleteAllRepeat: true)
                showSheet = false
            } label: {
                Text("刪除所有重複提醒")
            }
            Button(role: .cancel) {
                isConfirmtionDialogShow = false
            } label: {
                Text("取消")
            }
        }
    }
}

struct SingleCardDetailBottomView: View {
    @Binding var showSheet: Bool
    @EnvironmentObject var toDoData: ToDoData
    @EnvironmentObject var editToDoData: NewToDoData
    var index: Int
    var body: some View {
        HStack {
            Button {
                showSheet = false
            } label: {
                Image(systemName: "arrowshape.turn.up.backward.fill")
                    .foregroundStyle(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .font(.title)
                    .padding(.leading)
            }
            Spacer()
            Button {
                toDoData.deleteToDoData(index, deleteAllRepeat: true)
                toDoData.addToDoThing(editToDoData)
                showSheet = false
            } label: {
                Image(systemName: "paperplane.fill")
                    .rotationEffect(.degrees(45))
                    .font(.title)
                    .padding(.trailing)
            }
        }
    }
}
