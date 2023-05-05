//
//  ThemeStore.swift
//  Memorize A6
//
//  Created by Lukas Hering on 03.05.23.
//

import SwiftUI

//declare Themes´s Properties
struct Theme: Codable, Identifiable, Hashable {
    var name: String
    var emojis: String
    var removedEmojis: String
    var numberOfPairsOfCards: Int
    var color: RGBAColor
    let id: Int
    
    fileprivate init(name: String, emojis: String, numberOfPairsOfCards: Int, color: RGBAColor, id: Int) {
        self.name = name
        self.emojis = emojis
        self.removedEmojis = ""
        self.numberOfPairsOfCards = max(2, min(numberOfPairsOfCards, emojis.count))
        self.color = color
        self.id = id
    }
}

struct RGBAColor: Codable, Equatable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}

//declare initial Themes
class ThemeStore: ObservableObject {
    
    let name: String
    
    @Published var themes = [Theme]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    init(named name: String){
        self.name = name
        restoreFromUserDefaults()
        if themes.isEmpty {
            insertTheme(
                named: "Vehicles",
                emojis: "🚲🚂🚁🚜🚕🏎🚑🚓🚒✈️🚀⛵️🛸🛶🚌🏍🛺🚠🛵🚗🚚🚇🛻🚝",
                numberOfPairsOfCards: 7,
                color: Color(rgbaColor: RGBAColor(175, 67, 235, 1))
            )
            insertTheme(
                named: "Flags",
                emojis: "🇺🇸🇩🇪🇬🇧🇦🇺🇯🇵🇹🇭🇵🇸🇧🇷🇦🇫🇨🇳🇫🇷🇮🇷🇳🇬🇹🇷🇵🇹🇨🇷🇪🇹🇪🇪",
                numberOfPairsOfCards: 8,
                color: Color(rgbaColor: RGBAColor(38, 78, 245, 1))
            )
            insertTheme(
                named: "Animals",
                emojis: "🐆🐗🦓🐫🦌🦥🦏🦒🐺🦘🐘🦬🐅🦛",
                numberOfPairsOfCards: 7,
                color: Color(rgbaColor: RGBAColor(139, 69, 5, 1))
            )
            insertTheme(
                named: "Plants",
                emojis: "☘️🌵🌳🌿🌷🌹🌲🌴",
                numberOfPairsOfCards: 5,
                color: Color(rgbaColor: RGBAColor(0, 190, 0, 1))
            )
            insertTheme(
                named: "USA",
                emojis: "🔫🇺🇸🤠💵📱🏈🍩🦅",
                numberOfPairsOfCards: 8,
                color: Color(rgbaColor: RGBAColor(250, 0, 0, 1))
            )
            insertTheme(
                named: "Fruits",
                emojis: "🍊🍒🥝🍇🍏🍌🫐🥥🍍🥭",
                numberOfPairsOfCards: 7,
                color: Color(rgbaColor: RGBAColor(255, 115, 0, 1))
            )
        }
    }
    
    // MARK: - Store & Update Themes
    private var userDefaultsKey: String {
        "ThemeStore" + name
    }
    
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(themes), forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodeThemes = try? JSONDecoder().decode([Theme].self, from: jsonData) {
            themes = decodeThemes
        }
    }
    
    // MARK: - Intent
    func theme(at index: Int) -> Theme {
        let safeIndex = min(max(index, 0), themes.count - 1)
        return themes[safeIndex]
    }
    
    func removeTheme(at index: Int) {
        if themes.count > 1, themes.indices.contains(index) {
            themes.remove(at: index)
        }
    }

    func insertTheme(named name: String, emojis: String? = nil, numberOfPairsOfCards: Int = 2, color: Color = Color(rgbaColor: RGBAColor(240, 23, 50, 1)), at index: Int = 0) {
        let unique = (themes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let theme = Theme(name: name, emojis: emojis ?? "", numberOfPairsOfCards: numberOfPairsOfCards, color: RGBAColor(color: color), id: unique)
        let safeIndex = min(max(index, 0), themes.count)
        themes.insert(theme, at: safeIndex)
    }
}
