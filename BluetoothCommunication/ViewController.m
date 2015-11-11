//
//  ViewController.m
//  BluetoothCommunication
//
//  Created by admin on 11/10/15.
//  Copyright © 2015 thanhlt. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
{
    IOBluetoothDeviceSelectorController         *_deviceSelector;
    IOBluetoothSDPUUID                          *_sppServiceUUID;
    IOBluetoothSDPServiceRecord                 *_sppServiceRecord;
    IOBluetoothRFCOMMChannel                    *_mRFCOMMChannel;
    
    NSArray                                     *_deviceArray;
    IOBluetoothDevice                           *_deviceConnected;
    NSString                                    *_stringData;
    
    NSString                                    *_filePath;
    NSString                                    *_fileAtPath;
    
    int                                         _lines;
    BOOL                                        _isRetry;
    
    
}

#pragma mark - Initialization
- (void)setDefaultVariables
{
    _isRetry = false;
    _lines = 0;
    if (_filePath == nil) {
        _filePath = DEFAULT_PATH_FOLDER_LOCAL;
    }
}
#pragma mark - NSTextView


-(void)logOnTextView:(NSString *)text
{
    NSString *string = [_textView string];
    
    id new = [string stringByAppendingString:text];
    
    [_textView setString: new];
    
}


#pragma Lifecycle view

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self setDefaultVariables];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Selector buttons
- (IBAction)openSelectorController:(id)sender {
    IOBluetoothRFCOMMChannel *channel;
    
    UInt8 rfcommChannelID;
    [self logOnTextView: @"Attempting to connect\n" ];
    
    // The device selector will provide UI to the end user to find a remote device
    _deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
    
    _sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
    [_deviceSelector addAllowedUUID:_sppServiceUUID];
    
    if ( _deviceSelector == nil ) {
        [self logOnTextView: @"Error - unable to allocate IOBluetoothDeviceSelectorController.\n" ];
        return;
    }
    
    if ( [_deviceSelector runModal] != kIOBluetoothUISuccess ) {
        [self logOnTextView: @"User has cancelled the device selection.\n" ];
        return;
    }
    
    _deviceArray = [_deviceSelector getResults];
    if ( ( _deviceArray == nil ) || ( [_deviceArray count] == 0 ) ) {
        [self logOnTextView: @"Error - no selected device.  ***This should never happen.***\n" ];
        return;
    }
    
    _deviceConnected = [_deviceArray objectAtIndex:0];
    _sppServiceRecord = [_deviceConnected getServiceRecordForUUID:_sppServiceUUID];
    if ( _sppServiceRecord == nil ) {
        [self logOnTextView:@"Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n" ];
        return;
    }
    if ( [_sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess ) {
        [self logOnTextView: @"Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n" ];
        return;
    }
    
    if ( ( [_deviceConnected openRFCOMMChannelAsync:&channel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) && (channel != nil)) {
        [self logOnTextView: @"Error - open sequence failed.***\n" ];
        [_deviceConnected closeConnection];
        return;
    }
    _mRFCOMMChannel = channel;

}

- (IBAction)sendMessageForRecord:(id)sender {
    
    [self sendMessage:_textMessage.title];
    [self logOnTextView:@"Sending Message\n"];
    _stringData = @"";
    [_textMessage setTitle:@""];
    
    [self.buttonSend setEnabled:NO];
}


- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
    
    if ( error != kIOReturnSuccess ) {
        [self logOnTextView:@"Error - failed to open the RFCOMM channel with error %08lx.\n"];
        
        return;
    }
    else{
        [self.buttonConnect setEnabled:NO];
        [self logOnTextView:[[NSString alloc] initWithFormat:@"Connect with device %@\n",_deviceConnected.name]];
    }
    
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
    
    if (_lines == 0)
        [self logOnTextView:@"Send success !!!!!\n"];
    NSString  *message = [[NSString alloc] initWithBytes:dataPointer length:dataLength encoding:NSShiftJISStringEncoding];
    
    
    _stringData = [_stringData stringByAppendingString:message];
    [self logOnTextView:message];
    [self logOnTextView:@"\n"];
    
}

- (void)sendMessage:(NSString*)stringSend
{
    
    char buffer[ [stringSend length]];
    for (int i=0;i<[stringSend length];i++)
    {
        buffer[i] = [stringSend characterAtIndex:i];
    }
    // Append \r\n
    [_mRFCOMMChannel writeSync:&buffer length:[stringSend length]];
    
}



@end
