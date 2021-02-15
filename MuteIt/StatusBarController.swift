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
    private var unMuteVolume: Float
    private var statusBarButton: NSStatusBarButton
    
    init() {
        statusBarButton = NSStatusBarButton.init()
        statusBar = NSStatusBar.init()
        // Creating a status bar item having a fixed length
        statusItem = statusBar.statusItem(withLength: 28.0)
        isMute = true
        unMuteVolume = 0.5
        setInpuLevel(isMute: isMute)
        
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
                setInpuLevel(isMute: isMute)
            }
            else {
                isMute = true
                self.statusBarButton.image =  NSImage(named: "MuteIcon")
                self.statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
                self.statusBarButton.image?.isTemplate = true
                setInpuLevel(isMute: isMute)
            }
        }
    }
    
    func setInpuLevel(isMute: Bool) {
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
        
        var volume = Float32(0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMaster)
        
        if(isMute) {
            // Get Volume
            AudioObjectGetPropertyData(
                deviceID,
                &volumePropertyAddress,
                0,
                nil,
                &volumeSize,
                &volume)
            self.unMuteVolume = volume
            volume = 0
        } else {
            if self.unMuteVolume == 0 {
                self.unMuteVolume = 0.5
            }
            volume = self.unMuteVolume
        }
        
        // Set Volume
        AudioObjectSetPropertyData(
            deviceID,
            &volumePropertyAddress,
            0,
            nil,
            volumeSize,
            &volume)
        
        // Set Mute/Unmute
        var mute = 0
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
