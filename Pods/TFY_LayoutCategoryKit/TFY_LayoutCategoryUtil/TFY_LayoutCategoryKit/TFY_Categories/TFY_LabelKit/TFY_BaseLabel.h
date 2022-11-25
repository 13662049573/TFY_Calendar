//
//  TFY_BaseLabel.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TFYLastTextType) {
    TFYLastTextTypeNormal,
    TFYLastTextTypeAttributed,
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BaseLabel : UILabel

@property (nonatomic, assign) CGFloat lineHeightMultiple; //行高的multiple
@property (nonatomic, assign) CGFloat lineSpacing; //行间距

@property (nonatomic, assign) UIEdgeInsets textInsets;

@property (nonatomic, copy) void(^doBeforeDrawingTextBlock)(CGRect rect,CGPoint beginOffset,CGSize drawSize);

- (CGSize)preferredSizeWithMaxWidth:(CGFloat)maxWidth;

//方便码代码
- (void)setDoBeforeDrawingTextBlock:(void (^)(CGRect rect,CGPoint beginOffset,CGSize drawSize))doBeforeDrawingTextBlock;

@end

@interface NSMutableAttributedString (TFY_Label)

- (void)removeAllNSOriginalFontAttributes;

- (void)removeAttributes:(NSArray *)names range:(NSRange)range;

@end


@interface NSString (TFY_Label)

//这个只是由于换行符的原因所必须有的行数
- (NSUInteger)lineCount;

//拿到某行之前的字符串
- (NSString*)subStringToLineIndex:(NSUInteger)lineIndex;

//拿到某行之前的字符串的长度
- (NSUInteger)lengthToLineIndex:(NSUInteger)lineIndex;

//是否最后字符属于换行符
- (BOOL)isNewlineCharacterAtEnd;

/**
 根据一个链接相关的正则，返回链接化得AttributedString，linkRegex里一定要包含显示的内容用()包裹起来
 
 Example:
 NSString *str = @"张三的电话[tel=000000 name=tel1]李四的电话[tel=00444000 name=tel2]王五的电话[tel=000300 name=tel3]都在这了";
 NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\[tel=(\\d{6,11}) name=(\\w+)\\]" options:kNilOptions error:nil];
 self.label.attributedText = [str linkAttributedStringWithLinkRegex:regex groupIndexForDisplay:2 groupIndexForValue:1];
 */
- (NSAttributedString*)linkAttributedStringWithLinkRegex:(NSRegularExpression*)linkRegex groupIndexForDisplay:(NSInteger)groupIndexForDisplay groupIndexForValue:(NSInteger)groupIndexForValue;

@end

@interface NSAttributedString (TFY_Label)

+ (instancetype)attributedStringWithHTML:(NSString*)htmlString;

/**
 根据一个链接相关的正则，返回链接化得AttributedString，linkRegex里一定要包含显示的内容用()包裹起来
 
 Example:
 NSString *str = @"张三的电话[tel=000000 name=tel1]李四的电话[tel=00444000 name=tel2]王五的电话[tel=000300 name=tel3]都在这了";
 NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\[tel=(\\d{6,11}) name=(\\w+)\\]" options:kNilOptions error:nil];
 self.label.attributedText = [str linkAttributedStringWithLinkRegex:regex groupIndexForDisplay:2 groupIndexForValue:1];
 */
- (NSAttributedString*)linkAttributedStringWithLinkRegex:(NSRegularExpression*)linkRegex groupIndexForDisplay:(NSInteger)groupIndexForDisplay groupIndexForValue:(NSInteger)groupIndexForValue;

@end

NS_ASSUME_NONNULL_END
