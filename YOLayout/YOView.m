//
//  YOView.m
//  YOLayout
//
//  Created by Gabriel Handford on 10/29/13.
//  Copyright (c) 2014 YOLayout. All rights reserved.
//

#import "YOView.h"
#import "YOCGUtils.h"

@interface YOView ()
@property NSMutableArray *observeAttributes;
@end

@implementation YOView

- (void)_sharedInit {
  self.autoresizesSubviews = NO;
  self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)sharedInit { }

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self _sharedInit];
    [self sharedInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self _sharedInit];
    [self sharedInit];
  }
  return self;
}

- (void)dealloc {
  for (NSString *attr in _observeAttributes) {
    [self removeObserver:self forKeyPath:attr context:@"attributesNeedUpdate"];
  }
}

- (void)setLayoutBlock:(YOLayoutBlock)layoutBlock {
  if (!self.layout) {
    self.layout = [YOLayout layoutForView:self layoutBlock:layoutBlock];
  } else {
    self.layout.layoutBlock = layoutBlock;
  }
}

- (void)setAttributesNeedUpdate:(NSArray *)attributes {
  if (!_observeAttributes) _observeAttributes = [NSMutableArray array];
  [_observeAttributes addObjectsFromArray:attributes];
  for (NSString *attr in attributes) {
    [self addObserver:self forKeyPath:attr options:NSKeyValueObservingOptionNew context:@"attributesNeedUpdate"];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([_observeAttributes containsObject:keyPath]) {
    [self setNeedsDisplay];
    [self setNeedsLayout];
  }
}

- (void)setFrame:(CGRect)frame {
  if (_layout && !YOCGRectIsEqual(self.frame, frame)) [_layout setNeedsLayout];
  [super setFrame:frame];
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  YOLayoutAssert(self, _layout);
  if (_layout) {
    [_layout layoutSubviews:self.frame.size];
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  YOLayoutAssert(self, _layout);
  if (_layout) {
    return [_layout sizeThatFits:size];
  }
  return [super sizeThatFits:size];
}

- (void)setNeedsLayout {
  [super setNeedsLayout];
  [self setNeedsDisplay];
  [_layout setNeedsLayout];
}

- (void)notifyNeedsLayout:(BOOL)animated {
  [self setNeedsLayout];
}

#pragma mark Refersh

- (void)refresh { }

- (void)refreshIfNeeded {
  if (self.needsRefresh) {
    self.needsRefresh = NO;
    [self refresh];
  }
}

#pragma mark Drawing/Layout

- (void)layoutView {
  NSAssert(_layout, @"Missing layout instance");
  [_layout setNeedsLayout];
  [_layout layoutSubviews:self.frame.size];
}

- (void)drawInRect:(CGRect)rect {
  [_layout drawSubviewsInRect:rect];
}

@end
