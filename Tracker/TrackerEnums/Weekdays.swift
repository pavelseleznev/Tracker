//
//  Weekdays.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import Foundation

enum Weekdays: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var localizedNameFull: String {
        let locale = Locale.current
        switch locale.languageCode {
        case "ru":
            switch self {
            case .monday: return "Понедельник"
            case .tuesday: return "Вторник"
            case .wednesday: return "Среда"
            case .thursday: return "Четверг"
            case .friday: return "Пятница"
            case .saturday: return "Суббота"
            case .sunday: return "Воскресенье"
            }
        default:
            return self.rawValue
        }
    }
    
    var numberValue: Int {
        switch self {
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        case .sunday: 1
        }
    }
    
    var shortDayName: String {
        let locale = Locale.current
        switch locale.languageCode {
        case "ru":
            switch self {
            case .monday: return "Пн"
            case .tuesday: return "Вт"
            case .wednesday: return "Ср"
            case .thursday: return "Чт"
            case .friday: return "Пт"
            case .saturday: return "Сб"
            case .sunday: return "Вс"
            }
        default:
            switch self {
            case .monday: return "Mon"
            case .tuesday: return "Tue"
            case .wednesday: return "Wed"
            case .thursday: return "Thu"
            case .friday: return "Fri"
            case .saturday: return "Sat"
            case .sunday: return "Sun"
            }
        }
    }
    
    var numberValueRus: Int {
        switch self {
        case .monday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        case .sunday:
            return 7
        }
    }
    
    static func convertWeekDay(_ number: Int) -> String {
        if let weekday = Weekdays.allCases.first(where: {
            $0.numberValue == number }) {
            return weekday.rawValue
        } else {
            return "[convertWeekDay]: Failed to return weekday string"
        }
    }
}
