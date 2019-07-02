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

@interface ViewController ()
@property (nonatomic,assign) VipCardTypes type; //会员类型类型
@property (nonatomic,strong)NSArray *array;//折扣数组
@property (nonatomic,strong)NSMutableArray *dataArray;//商品数组
@property (nonatomic,strong)NSMutableArray *payTypesArray;//支付类型数组
@property (strong, nonatomic) UIDocumentInteractionController *documentController;
@property (nonatomic,copy)NSString *logs;
@end

@implementation ViewController
//初始化数组
- (NSArray *)array {
    if (!_array) {
        self.array = [NSArray array];
    }
    return _array;
}
//初始化数组

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
//初始化数组

- (NSMutableArray *)payTypesArray {
    if (!_payTypesArray) {
        self.payTypesArray = [NSMutableArray array];
    }
    return _payTypesArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    NSLog(@"方鼎银行贵金属购买凭证\n");
//    [self writeToFileWithTxt:@"方鼎银行贵金属购买凭证\n"];
    //读取数据
    NSDictionary *dic  = [self readLocalFileWithName:@"profile"];
    Model *demo = [[Model alloc]init];
    [demo setValuesForKeysWithDictionary:dic];
//    NSLog(@"商品及数量          单价            金额 ");
    self.logs = @"商品及数量          单价            金额";
//    [self writeToFileWithTxt:@"商品及数量          单价            金额"];
    //存储折扣券
    self.array = demo.discountCards;
    //获取支付类型
    for (NSDictionary *dic in demo.payments) {
        paymentsList *model = [[paymentsList alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.payTypesArray addObject:model];
    }
    //获取商品列表
    for (NSDictionary *dic in demo.items) {
        itemsList *model = [[itemsList alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }
    //计算总价
    CGFloat totalPrice = 0.00;
    for (itemsList *list in self.dataArray) {
//        NSLog(@"(%@)%@x%@,%@,%.2f\n",list.product,[self CommodityName:list.product],list.amount,[NSString stringWithFormat:@"%.2f",[self CommodityPrices:list.product]],[list.amount integerValue]*[self CommodityPrices:list.product]);
//        [self writeToFileWithTxt:[NSString stringWithFormat:@"(%@)%@x%@,%@,%.2f",list.product,[self CommodityName:list.product],list.amount,[NSString stringWithFormat:@"%.2f",[self CommodityPrices:list.product]],[list.amount integerValue]*[self CommodityPrices:list.product]]];
        self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,[NSString stringWithFormat:@"(%@)%@x%@,%@,%.2f",list.product,[self CommodityName:list.product],list.amount,[NSString stringWithFormat:@"%.2f",[self CommodityPrices:list.product]],[list.amount integerValue]*[self CommodityPrices:list.product]]];
        totalPrice += [list.amount integerValue]*[self CommodityPrices:list.product];
    }
//    NSLog(@"合计:%.2f\n",totalPrice);
//    [self writeToFileWithTxt:[NSString stringWithFormat:@"合计:%.2f\n",totalPrice]];
    self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,[NSString stringWithFormat:@"合计:%.2f\n",totalPrice]];

//    NSLog(@"优惠清单:\n");
//    [self writeToFileWithTxt:@"优惠清单:"];
    self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,@"优惠清单:"];

    //计算总优惠
    CGFloat disTotal =  [self disCountTotal:self.dataArray];
//    NSLog(@"应收合计:%.2f",totalPrice - disTotal);
//    [self writeToFileWithTxt:[NSString stringWithFormat:@"应收合计:%.2f",totalPrice - disTotal]];
    self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,[NSString stringWithFormat:@"应收合计:%.2f",totalPrice - disTotal]];

//    NSLog(@"收款:\n");
//    [self writeToFileWithTxt:@"收款:"];
    self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,@"收款:"];

    //输出打折券
//    for (NSString *str in self.array) {
//        NSLog(@"%@\n",str);
    if (self.array.count>0) {
        switch (self.array.count) {
            case 1:
//                [self writeToFileWithTxt:[NSString stringWithFormat:@" %@",[self.array firstObject]]];
                self.logs = [NSString stringWithFormat:@"%@\n %@",self.logs,[self.array firstObject]];

                break;
            case 2:
//                [self writeToFileWithTxt:[NSString stringWithFormat:@" %@",[self.array firstObject]]];
                self.logs = [NSString stringWithFormat:@"%@\n %@",self.logs,[self.array firstObject]];
                self.logs = [NSString stringWithFormat:@"%@\n %@",self.logs,[self.array lastObject]];

//                [self writeToFileWithTxt:[NSString stringWithFormat:@" %@",[self.array lastObject]]];
                break;
            default:
                break;
        }
    }

//    }
//    NSLog(@"余额支付:%.2f",totalPrice - disTotal);
//    [self writeToFileWithTxt:[NSString stringWithFormat:@" 余额支付:%.2f\n",totalPrice - disTotal]];
    self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,[NSString stringWithFormat:@" 余额支付:%.2f\n",totalPrice - disTotal]];

    //获取商户信息
    vipNomalMessage *vipModelTwo = [self messageWithMemberId:demo.memberId andIntegral:0];
    //获取支付总积分
    NSInteger totalInter = (totalPrice - disTotal) * [self multipleIntegralForVipType:[self frominterFor:vipModelTwo.integral]];
    //获取商户原有等级类型
    VipCardTypes typeOne = [self frominterFor:vipModelTwo.integral];
    //更新商户积分
    vipNomalMessage *vipModelThree = [self messageWithMemberId:demo.memberId andIntegral:totalInter];
    //获取商户支付完成等级类型
    VipCardTypes typeTwo = [self frominterFor:vipModelThree.integral];
    NSString *vipUpdate = @"";
    if (typeOne != typeTwo) {
        vipUpdate = [NSString stringWithFormat:@"恭喜您升级为%@客户!",[self vipTypeForIntegral:vipModelThree.integral]];
    }
//    NSLog(@"客户等级与积分：\n新增积分:%ld\n%@",(long)totalInter,vipUpdate);
//    [self writeToFileWithTxt:[NSString stringWithFormat:@"客户等级与积分：\n新增积分:%ld\n%@",(long)totalInter,vipUpdate]];
    self.logs = [NSString stringWithFormat:@"%@\n%@\n",self.logs,[NSString stringWithFormat:@"客户等级与积分：\n新增积分:%ld\n%@",(long)totalInter,vipUpdate]];
    //根据客户卡号获取会员信息
    vipNomalMessage *vipModel = [self messageWithMemberId:demo.memberId andIntegral:totalInter];

    [self writeToFileWithTxt:[NSString stringWithFormat:@"方鼎银行贵金属购买凭证\n\n销售单号:%@ 日期:%@\n客户卡号:%@ 会员姓名:%@ 客户等级:%@ 累计积分:%@\n\n%@",demo.orderId,demo.createTime,demo.memberId,vipModel.name,vipModel.vipType,vipModel.integral,self.logs]];
}
//读取本地文件 name:文件名
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}
//根据商户积分返回商户等级类型
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
//根据商户等级返回积分倍数.
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
//根据商品编号,返回商品价格
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
//根据商品编号,返回商品名称
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
//计算每种商品的总价格
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
//组建商户基本信息
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
        model.integral = [NSString stringWithFormat:@"%ld",9860  + addIntegral];
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
//根据积分返回等级汉子形式
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
//返回所有商品优惠合计
- (CGFloat )disCountTotal:(NSMutableArray *)dataArray {
    CGFloat disTotalMoney = 0.00;
    for (itemsList *model in dataArray) {
     
      CGFloat total =  [model.amount integerValue]*[self CommodityPrices:model.product];
//      NSLog(@"优惠券%@",self.array);
      CGFloat disTotal =  [self payMoneyThisPro:model.product withNumbers:[model.amount integerValue] andDiscountCards:self.array];
//        NSLog(@"原价格:%.2f,优惠后价格:%.2f",total,disTotal);
        if (total > disTotal) {
//            NSLog(@"(%@)%@:%.2f",model.product,[self CommodityName:model.product],-(total - disTotal));
            disTotalMoney += -(total - disTotal);
//            [self writeToFileWithTxt:[NSString stringWithFormat:@"(%@)%@:%.2f",model.product,[self CommodityName:model.product],-(total - disTotal)]];
            self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,[NSString stringWithFormat:@"(%@)%@:%.2f",model.product,[self CommodityName:model.product],-(total - disTotal)]];

        }
    }
//    NSLog(@"优惠合计:%.2f",-disTotalMoney);
//    [self writeToFileWithTxt:[NSString stringWithFormat:@"优惠合计:%.2f\n",-disTotalMoney]];
    self.logs = [NSString stringWithFormat:@"%@\n%@",self.logs,[NSString stringWithFormat:@"优惠合计:%.2f\n",-disTotalMoney]];

    return -disTotalMoney;
}
//将日志写入txt
//不论是创建还是写入只需调用此段代码即可 如果文件未创建 会进行创建操作
- (void)writeToFileWithTxt:(NSString *)string{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized (self) {
            //获取沙盒路径
            NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            //获取文件路径
            NSString *theFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PreciousMetalDistributionSystem.text"];
            NSLog(@"%@",theFilePath);
            //创建文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //如果文件不存在 创建文件
            if(![fileManager fileExistsAtPath:theFilePath]){
                NSString *str = @"";
                [str writeToFile:theFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
//            NSLog(@"所写内容=%@",string);
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:theFilePath];
            [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
            NSData* stringData  = [[NSString stringWithFormat:@"%@\n",string] dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:stringData]; //追加写入数据
            [fileHandle closeFile];
        }
//    });
}
@end
