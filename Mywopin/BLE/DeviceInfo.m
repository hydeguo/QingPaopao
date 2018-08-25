//
//  DeviceInfo.m
//  智能控制系统
//
//  Created by rf on 15/7/17.
//  Copyright (c) 2015年 wangli. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo

- (NSString *)showName
{
    NSString *orginName = _name;
    NSString *name = orginName;
    if (orginName.length > 6) {
        name = [NSString stringWithFormat:@"%@***%@",[orginName substringToIndex:2],[orginName substringFromIndex:orginName.length - 4]];
    }
    else if (orginName.length > 4) {
        name = [NSString stringWithFormat:@"%@***%@",[orginName substringToIndex:2],[orginName substringFromIndex:orginName.length - 2]];
    }
    else if (orginName.length > 2) {
        name = [NSString stringWithFormat:@"%@***%@",[orginName substringToIndex:1],[orginName substringFromIndex:orginName.length - 1]];
    }
    if (name.length == 0) {
        name = @"氢泡泡水杯";
    }
    return name;
}
@end
