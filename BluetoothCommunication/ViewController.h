//
//  ViewController.h
//  BluetoothCommunication
//
//  Created by admin on 11/10/15.
//  Copyright © 2015 thanhlt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>

#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>

#define DEFAULT_PATH_FOLDER_LOCAL           @"/Volumes/Untitled2/"

@interface ViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTextView *textView;
- (IBAction)openSelectorController:(id)sender;
- (IBAction)sendMessageForRecord:(id)sender;
@property (weak) IBOutlet NSTextFieldCell *textMessage;
@property (weak) IBOutlet NSButton *buttonSend;
@property (weak) IBOutlet NSButton *buttonConnect;

@end

