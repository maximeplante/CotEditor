/*
 
 GeneralPaneController.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2015-07-15.
 
 ------------------------------------------------------------------------------
 
 © 2015-2016 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Cocoa

class GeneralPaneController: NSViewController {

    private dynamic var hasUpdater: Bool = false
    private dynamic var prerelease: Bool = false
    
    @IBOutlet private weak var updaterConstraint: NSLayoutConstraint?
    
    
    
    
    // MARK:
    // MARK: View Controller Methods
    
    /// nib name
    override var nibName: String? {
        
        return "GeneralPane"
    }
    
    
    /// setup UI
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // remove updater option on AppStore ver.
        #if APPSTORE
            // cut down height for updater checkbox
            self.view.frame.size.height -= 96
            
            // cut down x-position of visible labels
            self.view.removeConstraint(self.updaterConstraint!)
        #else
            self.hasUpdater = true
            
            if CEUpdaterManager.shared().isPrerelease {
                self.prerelease = true
            } else {
                // cut down height for pre-release note
                self.view.frame.size.height -= 32
            }
        #endif
    }
    
    
    
    // MARK: Action Messages
    
    /// "Enable Auto Save and Versions" checkbox was clicked
    @IBAction func updateAutosaveSetting(_ sender: AnyObject?) {
        
        let currentSetting = CEDocument.autosavesInPlace()
        let newSetting = UserDefaults.standard().bool(forKey: CEDefaultEnablesAutosaveInPlaceKey)
        
        // do nothing if the setting returned to the current one.
        guard currentSetting != newSetting else { return }
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("The change will be applied first at the next launch.", comment: "")
        alert.informativeText = NSLocalizedString("Do you want to restart CotEditor now?", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Restart Now", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Later", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        
        alert.beginSheetModal(for: self.view.window!) { returnCode in
            
            switch returnCode {
            case NSAlertFirstButtonReturn:  // = Restart Now
                relaunchApplication(delay: 3.0)
                
            case NSAlertSecondButtonReturn:  // = Later
                break  // do nothing
                
            case NSAlertThirdButtonReturn:  // = Cancel
                UserDefaults.standard().set(!newSetting, forKey: CEDefaultEnablesAutosaveInPlaceKey)
                
            default: break
            }
        }
    }
    
}



// MARK: Private Functions

/// relaunch application itself with delay
private func relaunchApplication(delay: Float) {
    
    let command = String(format: "sleep %f; open \"%@\"", delay, Bundle.main().bundlePath)
    
    let task = Task()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", command]
    task.launch()
    
    NSApp.terminate(nil)
}