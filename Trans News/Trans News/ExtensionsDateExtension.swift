//
//  DateExtension.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: self, to: now)
        let language = AppLanguage.current
        
        if let year = components.year, year > 0 {
            return language == .english ? "\(year) years ago" : "\(year) tahun yang lalu"
        }
        if let month = components.month, month > 0 {
            return language == .english ? "\(month) months ago" : "\(month) bulan yang lalu"
        }
        if let week = components.weekOfYear, week > 0 {
            return language == .english ? "\(week) weeks ago" : "\(week) minggu yang lalu"
        }
        if let day = components.day, day > 0 {
            if day == 1 { return language == .english ? "Yesterday" : "Kemarin" }
            return language == .english ? "\(day) days ago" : "\(day) hari yang lalu"
        }
        if let hour = components.hour, hour > 0 {
            return language == .english ? "\(hour) hours ago" : "\(hour) jam yang lalu"
        }
        if let minute = components.minute, minute > 0 {
            return language == .english ? "\(minute) minutes ago" : "\(minute) menit yang lalu"
        }
        return language == .english ? "Just now" : "Baru saja"
    }
    
    func formattedIndonesian() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: AppLanguage.current.localeIdentifier)
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Greeting berdasarkan waktu hari
    static var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let language = AppLanguage.current
        switch hour {
        case 0..<5: return language == .english ? "Good Night" : "Selamat Malam"
        case 5..<11: return language == .english ? "Good Morning" : "Selamat Pagi"
        case 11..<15: return language == .english ? "Good Afternoon" : "Selamat Siang"
        case 15..<18: return language == .english ? "Good Evening" : "Selamat Sore"
        default: return language == .english ? "Good Night" : "Selamat Malam"
        }
    }
    
    /// Estimasi waktu baca berdasarkan jumlah kata (200 wpm)
    static func estimatedReadTime(for text: String?) -> String {
        guard let text, !text.isEmpty else { return "1 mnt baca" }
        let wordCount = text.split(separator: " ").count
        let minutes = max(1, wordCount / 200)
        return AppLanguage.current == .english ? "\(minutes) min read" : "\(minutes) mnt baca"
    }
}
