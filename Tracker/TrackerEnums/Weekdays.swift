//
//  Weekdays.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import Foundation

enum Weekdays: String, CaseIterable, Codable {
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"
    case Sunday = "Sunday"
    
    var localizedNameFull: String {
        let locale = Locale.current
        switch locale.languageCode {
        case "ru":
            switch self {
            case .Monday: return "Понедельник"
            case .Tuesday: return "Вторник"
            case .Wednesday: return "Среда"
            case .Thursday: return "Четверг"
            case .Friday: return "Пятница"
            case .Saturday: return "Суббота"
            case .Sunday: return "Воскресенье"
            }
        default:
            return self.rawValue
        }
    }
    
    var numberValue: Int {
        switch self {
        case .Monday:
            return 2
        case .Tuesday:
            return 3
        case .Wednesday:
            return 4
        case .Thursday:
            return 5
        case .Friday:
            return 6
        case .Saturday:
            return 7
        case .Sunday:
            return 1
        }
    }
    
    var shortDayName: String {
        let locale = Locale.current
        switch locale.languageCode {
        case "ru":
            switch self {
            case .Monday: return "Пн"
            case .Tuesday: return "Вт"
            case .Wednesday: return "Ср"
            case .Thursday: return "Чт"
            case .Friday: return "Пт"
            case .Saturday: return "Сб"
            case .Sunday: return "Вс"
            }
        default:
            switch self {
            case .Monday: return "Mon"
            case .Tuesday: return "Tue"
            case .Wednesday: return "Wed"
            case .Thursday: return "Thu"
            case .Friday: return "Fri"
            case .Saturday: return "Sat"
            case .Sunday: return "Sun"
            }
        }
    }
    
    var numberValueRus: Int {
        switch self {
        case .Monday:
            return 1
        case .Tuesday:
            return 2
        case .Wednesday:
            return 3
        case .Thursday:
            return 4
        case .Friday:
            return 5
        case .Saturday:
            return 6
        case .Sunday:
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
