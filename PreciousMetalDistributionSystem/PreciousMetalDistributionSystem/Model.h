//
//  Model.h
//  PreciousMetalDistributionSystem
//
//  Created by Just one on 2019/7/2.
//  Copyright © 2019年 zhangyalei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Model : NSObject
@property (nonatomic,copy)NSString *memberId;
@property (nonatomic,copy)NSString *orderId;
@property (nonatomic,strong)NSArray *payments;
@property (nonatomic,strong)NSArray *items;
@property (nonatomic,strong)NSArray *discountCards;
@property (nonatomic,copy)NSString *createTime;

@end
@interface itemsList : NSObject
@property (nonatomic,copy)NSString *amount;
@property (nonatomic,copy)NSString *product;
@end

@interface paymentsList : NSObject
@property (nonatomic,copy)NSString *amount;
@property (nonatomic,copy)NSString *type;
@end
NS_ASSUME_NONNULL_END

