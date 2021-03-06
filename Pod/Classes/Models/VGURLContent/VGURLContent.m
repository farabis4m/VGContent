//
//  VGURLContent.m
//  VGContent
//
//  Created by Vlad Gorbenko on 05.07.15.
//  Copyright (c) 2015 Vlad Gorbenko. All rights reserved.
//

#import "VGURLContent.h"

#import <UIScrollView-InfiniteScroll/UIScrollView+InfiniteScroll.h>

@interface VGURLContent ()

@property (nonatomic, readonly, assign) UIScrollView *scrollView;

@end

@implementation VGURLContent

@synthesize isRefreshing = _isRefreshing;
@synthesize isAllLoaded = _isAllLoaded;
@synthesize isLoading = _isLoading;

#pragma mark - Setup methods

- (void)setup {
    self.isAllLoaded = NO;
    [super setup];
}

#pragma mark - Accessors

- (NSInteger)offset {
    return _isRefreshing ? 0 : _offset;
}

- (BOOL)isRefreshing {
    return _isRefreshing;
}

- (UIScrollView *)scrollView {
    return (UIScrollView *)self.view;
}

- (void)setIsAllLoaded:(BOOL)isAllLoaded {
    _isAllLoaded = isAllLoaded;
    // TODO: think about this
    // iCarousel is not UIScrollView child;
    if(isAllLoaded) {
        if([self.scrollView respondsToSelector:@selector(addInfiniteScrollWithHandler:)]) {
            [self.scrollView removeInfiniteScroll];
        }
    } else {
        if([self.scrollView respondsToSelector:@selector(addInfiniteScrollWithHandler:)]) {
            if(!self.isAllLoaded) {
                [self.scrollView addInfiniteScrollWithHandler:^(id scrollView) {
                    [self loadMoreItems];
                }];
            }
        }
    }
}

#pragma mark - VGURLContent management

- (void)loadItems {
}

- (void)refresh {
    _isRefreshing = YES;
    [self notifyWillLoad];
    [self loadItems];
}

- (void)loadMoreItems {
    _isLoading = YES;
    [self notifyWillLoad];
    [self loadItems];
}

- (void)cancel {
}

#pragma mark - URL fetching management

- (void)fetchLoadedItems:(NSArray *)items error:(NSError *)error {
    if(error) {
        [self notifyDidFailWithError:error];
        return;
    }
    if (_isRefreshing) { // TODO: handle situations when can infinite scroll with search string.
        self.originalItems = [NSMutableArray arrayWithArray:items];
        [_items removeAllObjects];
    }
    
    [self insertItems:items atIndex:_items.count animated:YES];
    [self notifyDidLoadWithItems:items];
    _isRefreshing = NO;
    _isLoading = NO;
    [self.scrollView finishInfiniteScroll];
}

- (void)fetchLoadedItems:(NSArray *)items pageSize:(NSInteger)pageSize error:(NSError *)error {
    self.filteredItems = nil;
    [self fetchLoadedItems:items error:error];
    self.isAllLoaded = items.count < pageSize;
}

#pragma mark - Notifiers

- (void)notifyDidFailWithError:(NSError *)error {
    if ([self.dataDelegate respondsToSelector:@selector (content:didFailLoadingWithError:)]) {
        [self.dataDelegate content:self didFailLoadingWithError:error];
    }
}

- (void)notifyDidLoadWithItems:(NSArray *)items {
    if ([self.dataDelegate respondsToSelector:@selector (content:didFinishLoadingWithItems:)]) {
        [self.dataDelegate content:self didFinishLoadingWithItems:items];
    }
}

- (void)notifyWillLoad {
    if ([self.dataDelegate respondsToSelector:@selector (contentWillLoadItems:)]) {
        [self.dataDelegate contentWillLoadItems:self];
    }
}

@end
