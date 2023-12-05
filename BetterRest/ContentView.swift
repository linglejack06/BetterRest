//
//  ContentView.swift
//  BetterRest
//
//  Created by Jack Lingle on 11/30/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var reccomendedBedTime: String {
        return calculateBedtime()
    }
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1..<20) {
                            Text("^[\($0 - 1) cup](inflect: true)")
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Reccomended Bedtime").font(.headline)
                    Text("\(reccomendedBedTime)")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    func calculateBedtime() -> String {
        var sleepTime: Date
        do {
            let config  = MLModelConfiguration()
            let model = try BetterRestMLModelEquation(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            return sleepTime.formatted(date: .omitted, time: .shortened);
        } catch {
            alertTitle = "Error"
            alertMessage = "There was a problem"
        }
        return "failure"
    }
}

#Preview {
    ContentView()
}
