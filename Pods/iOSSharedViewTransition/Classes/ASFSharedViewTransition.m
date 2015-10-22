//
//  ASFSharedViewTransition.m
//  ASFTransitionTest
//
//  Created by Asif Mujteba on 09/08/2014.
//  Copyright (c) 2014 Asif Mujteba. All rights reserved.
//

#import "ASFSharedViewTransition.h"
#import <objc/runtime.h>

@interface ParamsHolder : NSObject

@property (nonatomic, weak) UINavigationController *nav;
@property (nonatomic, weak) Class fromVCClass;
@property (nonatomic, weak) Class toVCClass;

@property (nonatomic, assign) NSTimeInterval duration;


@end

@implementation ParamsHolder

@end

@interface ASFSharedViewTransition ()

@property (nonatomic, retain) NSMutableArray *arrParamHolders;

@end

@implementation ASFSharedViewTransition

#pragma mark - Setup & Initializers

+ (instancetype)shared
{
    static ASFSharedViewTransition *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ASFSharedViewTransition alloc] init];
    });
    return instance;
}

- (NSMutableArray *)arrParamHolders
{
    if (!_arrParamHolders) {
        _arrParamHolders = [[NSMutableArray alloc] init];
    }
    
    return _arrParamHolders;
}

#pragma mark - Private Methods

- (ParamsHolder *)paramHolderForFromVC:(UIViewController *)fromVC ToVC:(UIViewController *)toVC reversed:(BOOL *)reversed {
    ParamsHolder *pHolder = nil;
    for (ParamsHolder *holder in [[ASFSharedViewTransition shared] arrParamHolders]) {
        if (holder.fromVCClass == [fromVC class] && holder.toVCClass == [toVC class]) {
            pHolder = holder;
        }
        else if (holder.fromVCClass == [toVC class] && holder.toVCClass == [fromVC class]) {
            pHolder = holder;
            
            if (reversed) {
                *reversed = true;
            }
        }
    }
    
    return pHolder;
}

#pragma mark - Public Methods

+ (void)addTransitionWithFromViewControllerClass:(Class<ASFSharedViewTransitionDataSource>)aFromVCClass
                           ToViewControllerClass:(Class<ASFSharedViewTransitionDataSource>)aToVCClass
                        WithNavigationController:(UINavigationController *)aNav
                                    WithDuration:(NSTimeInterval)aDuration
{
    BOOL found = false;
    for (ParamsHolder *holder in [[ASFSharedViewTransition shared] arrParamHolders]) {
        if (holder.fromVCClass == aFromVCClass && holder.toVCClass == aToVCClass) {
            holder.duration = aDuration;
            holder.nav = aNav;
            holder.nav.delegate = [ASFSharedViewTransition shared];
            
            found = true;
            break;
        }
    }
    
    if (!found) {
        ParamsHolder *holder = [[ParamsHolder alloc] init];
        holder.fromVCClass = aFromVCClass;
        holder.toVCClass = aToVCClass;
        holder.duration = aDuration;
        holder.nav = aNav;
        
        holder.nav.delegate = [ASFSharedViewTransition shared];
        [[[ASFSharedViewTransition shared] arrParamHolders] addObject:holder];
    }
}

#pragma mark UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    ParamsHolder *pHolder = [self paramHolderForFromVC:fromVC ToVC:toVC reversed:nil];
    if (pHolder) {
        return [ASFSharedViewTransition shared];
    }
    else {
        return nil;
    }
}

#pragma mark - UIViewControllerContextTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController<ASFSharedViewTransitionDataSource> *fromVC =
        (UIViewController<ASFSharedViewTransitionDataSource> *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<ASFSharedViewTransitionDataSource> *toVC   =
        (UIViewController<ASFSharedViewTransitionDataSource> *) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BOOL reversed = false;
    ParamsHolder *pHolder = [self paramHolderForFromVC:fromVC ToVC:toVC reversed:&reversed];
    
    if (!pHolder) {
        return;
    }
    
    UIView *fromView = [fromVC sharedView];
    UIView *toView = [toVC sharedView];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval dur = [self transitionDuration:transitionContext];
    
    // Take Snapshot of fomView
    UIView *snapshotView = [fromView snapshotViewAfterScreenUpdates:NO];
    [self debug:@"orig snapshot" frame:snapshotView.frame];
    snapshotView.frame = [containerView convertRect:fromView.frame fromView:fromView.superview];
    [self debug:@"snapshot converted frame" frame:snapshotView.frame];
    
    // Setup the initial view states
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    
    if (!reversed) {
        toVC.view.alpha = 0;
        [containerView addSubview:toVC.view];
    }
    else {
        [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    }
    
    [containerView addSubview:snapshotView];
    fromView.hidden = YES;
    toView.hidden = YES;
    
    [UIView animateWithDuration:dur animations:^{
        if (!reversed) {
            toVC.view.alpha = 1.0; // Fade in
        }
        else {
            fromVC.view.alpha = 0.0; // Fade out
        }
        
        // Move the SnapshotView
        [self debug:@"converting from" frame:toView.frame];
        [self debug:@"in view" frame:toView.superview.frame];
        snapshotView.frame = [containerView convertRect:toView.frame fromView:toView.superview];
//        snapshotView.frame = CGRectMake(snapshotView.frame.origin.x + 10.0, snapshotView.frame.origin.y + 20.0, snapshotView.frame.size.width, snapshotView.frame.size.height);
        [self debug:@"animate to" frame:snapshotView.frame];
        
    } completion:^(BOOL finished) {
        // Clean up
        [self debug:@"animation finished" frame:snapshotView.frame];
        toView.hidden = NO;
        fromView.hidden = NO;
        [snapshotView removeFromSuperview];
        
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)debug:(NSString *)message frame:(CGRect)frame {
    NSLog(@"%@ - %f, %f, %f, %f", message, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    ParamsHolder *pHolder = [self paramHolderForFromVC:fromVC ToVC:toVC reversed:nil];
    
    if (pHolder) {
        return pHolder.duration;
    }
    else {
        return 0;
    }
}

@end
