//
//  ViewController.m
//  PreciousMetalDistributionSystem
//
//  Created by Just one on 2019/7/2.
//  Copyright © 2019年 zhangyalei. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"
#import "vipNomalMessage.h"

//会员卡类型
typedef enum VIPCardType {
    ordinaryCard,//普卡
    goldCard,//金卡
    platinumCard,//白金卡
    diamondCard//钻石卡
} VipCardTypes;

//定义枚举类型
typedef enum favourableActivityType {
    none,//不能使用优惠
    foldOf95,//95折
    foldOf90,//9折
    fullReduction1000_10,//1000-10
    fullReduction2000_30,//1000-10
    fullReduction3000_350,//1000-10
    TheThirdhalfPrice,//第三件半价
    fullReduction4_1,//满三送一
} favourableActivityTypes;

@interface ViewController ()
@property (nonatomic,assign) VipCardTypes type; //会员类型类型
@property (nonatomic,assign) favourableActivityTypes favourableTType; //活动类型
@property (nonatomic,strong)NSArray *array;//折扣数组
@property (nonatomic,strong)NSMutableArray *dataArray;//商品数组
@property (nonatomic,strong)NSMutableArray *payTypesArray;//支付类型数组
@property (nonatomic,strong)UILabel *label;

@end

@implementation ViewController
- (NSArray *)array {
    if (!_array) {
        self.array = [NSArray array];
    }
    return _array;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)payTypesArray {
    if (!_payTypesArray) {
        self.payTypesArray = [NSMutableArray array];
    }
    return _payTypesArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 200, 300)];
    self.label.numberOfLines = 0;
    [self.view addSubview:self.label];
    NSLog(@"方鼎银行贵金属购买凭证\n");
 NSDictionary *dic  = [self readLocalFileWithName:@"profile"];
//    NSLog(@"%@",dic);
    Model *demo = [[Model alloc]init];
    [demo setValuesForKeysWithDictionary:dic];
    vipNomalMessage *vipModel = [self messageWithMemberId:demo.memberId andIntegral:0];
    NSLog(@"\n销售单号:%@ 日期:%@\n客户卡号:%@ 会员姓名:%@ 客户等级:%@ 累计积分:%@",demo.orderId,demo.createTime,demo.memberId,vipModel.name,vipModel.vipType,vipModel.integral);
//    NSLog(@"商品及数量          单价            金额 ");
    self.array = demo.discountCards;
//    NSLog(@"%@",demo.discountCards);

    for (NSDictionary *dic in demo.payments) {
        paymentsList *model = [[paymentsList alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.payTypesArray addObject:model];
    }
    for (NSDictionary *dic in demo.items) {
        itemsList *model = [[itemsList alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }
    CGFloat totalPrice = 0.00;
    for (itemsList *list in self.dataArray) {
//     CGFloat price  = [self payMoneyThisPro:list.product withNumbers:[list.amount integerValue] andDiscountCards:self.array];
//        NSLog(@"名称:%@优惠后价格:%.2f",[self CommodityName:list.product],price);
        NSLog(@"(%@)%@x%@,%@,%.2f\n",list.product,[self CommodityName:list.product],list.amount,[NSString stringWithFormat:@"%.2f",[self CommodityPrices:list.product]],[list.amount integerValue]*[self CommodityPrices:list.product]);
        totalPrice += [list.amount integerValue]*[self CommodityPrices:list.product];
    }
    
    NSLog(@"合计:%.2f\n",totalPrice);
    NSLog(@"优惠清单:\n");
    CGFloat disTotal =  [self sssssssssss:self.dataArray];
    
    NSLog(@"应收合计:%.2f",totalPrice - disTotal);
    NSLog(@"收款:\n");
    for (NSString *str in self.array) {
        NSLog(@"%@\n",str);
    }
//    paymentsList *payList = [self.payTypesArray firstObject];
//    NSLog(@"%@:%@\n",payList.type,payList.amount);
    NSLog(@"余额支付:%.2f",totalPrice - disTotal);
    vipNomalMessage *vipModelTwo = [self messageWithMemberId:demo.memberId andIntegral:0];
    NSInteger totalInter = (totalPrice - disTotal) * [self multipleIntegralForVipType:[self frominterFor:vipModelTwo.integral]];
    
    VipCardTypes typeOne = [self frominterFor:vipModelTwo.integral];
    vipNomalMessage *vipModelThree = [self messageWithMemberId:demo.memberId andIntegral:totalInter];

    VipCardTypes typeTwo = [self frominterFor:vipModelThree.integral];
    NSString *vipUpdate = @"";

    if (typeOne != typeTwo) {
        vipUpdate = [NSString stringWithFormat:@"恭喜您升级为%@客户!",[self vipTypeForIntegral:vipModelThree.integral]];
    }
    NSLog(@"客户等级与积分：\n新增积分:%ld\n%@",(long)totalInter,vipUpdate);
    self.label.text = [NSString stringWithFormat:@"%.2f",totalPrice];
    
}
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}
- (VipCardTypes )frominterFor:(NSString *)integral {
    NSInteger integ = [integral integerValue];
    if (integ < 10000) {
        return ordinaryCard;
    }
    if (integ >= 10000 && integ < 50000) {
        return goldCard;
    }
    if (integ >= 50000 && integ < 100000) {
        return platinumCard;
    }
    if (integ >= 100000) {
        return diamondCard;
    }
    return ordinaryCard;
}
- (CGFloat)multipleIntegralForVipType:(VipCardTypes )type {
    switch (type) {
        case ordinaryCard:
            return 1.0;
            break;
        case goldCard:
            return 1.5;
            break;
        case platinumCard:
            return 1.8;
            break;
        case diamondCard:
            return 2.0;
            break;
        default:
            break;
    }
}
- (CGFloat )CommodityPrices:(NSString *)shop {
    if ([shop isEqualToString:@"001001"]) {
        return 998.00;
    }
    if ([shop isEqualToString:@"001002"]) {
        return 1380.00;
    }
    if ([shop isEqualToString:@"003001"]) {
        return 1580.00;
    }
    if ([shop isEqualToString:@"003002"]) {
        return 980.00;
    }
    if ([shop isEqualToString:@"002002"]) {
        return 998.00;
    }
    if ([shop isEqualToString:@"002001"]) {
        return 1080.00;
    }
    if ([shop isEqualToString:@"002003"]) {
        return 698.00;
    }
    return 0.00;
}
- (NSString *)CommodityName:(NSString *)shop {
    if ([shop isEqualToString:@"001001"]) {
        return @"世园会五十国钱币册";
    }
    if ([shop isEqualToString:@"001002"]) {
        return @"2019北京世园会纪念银章大全40g";
    }
    if ([shop isEqualToString:@"003001"]) {
        return @"招财进宝";
    }
    if ([shop isEqualToString:@"003002"]) {
        return @"水晶之恋";
    }
    if ([shop isEqualToString:@"002002"]) {
        return @"中国经典钱币套装";
    }
    if ([shop isEqualToString:@"002001"]) {
        return @"守扩之羽比翼双飞4.8g";
    }
    if ([shop isEqualToString:@"002003"]) {
        return @"中国银象棋12g";
    }
    return @"";
}
- (CGFloat )payMoneyThisPro:(NSString *)proId withNumbers:(NSInteger )number andDiscountCards:(NSArray *)array{
    NSString *disOne,*disTwo;
    
    if (array.count>0) {
        switch (array.count) {
            case 1:{
          disOne = [array firstObject];
        disOne = [disOne stringByReplacingOccurrencesOfString:@"折券" withString:@""];
//                NSLog(@"%@",disOne);
            }
                break;
            case 2:
            {
               disOne = [array firstObject];
                disOne = [disOne stringByReplacingOccurrencesOfString:@"折券" withString:@""];
              disTwo = [array lastObject];
                disTwo = [disTwo stringByReplacingOccurrencesOfString:@"折券" withString:@""];
            }
                break;
            default:
                break;
        }
    }
    
    if ([proId isEqualToString:@"001001"]) {
        return [self CommodityPrices:proId] * number;
    }
    if ([proId isEqualToString:@"001002"]) {
        if ([disOne isEqualToString:@"9"] || [disTwo isEqualToString:@"9"]) {
            return [self CommodityPrices:proId] * number * 0.90;
        }
        return [self CommodityPrices:proId] * number;
    }
    if ([proId isEqualToString:@"003001"]) {
        if ([disOne isEqualToString:@"95"] || [disTwo isEqualToString:@"95"]) {
            return [self CommodityPrices:proId] * number * 0.95;
        }
        return [self CommodityPrices:proId] * number;
    }
    if ([proId isEqualToString:@"003002"]) {
        if (number == 3) {
            return [self CommodityPrices:proId] * 2.5;
        }
        if (number >= 4) {
            return [self CommodityPrices:proId] * (number - 1);
        }
        return [self CommodityPrices:proId] * number;
    }
    if ([proId isEqualToString:@"002002"]) {
        CGFloat price = [self CommodityPrices:proId] * number;
        NSInteger dis30 =  price / 2000.00;
        NSInteger dis10 =  price / 1000.00;
        if (dis30 >= 1) {
            price = [self CommodityPrices:proId] * number - dis30 * 30;
        }else {
            if (dis10>=1) {
                price = [self CommodityPrices:proId] * number - dis10 * 10;
            }
        }
        
        return price;
    }
    if ([proId isEqualToString:@"002001"]) {
        CGFloat priceOne;
        CGFloat priceTwo;
        CGFloat priceThree;
        CGFloat priceFour;
if ([disOne isEqualToString:@"95"] || [disTwo isEqualToString:@"95"]) {
        if (number == 3) {
            priceOne = [self CommodityPrices:proId] * 2.5;
            priceTwo = [self CommodityPrices:proId] * 3 * 0.95;
            return priceOne > priceTwo ? priceTwo : priceOne;
        }
        if (number >= 4) {
            priceThree = [self CommodityPrices:proId] * (number - 1);
            priceFour = [self CommodityPrices:proId] * number * 0.95;
            return priceThree > priceFour ? priceFour : priceThree;
        }
    return [self CommodityPrices:proId] * number * 0.95;

}else {
    if (number == 3) {
        return [self CommodityPrices:proId] * 2.5;
    }
    if (number >= 4) {
        return [self CommodityPrices:proId] * (number - 1);
    }
    return [self CommodityPrices:proId] * number;
}
       
    }
    if ([proId isEqualToString:@"002003"]) {
        if ([disOne isEqualToString:@"9"] || [disTwo isEqualToString:@"9"]) {
            
            CGFloat price = [self CommodityPrices:proId] * number;
            NSInteger dis350 =  price / 3000.00;
            NSInteger dis30 =  price / 2000.00;
            NSInteger dis10 =  price / 1000.00;
            
            if (dis350 >= 1) {
                price = [self CommodityPrices:proId] * number - dis350 * 350 > [self CommodityPrices:proId] * number * 0.9 ? [self CommodityPrices:proId] * number * 0.9 :[self CommodityPrices:proId] * number - dis350 * 350 ;
//                NSLog(@"350:%.2f,9折:%.2f,返回价格:%.2f",[self CommodityPrices:proId] * number - dis350 * 350,[self CommodityPrices:proId] * number * 0.9,price);
                
            }else if (dis30 >= 1) {
                price = [self CommodityPrices:proId] * number - dis30 * 30 > [self CommodityPrices:proId] * number * 0.9 ? [self CommodityPrices:proId] * number * 0.9 : [self CommodityPrices:proId] * number - dis30 * 30;
            }else {
                if (dis10>=1) {
                    price = [self CommodityPrices:proId] * number - dis10 * 10 > [self CommodityPrices:proId] * number * 0.9 ? [self CommodityPrices:proId] * number * 0.9 : [self CommodityPrices:proId] * number - dis10 * 10;
                }
            }

            return price;

        }else {
            CGFloat price = [self CommodityPrices:proId] * number;
            NSInteger dis350 =  price / 3000.00;
            NSInteger dis30 =  price / 2000.00;
            NSInteger dis10 =  price / 1000.00;
            
            if (dis350 >= 1) {
                price = [self CommodityPrices:proId] * number - dis350 * 350;
            }else if (dis30 >= 1) {
                price = [self CommodityPrices:proId] * number - dis30 * 30;
            }else {
                if (dis10>=1) {
                    price = [self CommodityPrices:proId] * number - dis10 * 10;
                }
            }
            return price;
        }
    }
    return 0.00;
}
- (vipNomalMessage *)messageWithMemberId:(NSString *)memberId andIntegral:(NSInteger )addIntegral{
    /*
     姓名,等级,卡号,积分
     马丁,普卡,6236609999,9860
     王立,金卡,6630009999,48860
     李想,白金卡,8230009999,98860
     张三,钻石卡,9230009999,198860
     */
    vipNomalMessage *model = [[vipNomalMessage alloc]init];
    if ([memberId isEqualToString:@"6236609999"]) {
        model.name = @"马丁";
        model.cardNumber = @"6236609999";
        model.integral = [NSString stringWithFormat:@"%ld",9860 + 1242 + addIntegral];
        model.vipType = [self vipTypeForIntegral:model.integral];
    }else if ([memberId isEqualToString:@"6630009999"]) {
        model.name = @"王立";
        model.cardNumber = @"6630009999";
        model.integral = [NSString stringWithFormat:@"%ld",48860 + addIntegral];
        model.vipType = [self vipTypeForIntegral:model.integral];
    }else if ([memberId isEqualToString:@"8230009999"]) {
        model.name = @"李想";
        model.cardNumber = @"8230009999";
        model.integral = [NSString stringWithFormat:@"%ld",98860 + addIntegral];
        model.vipType = [self vipTypeForIntegral:model.integral];
    }else if ([memberId isEqualToString:@"9230009999"]) {
        model.name = @"张三";
        model.cardNumber = @"9230009999";
        model.integral = [NSString stringWithFormat:@"%ld",198860 + addIntegral];
        model.vipType = [self vipTypeForIntegral:model.integral];
    }
    return model;
}
- (NSString *)vipTypeForIntegral:(NSString *)integral {
    NSInteger integ = [integral integerValue];
    if (integ < 10000) {
        return @"普卡";
    }
    if (integ >= 10000 && integ < 50000) {
        return @"金卡";
    }
    if (integ >= 50000 && integ < 100000) {
        return @"白金卡";
    }
    if (integ >= 100000) {
        return @"钻石卡";
    }
    return @"";
}
- (CGFloat )sssssssssss:(NSMutableArray *)dataArray {
    CGFloat disTotalMoney = 0.00;
    for (itemsList *model in dataArray) {
     
      CGFloat total =  [model.amount integerValue]*[self CommodityPrices:model.product];
//      NSLog(@"优惠券%@",self.array);
      CGFloat disTotal =  [self payMoneyThisPro:model.product withNumbers:[model.amount integerValue] andDiscountCards:self.array];
//        NSLog(@"原价格:%.2f,优惠后价格:%.2f",total,disTotal);
        if (total > disTotal) {
            NSLog(@"(%@)%@:%.2f",model.product,[self CommodityName:model.product],-(total - disTotal));
            disTotalMoney += -(total - disTotal);
        }
    }
    NSLog(@"优惠合计:%.2f",-disTotalMoney);
    return -disTotalMoney;
}
@end
