//
//  vipNomalMessage.h
//  PreciousMetalDistributionSystem
//
//  Created by Just one on 2019/7/2.
//  Copyright © 2019年 zhangyalei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 姓名,等级,卡号,积分
 马丁,普卡,6236609999,9860
 王立,金卡,6630009999,48860
 李想,白金卡,8230009999,98860
 张三,钻石卡,9230009999,198860
 */
@interface vipNomalMessage : NSObject
@property (nonatomic,copy)NSString *name;//姓名
@property (nonatomic,copy)NSString *vipType;//等级
@property (nonatomic,copy)NSString *cardNumber;//账号
@property (nonatomic,copy)NSString *integral;//积分

@end

NS_ASSUME_NONNULL_END
