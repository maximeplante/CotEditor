/*
 
 PrintAccessoryViewController.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2014-03-24.
 
 ------------------------------------------------------------------------------
 
 © 2014-2017 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Cocoa

/// print setting keys
enum PrintSettingKey: String {
    
    case theme = "CEThemeName"
    case lineNumber = "CEPrintLineNumber"
    case invisibles = "CEPrintInvisibles"
    case printsHeader = "CEPrintHeader"
    case primaryHeaderContent = "CEPrimaryHeaderContent"
    case secondaryHeaderContent = "CESecondaryHeaderContent"
    case primaryHeaderAlignment = "CEPrimaryHeaderAlignment"
    case secondaryHeaderAlignment = "CESecondaryHeaderAlignment"
    case printsFooter = "CEPrintFooter"
    case primaryFooterContent = "CEPrimaryFooterContent"
    case secondaryFooterContent = "CESecondaryFooterContent"
    case primaryFooterAlignment = "CEPrimaryFooterAlignment"
    case secondaryFooterAlignment = "CESecondaryFooterAlignment"
    
}

struct ThemeName {
    
    static let blackAndWhite = NSLocalizedString("Black and White", comment: "")
}



final class PrintPanelAccessoryController: NSViewController, NSPrintPanelAccessorizing {
    
    // MARK: Public Properties
    
    /// dummy property for syntax highlighting update
    dynamic var needsUpdatePreview = false
    
    
    // MARK: Private Properties
    
    @IBOutlet private weak var colorPopupButton: NSPopUpButton?
    
    
    
    // MARK: -
    // MARK: View Controller Method
    
    /// nib name
    override var nibName: String? {
        
        return "PrintPanelAccessory"
    }
    
    
    /// printInfo did set (new print sheet wil be displayed)
    override var representedObject: Any? {
        
        didSet {
            let defaults = UserDefaults.standard
            
            // set theme if needed
            self.theme = {
                if let mode = PrintColorMode(rawValue: defaults[.printColorIndex]) {
                    switch mode {
                    case .blackWhite:
                        return ThemeName.blackAndWhite
                    case .sameAsDocument:
                        return defaults[.theme] ?? ThemeName.blackAndWhite
                    }
                }
                return defaults[.printTheme] ?? ThemeName.blackAndWhite
            }()
            self.lineNumberMode = PrintLineNmuberMode(rawValue: defaults[.printLineNumIndex]) ?? .no
            self.invisibleCharsMode = PrintInvisiblesMode(rawValue: defaults[.printInvisibleCharIndex]) ?? .no
            
            self.printsHeader = defaults[.printHeader]
            self.primaryHeaderContent = PrintInfoType(defaults[.primaryHeaderContent])
            self.primaryHeaderAlignment = AlignmentType(defaults[.primaryHeaderAlignment])
            self.secondaryHeaderContent = PrintInfoType(defaults[.secondaryHeaderContent])
            self.secondaryHeaderAlignment = AlignmentType(defaults[.secondaryHeaderAlignment])
            
            self.printsFooter = defaults[.printFooter]
            self.primaryFooterContent = PrintInfoType(defaults[.primaryFooterContent])
            self.primaryFooterAlignment = AlignmentType(defaults[.primaryFooterAlignment])
            self.secondaryFooterContent = PrintInfoType(defaults[.secondaryFooterContent])
            self.secondaryFooterAlignment = AlignmentType(defaults[.secondaryFooterAlignment])
            
            // apply current theme
            self.setupColorMenu()
        }
    }
    
    
    
    // MARK: NSPrintPanelAccessorizing Protocol
    
    /// list of key paths that affect to preview
    func keyPathsForValuesAffectingPreview() -> Set<String> {
        
        return [#keyPath(theme),
                #keyPath(lineNumberMode),
                #keyPath(invisibleCharsMode),
                
                #keyPath(printsHeader),
                #keyPath(primaryHeaderContent),
                #keyPath(primaryHeaderAlignment),
                #keyPath(secondaryHeaderContent),
                #keyPath(secondaryHeaderAlignment),
                
                #keyPath(printsFooter),
                #keyPath(primaryFooterAlignment),
                #keyPath(primaryFooterContent),
                #keyPath(secondaryFooterAlignment),
                #keyPath(secondaryFooterContent),
                
                #keyPath(needsUpdatePreview),
        ]
    }
    
    
    /// localized descriptions for print settings
    func localizedSummaryItems() -> [[String: String]] {
        
        return [
            localizedSummaryItem(name: "Color", description: self.theme),
            localizedSummaryItem(name: "Line Number", description: self.lineNumberMode.description),
            localizedSummaryItem(name: "Invisible Characters", description: self.invisibleCharsMode.description),
            
            localizedSummaryItem(name: "Print Header", description: self.printsHeader ? "On" : "Off"),
            localizedSummaryItem(name: "Primary Header", description: self.primaryHeaderContent.description),
            localizedSummaryItem(name: "Primary Header Alignment", description: self.primaryHeaderContent.description),
            localizedSummaryItem(name: "Primary Header", description: self.secondaryHeaderContent.description),
            localizedSummaryItem(name: "Primary Header Alignment", description: self.secondaryHeaderAlignment.description),
            
            localizedSummaryItem(name: "Print Footer", description: self.printsFooter ? "On" : "Off"),
            localizedSummaryItem(name: "Primary Footer", description: self.primaryFooterContent.description),
            localizedSummaryItem(name: "Primary Footer Alignment", description: self.primaryFooterAlignment.description),
            localizedSummaryItem(name: "Primary Footer", description: self.secondaryFooterContent.description),
            localizedSummaryItem(name: "Primary Footer Alignment", description: self.secondaryFooterAlignment.description),
        ]
    }
    
    
    
    // MARK Private Methods
    
    /// cast representedObject to NSPrintInfo
    private var printInfo: NSPrintInfo? {
        
        return self.representedObject as? NSPrintInfo
    }
    
    
    /// update popup menu for color setting
    private func setupColorMenu() {
        
        let themeNames = ThemeManager.shared.settingNames
        
        guard let popupButton = self.colorPopupButton else { return }
        
        popupButton.removeAllItems()
        
        // build popup button
        popupButton.addItem(withTitle: ThemeName.blackAndWhite)
        popupButton.menu?.addItem(.separator())
        
        popupButton.addItem(withTitle: NSLocalizedString("Theme", comment: ""))
        popupButton.lastItem?.isEnabled = false
        
        for themeName in themeNames {
            popupButton.addItem(withTitle: themeName)
            popupButton.lastItem?.indentationLevel = 1
        }
        
        // select "Black and White" if there is nothing to select
        if themeNames.contains(self.theme) {
            popupButton.selectItem(withTitle: self.theme)
        } else {
            popupButton.selectItem(at: 0)
        }
    }
    
    
    /// KVO compatible setter for Cocoa print setting
    private func setSettingValue(_ value: Any?, forKey key: PrintSettingKey) {
        
        self.setValue(value, forKeyPath: self.settingPath(forKey: key))
    }
    
    
    /// KVO compatible getter for Cocoa print setting
    private func settingValue(forKey key: PrintSettingKey) -> Any? {
        
        return self.value(forKeyPath: self.settingPath(forKey: key))
    }
    
    
    /// return keyPath to the given setting key
    private func settingPath(forKey key: PrintSettingKey) -> String {
        
        return "representedObject.dictionary." + key.rawValue
    }
    
    
    
    // MARK: Setting Accessors
    
    /// print theme
    dynamic var theme: String {
        
        get {
            return self.settingValue(forKey: .theme) as? String ?? ThemeName.blackAndWhite
        }
        set {
            self.setSettingValue(newValue, forKey: .theme)
        }
    }
    
    
    /// whether draws line number
    dynamic var lineNumberMode: PrintLineNmuberMode {
        
        get {
            return PrintLineNmuberMode(rawValue: (self.settingValue(forKey: .lineNumber) as? Int) ?? 0) ?? .no
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .lineNumber)
        }
    }
    
    
    /// whether draws invisible characters
    dynamic var invisibleCharsMode: PrintInvisiblesMode {
        
        get {
            return PrintInvisiblesMode(rawValue: (self.settingValue(forKey: .invisibles) as? Int) ?? 0) ?? .no
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .invisibles)
        }
    }
    
    
    /// whether prints header
    dynamic var printsHeader: Bool {
        
        get {
            return (self.settingValue(forKey: .printsHeader) as? Bool) ?? false
        }
        set {
            self.setSettingValue(newValue, forKey: .printsHeader)
        }
    }
    
    
    /// primary header item content type
    dynamic var primaryHeaderContent: PrintInfoType {
        
        get {
            return PrintInfoType(self.settingValue(forKey: .primaryHeaderContent) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .primaryHeaderContent)
        }
    }
    
    
    /// primary header item align
    dynamic var primaryHeaderAlignment: AlignmentType {
        
        get {
            return AlignmentType(self.settingValue(forKey: .primaryHeaderAlignment) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .primaryHeaderAlignment)
        }
    }
    
    
    /// secondary header item content type
    dynamic var secondaryHeaderContent: PrintInfoType {
        
        get {
            return PrintInfoType(self.settingValue(forKey: .secondaryHeaderContent) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .secondaryHeaderContent)
        }
    }
    
    
    /// secondary header item align
    dynamic var secondaryHeaderAlignment: AlignmentType {
        
        get {
            return AlignmentType(self.settingValue(forKey: .secondaryHeaderAlignment) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .secondaryHeaderAlignment)
        }
    }
    
    
    /// whether prints footer
    dynamic var printsFooter: Bool {
        
        get {
            return (self.settingValue(forKey: .printsFooter) as? Bool) ?? false
        }
        set {
            self.setSettingValue(newValue, forKey: .printsFooter)
        }
    }
    
    
    /// primary footer item content type
    dynamic var primaryFooterContent: PrintInfoType {
        
        get {
            return PrintInfoType(self.settingValue(forKey: .primaryFooterContent) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .primaryFooterContent)
        }
    }
    
    
    /// primary footer item align
    dynamic var primaryFooterAlignment: AlignmentType {
        
        get {
            return AlignmentType(self.settingValue(forKey: .primaryFooterAlignment) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .primaryFooterAlignment)
        }
    }
    
    
    /// secondary footer item content type
    dynamic var secondaryFooterContent: PrintInfoType {
        
        get {
            return PrintInfoType(self.settingValue(forKey: .secondaryFooterContent) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .secondaryFooterContent)
        }
    }
    
    
    /// secondary footer item align
    dynamic var secondaryFooterAlignment: AlignmentType {
        
        get {
            return AlignmentType(self.settingValue(forKey: .secondaryFooterAlignment) as? Int)
        }
        set {
            self.setSettingValue(newValue.rawValue, forKey: .secondaryFooterAlignment)
        }
    }
    
}


/// create dictionary for localizedSummaryItems
private func localizedSummaryItem(name: String, description: String) -> [String: String] {
    
    return [NSPrintPanelAccessorySummaryItemNameKey: NSLocalizedString(name, comment: ""),
            NSPrintPanelAccessorySummaryItemDescriptionKey: NSLocalizedString(description, comment: "")]
}


private extension PrintLineNmuberMode {
    
    var description: String {
        switch self {
        case .no:
            return "Don’t Print"
        case .sameAsDocument:
            return "Same as Document’s Setting"
        case .yes:
            return "Print"
        }
    }
}


private extension PrintInvisiblesMode {
    
    var description: String {
        switch self {
        case .no:
            return "Don’t Print"
        case .sameAsDocument:
            return "Same as Document’s Setting"
        case .all:
            return "Print All"
        }
    }
}


private extension PrintInfoType {
    
    var description: String {
        
        switch self {
        case .none:
            return "None"
        case .syntaxName:
            return "Syntax Name"
        case .documentName:
            return "Document Name"
        case .filePath:
            return "File Path"
        case .printDate:
            return "Print Date"
        case .pageNumber:
            return "Page Number"
        }
    }
}


private extension AlignmentType {
    
    var description: String {
        switch self {
        case .left:
            return "Left"
        case .center:
            return "Center"
        case .right:
            return "Right"
        }
    }
}
