//
//  ZHUseFDModel+UIModel.h
//  PracticeSaftSystem
//
//  Created by 逸信Mac on 16/9/6.
//  Copyright © 2016年 逸信Mac. All rights reserved.
//

#import "ZHUseFDModel.h"
#import "ZHCMessage.h"
@interface ZHUseFDModel (UIModel)
+(ZHUseFDModel *)ZHUseFDModelFromUIModel:(ZHCMessage *)Model;
@end
