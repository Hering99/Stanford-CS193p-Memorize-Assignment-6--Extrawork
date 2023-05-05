//
//  Memorize_A6App.swift
//  Memorize A6
//
//  Created by Lukas Hering on 03.05.23.
//

import SwiftUI

@main
struct Memorize_A6App: App {
    
    var body: some Scene {
        WindowGroup {
            ThemeSelector().environmentObject(ThemeStore(named: "default"))
        }
    }
}
