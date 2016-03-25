//
//  ViewController.m
//  BeaconTest
//
//  Created by Wayne Hartman on 9/29/15.
//  Copyright © 2015 Wayne Hartman. All rights reserved.
//

#import "ViewController.h"

@import CoreBluetooth;

@interface ViewController () <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (CBPeripheralManager *)peripheralManager {
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc] init];
        _peripheralManager.delegate = self;
    }

    return _peripheralManager;
}

#pragma mark - Actions

- (IBAction)didSelectAdvertiseButton:(id)sender {
    [self startAdvertising];
}

- (IBAction)didSelectStopAdvertingButton:(id)sender {
    [self.peripheralManager stopAdvertising];
}

#pragma mark - Advertising

- (void)startAdvertising {
    // Advertising fails if the peripheral manager is not in the powered on state.
    // The first time, it's likely to be powered off on Apple TV.
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn
        && !self.peripheralManager.isAdvertising) {
        NSDictionary *advertisingData = [self beaconDataWithUUID:[[NSUUID alloc] initWithUUIDString:@"E2AD5810-554E-11E4-9E35-164230D1DF67"]
                                                           major:1000
                                                           minor:56
                                                   measuredPower:-59];
        [self.peripheralManager startAdvertising:advertisingData];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"Changed state: %li", (long)peripheral.state);
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self startAdvertising];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    if (error) {
        NSLog(@"There was an error advertising: %@", error);
    }
}

/**
 *  Code adapted from http://www.blendedcocoa.com/blog/2013/11/02/mavericks-as-an-ibeacon/
 */
- (NSDictionary *)beaconDataWithUUID:(NSUUID *)uuid major:(uint16_t)major minor:(uint16_t)minor measuredPower:(NSInteger)measuredPower {
    static NSString *iBeaconKey = @"kCBAdvDataAppleBeaconKey";

    unsigned char advertisingData[21] = { 0 };
    [uuid getUUIDBytes:(unsigned char *)&advertisingData];

    advertisingData[16] = (unsigned char)(major >> 8);
    advertisingData[17] = (unsigned char)(major & 255);
    advertisingData[18] = (unsigned char)(minor >> 8);
    advertisingData[19] = (unsigned char)(minor & 255);
    advertisingData[20] = measuredPower;

    NSData *data = [NSData dataWithBytes:advertisingData length:sizeof(advertisingData)];

    return @{ iBeaconKey : data };
}

@end
