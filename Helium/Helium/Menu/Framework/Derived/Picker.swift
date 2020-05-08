//
//  Picker.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

//struct Picker<SelectionValue: Hashable>: MenuItemGroup {
//    @Binding
//    var selection: SelectionValue
//    var content: [Text]
//
//    var body: MenuItemGroup {
//        Section {
//            content
//        }
//    }
//}

struct Picker<SelectionValue: Equatable>: Menu {
    @Binding var selection: SelectionValue
    var choices: [(SelectionValue, String)]
    
    init(selection: Binding<SelectionValue>, _ choices: KeyValuePairs<SelectionValue, String>) {
        self._selection = selection
        self.choices = Array(choices)
    }
    
    init(selection: Binding<SelectionValue>, _ choices: [(SelectionValue, String)]) {
        self._selection = selection
        self.choices = choices
    }
    
    var body: Menu {
        Section {
            ForEach(choices) { (key, choice) in
                Button(choice, action: { self.selection = key })
                    .state(self.selection == key ? .on : .off)
            }
        }
    }
}
