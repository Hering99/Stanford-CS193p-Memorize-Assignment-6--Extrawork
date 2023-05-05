//
//  ThemeSelector.swift
//  Memorize A6
//
//  Created by Lukas Hering on 03.05.23.
//

import SwiftUI

//View that is shown when App is opened.
//UI to select Theme to which Memory is played with
//Button to create new Theme or edit/delete existing Themes
struct ThemeSelector: View {
    @EnvironmentObject var store: ThemeStore
    @State private var games = [Theme: EmojiMemoryGame]()
    @State private var editMode: EditMode = .inactive
    
    
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(store.themes.filter { $0.emojis.count > 1 }) { theme in
                    NavigationLink(destination: getDestination(for: theme)) {
                        themePreview(for: theme)
                    }
                    .gesture(editMode == .active ? tapToEditTheme(for: theme) : nil)
                }
                .onDelete { indexSet in
                    indexSet.forEach { store.removeTheme(at: $0) }
                }
                .onMove { fromOffsets, toOffset in
                    store.themes.move(fromOffsets: fromOffsets, toOffset: toOffset)
                }
            }
            .navigationTitle("Memorize")
            .listStyle(.inset)
            .sheet(item: $themeToEdit) {
                removeNewThemeIfInvalid()
            } content: { theme in
                ThemeEditor(theme: $store.themes[theme])
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { newThemeButton }
                ToolbarItem { EditButton() }
            }
            .environment(\.editMode, $editMode)
        }
        .listViewIfIPad()
        .onChange(of: store.themes) { newThemes in
            updateGames(to: newThemes)
        }
    }
    
    //Preview showing Number of Pairs of Cards, Color and Emojjis the Memory Game involves
    private func themePreview(for theme: Theme) -> some View {
        VStack(alignment: .leading) {
            Text(theme.name)
                .foregroundColor(Color(rgbaColor: theme.color))
                .font(.system(size: 25))
                .bold()
            HStack {
                if theme.emojis.count == theme.numberOfPairsOfCards {
                    Text("All of \(theme.emojis)")
                }
                else {
                    Text("\(theme.numberOfPairsOfCards) Pairs from \(theme.emojis)")
                }
            } .lineLimit(1)
        }
    }

    
    
    //copied from Skkimeo
    private func getDestination(for theme: Theme) -> some View{
        if games[theme] == nil {
            let newGame = EmojiMemoryGame(theme: theme)
            games.updateValue(newGame, forKey: theme)
            return EmojiMemoryGameView(game: newGame)
        }
        return EmojiMemoryGameView(game: games[theme]!)
    }
    
    //Theme Editing Buttons and Gestures
    
    @State private var themeToEdit: Theme?
    
    private var newThemeButton: some View {
        Button {
            store.insertTheme(named: "new Theme")
            themeToEdit = store.themes.first
        } label: {
            Image(systemName: "plus")
                .foregroundColor(.blue)
        }
    }
    
    private func removeNewThemeIfInvalid() {
        if let newInvalidTheme = store.themes.first {
            if newInvalidTheme.emojis.count < 2 {
                store.removeTheme(at: 0)
            }
        }
    }
    
    private func tapToEditTheme(for theme: Theme) -> some Gesture {
        TapGesture().onEnded {
            print("edit \(editMode)")
            themeToEdit = store.themes[theme]
        }
    }
    
    private func updateGames(to newThemes: [Theme]) {
        store.themes.filter { $0.emojis.count >= 2}.forEach { theme in
            if !newThemes.contains(theme) {
                store.themes.remove(theme)
            }
        }
    }
}

//struct PaletteManager_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteManager()
//            .previewDevice("iPhone 8")
//            .environmentObject(PaletteStore(named: "Preview"))
//            .preferredColorScheme(.light)
//    }
//}
