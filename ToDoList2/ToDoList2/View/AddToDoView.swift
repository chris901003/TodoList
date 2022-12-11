//
//  AddToDoView.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/6.
//

import SwiftUI
import AudioToolbox

struct DataInfoView: View {
    @Binding var title: String
    @Binding var detail: String
    @FocusState var isTaping: Bool
    var body: some View {
        VStack {
            TextField("記下東西吧", text: $title)
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding()
                .opacity(1)
            ZStack(alignment: .leading) {
                TextEditor(text: $detail)
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.leading)
                    .padding(.trailing)
                    .focused($isTaping)
                if !isTaping && detail == "" {
                    VStack {
                        Text("留下點詳細資訊吧")
                            .padding()
                            .padding(.leading)
                            .opacity(0.25)
                        Spacer()
                    }
                }
            }
        }.animation(.easeInOut, value: isTaping)
    }
}

struct BottomView: View {
    @Binding var isChoosingDay: Bool
    @Binding var isSettingMessage: Bool
    @EnvironmentObject var newToDoData: NewToDoData
    @EnvironmentObject var toDoData: ToDoData
    var body: some View {
        HStack {
            Button {
                isChoosingDay = true
            } label: {
                Image(systemName: "calendar")
                    .padding(.leading, 30)
                Text("日期")
                    .font(.subheadline)
            }
            .foregroundColor(.orange)
            .padding(.bottom, 20)
            Button {
                isSettingMessage = true
            } label: {
                Image(systemName: "message.and.waveform.fill")
                    .padding(.leading, 30)
                Text("提醒")
                    .font(.subheadline)
            }
            .foregroundColor(.orange)
            .padding(.bottom, 20)
            Spacer()
            SendNewToDoButtonView()
                .environmentObject(newToDoData)
                .environmentObject(toDoData)
                .padding(.bottom, 20)
        }
    }
}

struct SendNewToDoButtonView: View {
    @EnvironmentObject var newToDoData: NewToDoData
    @EnvironmentObject var toDoData: ToDoData
    @Environment(\.presentationMode) var presentation
    var body: some View {
        Button {
            toDoData.addToDoThing(newToDoData)
            AudioServicesPlaySystemSound(1519)
            presentation.wrappedValue.dismiss()
        } label: {
            Image(systemName: "paperplane.fill")
                .padding(5)
                .font(.subheadline)
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(10)
                .padding(.trailing, 30)
        }
    }
}

struct ChooseDayView: View {
    @EnvironmentObject var newToDoData: NewToDoData
    @Binding var toDoDay: Date
    @Binding var isChoosingDay: Bool
    var body: some View {
        VStack {
            DatePicker("日期選擇", selection: $toDoDay)
                .padding()
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale.init(identifier: "zh-tw"))
            HStack {
                Button {
                    isChoosingDay = false
                    toDoDay = newToDoData.todoDay
                } label: {
                    Image(systemName: "xmark.shield.fill")
                        .foregroundStyle(LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.title)
                        .padding(.bottom)
                }.padding(.leading)
                Spacer()
                Button {
                    isChoosingDay = false
                    newToDoData.todoDay = toDoDay
                } label: {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(LinearGradient(colors: [.red, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.title)
                        .padding(.bottom)
                }.padding(.trailing)
            }
        }
        .onAppear() { toDoDay = newToDoData.todoDay }
    }
}

struct SettingMessageView: View {
    @EnvironmentObject var newToDoData: NewToDoData
    @Binding var isSettingMessage: Bool
    @Binding var isSettingRemainTime: Bool
    @Binding var isSettingRepeatTime: Bool
    var screenBounds:CGRect = UIScreen.main.bounds
    var body: some View {
        VStack {
            Button {
                isSettingRemainTime = true
            } label: {
                HStack {
                    Image(systemName: "alarm.fill")
                    Text("提醒時段")
                    Spacer()
                    Image(systemName: "arrowshape.forward.fill")
                }
                .foregroundStyle(LinearGradient(colors: [Color(red: 105/255, green: 134/255, blue: 170/255), Color(red: 162/255, green: 133/255, blue: 174/255)], startPoint: .leading, endPoint: .trailing))
                .padding()
                .bold()
            }
            Button {
                isSettingRepeatTime = true
            } label: {
                HStack {
                    Image(systemName: "repeat.circle")
                    Text("重複提醒")
                    Spacer()
                    Image(systemName: "arrowshape.forward.fill")
                }
                .padding()
                .foregroundStyle(LinearGradient(colors: [Color(red: 162/255, green: 133/255, blue: 174/255), Color(red: 105/255, green: 134/255, blue: 170/255)], startPoint: .leading, endPoint: .trailing))
                .bold()
            }
        }
        .padding()
        .fullScreenCover(isPresented: $isSettingRemainTime) {
            ZStack {
                Color.secondary.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { isSettingRemainTime = false }
                VStack {
                    SettingMessageSendTimeView(isSettingMessage: $isSettingMessage, isSettingRemainTime: $isSettingRemainTime)
                        .environmentObject(newToDoData)
                        .background(TransparentBackground())
                        .offset(y: screenBounds.midY / 2)
                }
            }
        }
        .fullScreenCover(isPresented: $isSettingRepeatTime) {
            ZStack {
                Color.secondary.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { isSettingRepeatTime = false }
                SettingMessageRepeatView(isSettingRepeatTime: $isSettingRepeatTime, isSettingMessage: $isSettingMessage)
                    .environmentObject(newToDoData)
                    .background(TransparentBackground())
                    .offset(y: screenBounds.midY / 2)
            }
        }
    }
}

struct SettingMessageSendTimeView: View {
    @EnvironmentObject var newToDoData: NewToDoData
    @Binding var isSettingMessage: Bool
    @Binding var isSettingRemainTime: Bool
    var body: some View {
        List {
            ForEach(RemainMode.allCases, id: \.rawValue) { remainType in
                Button {
                    if newToDoData.remainMode.contains(remainType) {
                        newToDoData.remainMode.remove(at: newToDoData.remainMode.firstIndex(where: { mode in
                            mode == remainType
                        })!)
                    } else {
                        newToDoData.remainMode.append(remainType)
                    }
                } label: {
                    HStack {
                        Image(systemName: newToDoData.remainMode.contains(remainType) ? "record.circle" : "circle")
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
                    isSettingRemainTime = false
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

struct SettingMessageRepeatView: View {
    @EnvironmentObject var newToDoData: NewToDoData
    @Binding var isSettingRepeatTime: Bool
    @Binding var isSettingMessage: Bool
    var body: some View {
        VStack {
            List {
                ForEach(RepeatTime.allCases, id: \.rawValue) { repeatType in
                    Button {
                        newToDoData.repeatTime = repeatType
                    } label: {
                        HStack {
                            Image(systemName: newToDoData.repeatTime == repeatType ? "record.circle" : "circle")
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
                        isSettingRepeatTime = false
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

struct NavigationBackButtonView: View {
    @Environment(\.presentationMode) var presentation
    var body: some View {
        Button {
            presentation.wrappedValue.dismiss()
        } label: {
            Image(systemName: "arrowshape.turn.up.backward.fill")
                .foregroundStyle(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .font(.title)
                .padding(.bottom)
        }
        .padding(.top, 5)
        .padding(.leading)
        Spacer()
    }
}

struct NavigationDoubleBackButtonView: View {
    @Binding var isSetting: Bool
    var body: some View {
        Button {
            isSetting = false
        } label: {
            Image(systemName: "arrowshape.turn.up.backward.2.fill")
                .foregroundStyle(LinearGradient(colors: [.green, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                .font(.title)
                .padding(.bottom)
        }
        .padding(.top, 5)
        .padding(.trailing)
    }
}

struct AddToDoView: View {
    @State var isChoosingDay: Bool = false
    @State var isSettingMessage: Bool = false
    @State var toDoDay = Date()
    @State var isSettingRemainTime: Bool = false
    @State var isSettingRepeatTime: Bool = false
    @ObservedObject var newToDoData = NewToDoData()
    @EnvironmentObject var toDoData: ToDoData
    var body: some View {
        VStack {
            DataInfoView(title: $newToDoData.title, detail: $newToDoData.detail)
            Spacer()
            BottomView(isChoosingDay: $isChoosingDay, isSettingMessage: $isSettingMessage)
                .padding(.top)
                .environmentObject(newToDoData)
                .environmentObject(toDoData)
        }
        .background(Color(red: 196/255, green: 196/255, blue: 198/255, opacity: 0.5))
        .fullScreenCover(isPresented: $isChoosingDay) {
            ZStack {
                Color.secondary
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { isChoosingDay = false }
                ChooseDayView(toDoDay: $toDoDay, isChoosingDay: $isChoosingDay)
                    .environmentObject(newToDoData)
                    .background(.white)
                    .cornerRadius(20)
                    .padding(.leading)
                    .padding(.trailing)
                    .background(TransparentBackground())
            }
        }
        .fullScreenCover(isPresented: $isSettingMessage) {
            ZStack {
                Color.secondary
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { isSettingMessage = false }
                SettingMessageView(isSettingMessage: $isSettingMessage, isSettingRemainTime: $isSettingRemainTime, isSettingRepeatTime: $isSettingRepeatTime)
                    .environmentObject(newToDoData)
                    .background(.white)
                    .cornerRadius(20)
                    .background(TransparentBackground())
                    .padding(.leading)
                    .padding(.trailing)
            }
        }
        .animation(.easeInOut, value: isChoosingDay || isSettingMessage)
        .onAppear() { newToDoData.todoDay = toDoDay }
    }
}

//struct AddToDoView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddToDoView()
//    }
//}

