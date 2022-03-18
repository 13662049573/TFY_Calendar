//
//  UIImage+Addtions.m
//  TFY_ChatIMInterface
//
//  Created by 田风有 on 2022/2/11.
//

#import "UIImage+Addtions.h"

@implementation UIImage (Addtions)

+ (UIImage *)tfy_groupIconWithURLArray:(NSArray *)URLArray bgColor:(UIColor *)bgColor {
    UIImageView *imageView = [[UIImageView alloc] init];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for (int i = 0; i<URLArray.count;  i++) {
        id urlData = URLArray[i];
        UIImage *image = [self tfy_groupIconWithURL:urlData];
        [imageArray addObject:image];
    }
    
    imageView.image = [UIImage tfy_groupIconWith:imageArray bgColor:bgColor];
    
    return imageView.image;
}

+ (UIImage *)tfy_groupIconWith:(NSArray *)array bgColor:(UIColor *)bgColor {

    CGSize finalSize = CGSizeMake(100, 100);
    CGRect rect = CGRectZero;
    rect.size = finalSize;

    UIGraphicsBeginImageContext(finalSize);

    if (bgColor) {

        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, bgColor.CGColor);
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, 100);
        CGContextAddLineToPoint(context, 100, 100);
        CGContextAddLineToPoint(context, 100, 0);
        CGContextAddLineToPoint(context, 0, 0);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
    }

    if (array.count == 1) {
        NSMutableArray *rectsArray = NSMutableArray.array;
        [self tfy_getRects:rectsArray padding:0 width:100 count:1];

        id obj = array.firstObject;
        UIImage *image = [self tfy_groupIconWithURL:obj];
        
        CGRect rect = CGRectFromString([rectsArray objectAtIndex:0]);
        [image drawInRect:rect];
    }
    if (array.count >= 2) {

        NSArray *rects = [self tfy_eachRectInGroupWithCount2:array.count];
        int count = 0;
        for (id obj in array) {
            if (count > rects.count-1) {
                break;
            }
            UIImage *image = [self tfy_groupIconWithURL:obj];
            
            CGRect rect = CGRectFromString([rects objectAtIndex:count]);
            [image drawInRect:rect];
            count++;
        }
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)tfy_groupIconWithURL:(id)urlData {
    NSData * data = nil;
    if ([urlData isKindOfClass:NSData.class]) {
        data = urlData;
    } else if ([urlData isKindOfClass:NSString.class]) {
        NSString *url = urlData;
        if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) {
            data = [[NSData alloc] initWithContentsOfURL:urlData];
        } else {
            data = [[NSData alloc] initWithContentsOfFile:urlData];
            if (data == nil) {
                data = UIImagePNGRepresentation([UIImage imageNamed:urlData]);
            }
        }
    } else if ([urlData isKindOfClass:UIImage.class]) {
        data = UIImagePNGRepresentation(urlData);
    }
    UIImage *image = [[UIImage alloc]initWithData:data];
    return image;
}

+ (NSArray *)tfy_eachRectInGroupWithCount:(NSInteger)count {

    NSArray *rects = nil;
    
    CGFloat sizeValue = 100;
    CGFloat padding = 2;
    
    CGFloat eachWidth = (sizeValue - padding*3) / 2;
    
    CGRect rect1 = CGRectMake(sizeValue/2 - eachWidth/2, padding, eachWidth, eachWidth);
    
    CGRect rect2 = CGRectMake(padding, padding*2 + eachWidth, eachWidth, eachWidth);
    
    CGRect rect3 = CGRectMake(padding*2 + eachWidth, padding*2 + eachWidth, eachWidth, eachWidth);
    if (count == 3) {
        rects = @[NSStringFromCGRect(rect1), NSStringFromCGRect(rect2), NSStringFromCGRect(rect3)];
    } else if (count == 4) {
        CGRect rect0 = CGRectMake(padding, padding, eachWidth, eachWidth);
        rect1 = CGRectMake(padding*2, padding, eachWidth, eachWidth);
        rects = @[NSStringFromCGRect(rect0), NSStringFromCGRect(rect1), NSStringFromCGRect(rect2), NSStringFromCGRect(rect3)];
    }
    
    return rects;
}

+ (NSArray *)tfy_eachRectInGroupWithCount2:(NSInteger)count {
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
    
    CGFloat sizeValue = 100;
    CGFloat padding = 2;
    
    CGFloat eachWidth;
    
    if (count <= 4) {
        eachWidth = (sizeValue - padding*3) / 2;
        [self tfy_getRects:array padding:padding width:eachWidth count:4];
    } else {
        padding = padding / 2;
        eachWidth = (sizeValue - padding*4) / 3;
        [self tfy_getRects:array padding:padding width:eachWidth count:9];
    }

    if (count < 4) {
        [array removeObjectAtIndex:0];
        CGRect rect = CGRectFromString([array objectAtIndex:0]);
        rect.origin.x = (sizeValue - eachWidth) / 2;
        [array replaceObjectAtIndex:0 withObject:NSStringFromCGRect(rect)];
        if (count == 2) {
            [array removeObjectAtIndex:0];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
            
            for (NSString *rectStr in array) {
                CGRect rect = CGRectFromString(rectStr);
                rect.origin.y -= (padding+eachWidth)/2;
                [tempArray addObject:NSStringFromCGRect(rect)];
            }
            [array removeAllObjects];
            [array addObjectsFromArray:tempArray];
        }
    } else if (count != 4 && count <= 6) {
        [array removeObjectsInRange:NSMakeRange(0, 3)];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:6];

        for (NSString *rectStr in array) {
            CGRect rect = CGRectFromString(rectStr);
            rect.origin.y -= (padding+eachWidth)/2;
            [tempArray addObject:NSStringFromCGRect(rect)];
        }
        [array removeAllObjects];
        [array addObjectsFromArray:tempArray];
        
        if (count == 5) {
            [tempArray removeAllObjects];
            [array removeObjectAtIndex:0];
            
            for (int i=0; i<2; i++) {
                CGRect rect = CGRectFromString([array objectAtIndex:i]);
                rect.origin.x -= (padding+eachWidth)/2;
                [tempArray addObject:NSStringFromCGRect(rect)];
            }
            [array replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:tempArray];
        }
        
    } else if (count != 4 && count < 9) {
        if (count == 8) {
            [array removeObjectAtIndex:0];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
            for (int i=0; i<2; i++) {
                CGRect rect = CGRectFromString([array objectAtIndex:i]);
                rect.origin.x -= (padding+eachWidth)/2;
                [tempArray addObject:NSStringFromCGRect(rect)];
            }
            [array replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:tempArray];
        } else {
            [array removeObjectAtIndex:2];
            [array removeObjectAtIndex:0];
        }
    }

    return array;
}

+ (void)tfy_getRects:(NSMutableArray *)array padding:(CGFloat)padding width:(CGFloat)eachWidth count:(int)count {

    for (int i=0; i<count; i++) {
        int sqrtInt = (int)sqrt(count);
        int line = i%sqrtInt;
        int row = i/sqrtInt;
        CGRect rect = CGRectMake(padding * (line+1) + eachWidth * line, padding * (row+1) + eachWidth * row, eachWidth, eachWidth);
        [array addObject:NSStringFromCGRect(rect)];
    }
}


@end
