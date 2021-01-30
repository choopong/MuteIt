//
//  StatusBarController.swift
//  MuteIt
//
//  Created by Choopong on 29/1/21.
//

import AppKit
import CoreAudio

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var isMute: Bool
    private var statusBarButton: NSStatusBarButton
    
    init() {
        statusBarButton = NSStatusBarButton.init()
        statusBar = NSStatusBar.init()
        // Creating a status bar item having a fixed length
        statusItem = statusBar.statusItem(withLength: 28.0)
        isMute = true
        setInpuLevel(level: 0)
        
        if let statusBarButton = statusItem.button {
            self.statusBarButton = statusBarButton
            self.statusBarButton.image = NSImage(named: "MuteIcon")
            self.statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            self.statusBarButton.image?.isTemplate = true
            self.statusBarButton.action = #selector(toggleMute(sender:))
            self.statusBarButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
            self.statusBarButton.target = self
        }
    }
    
    @objc func toggleMute(sender: AnyObject) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            print("Right click")
        } else {
            if(isMute) {
                isMute = false
                self.statusBarButton.image = NSImage(named: "UnmuteIcon")
                self.statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
                self.statusBarButton.image?.isTemplate = true
                setInpuLevel(level: 1)
            }
            else {
                isMute = true
                self.statusBarButton.image =  NSImage(named: "MuteIcon")
                self.statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
                self.statusBarButton.image?.isTemplate = true
                setInpuLevel(level: 0)
            }
        }
    }
    
    func setInpuLevel(level: Int) {
        // Get default audio inout id
        var deviceID = AudioDeviceID(0)
        var deviceIDSize = UInt32(MemoryLayout.size(ofValue: deviceID))
        
        var defaultInputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster)
        
        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &defaultInputDevicePropertyAddress,
            0,
            nil,
            &deviceIDSize,
            &deviceID)
        
        // Set Volume
        var volume = Float32(level)
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMaster)
        
        AudioObjectSetPropertyData(
            deviceID,
            &volumePropertyAddress,
            0,
            nil,
            volumeSize,
            &volume)
        
        // Set Mute
        var mute = Int32(0)
        if(volume == 0) {
            mute = 1
        }
        let muteSize = UInt32(MemoryLayout.size(ofValue: mute))
        
        var mutePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMaster)
        
        AudioObjectSetPropertyData(
            deviceID,
            &mutePropertyAddress,
            0,
            nil,
            muteSize,
            &mute)
    }
}
