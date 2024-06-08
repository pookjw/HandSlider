//
//  HandSlider.m
//  HandSlider
//
//  Created by Jinwoo Kim on 6/7/24.
//

#import "HandSlider.h"
#import "UIApplication+mrui_requestSceneWrapper.hpp"
#import <ARKit/ARKit.h>

__attribute__((objc_direct_members))
@interface HandSlider ()
@property (retain, nonatomic, readonly) ar_session_t session;
@property (retain, nonatomic, readonly) ar_hand_tracking_provider_t handTrackingProvider;
@end

@implementation HandSlider
@synthesize session = _session;
@synthesize handTrackingProvider = _handTrackingProvider;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit_HandSlider];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit_HandSlider];
    }
    
    return self;
}

- (void)dealloc {
    if (auto session = _session) {
        ar_session_stop(session);
        ar_release(session);
    }
    
    ar_release(_handTrackingProvider);
    
    [super dealloc];
}

- (void)commonInit_HandSlider __attribute__((objc_direct)) {
    self.minimumValue = 0.f;
    self.maximumValue = M_PI_2;
    
    ar_authorization_type_t authorizationTypes = ar_hand_tracking_provider_get_required_authorization_type();
    
    ar_session_t session = self.session;
    
    ar_session_request_authorization(session, authorizationTypes, ^(ar_authorization_results_t  _Nonnull authorization_results, ar_error_t  _Nullable error) {
        if (error != nil) {
            CFErrorRef cfError = ar_error_copy_cf_error(error);
            ar_release(error);
            CFShow(cfError);
            CFRelease(cfError);
            return;
        }
        
        __block BOOL flag = YES;
        
        ar_authorization_results_enumerate_results(authorization_results, ^bool(ar_authorization_result_t  _Nonnull authorization_result) {
            ar_authorization_status_t status = ar_authorization_result_get_status(authorization_result);
            
            if (status == ar_authorization_status_allowed) {
                return true;
            } else {
                flag = NO;
                return false;
            }
        });
        
        if (flag) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ar_hand_tracking_provider_t handTrackingProvider = self.handTrackingProvider;
                
                ar_data_providers_t dataProviders = ar_data_providers_create_with_data_providers(handTrackingProvider, nil);
                
                ar_session_run(session, dataProviders);
                
                [UIApplication.sharedApplication mruiw_requestMixedImmersiveSceneWithUserActivity:nil completionHandler:^(NSError * _Nullable error) {
                    assert(error == nil);
                }];
                
                ar_release(dataProviders);
            });
        } else {
            abort();
        }
    });
}

- (ar_session_t)session {
    if (auto session = _session) return session;
    
    ar_session_t session = ar_session_create();
    
    ar_session_set_data_provider_state_change_handler(session, NULL, ^(ar_data_providers_t  _Nonnull data_providers, ar_data_provider_state_t new_state, ar_error_t  _Nullable error, ar_data_provider_t  _Nullable failed_data_provider) {
        if (error != nil) {
            CFErrorRef cfError = ar_error_copy_cf_error(error);
            ar_release(error);
            CFShow(cfError);
            CFRelease(cfError);
            return;
        }
    });
    
    _session = ar_retain(session);
    return [session autorelease];
}

- (ar_hand_tracking_provider_t)handTrackingProvider {
    if (auto handTrackingProvider = _handTrackingProvider) return handTrackingProvider;
    
    // simulator is not supported
    assert(ar_hand_tracking_provider_is_supported());
    
    ar_hand_tracking_configuration_t configuration = ar_hand_tracking_configuration_create();
    ar_hand_tracking_provider_t handTrackingProvider = ar_hand_tracking_provider_create(configuration);
    ar_release(configuration);
    
    ar_hand_tracking_provider_set_update_handler(handTrackingProvider, NULL, ^(ar_hand_anchor_t  _Nonnull hand_anchor_left, ar_hand_anchor_t  _Nonnull hand_anchor_right) {
//        ar_skeleton_joint_t joint = ar_hand_skeleton_get_joint_named(ar_hand_anchor_get_hand_skeleton(hand_anchor_right), ar_hand_skeleton_joint_name_wrist);
        
//        ar_hand_skeleton_enumerate_joints(ar_hand_anchor_get_hand_skeleton(hand_anchor_right), ^bool(ar_skeleton_joint_t  _Nonnull joint) {
//            simd_float4x4 matrix = ar_skeleton_joint_get_anchor_from_joint_transform(joint);
//            simd_quatf rotation = simd_quaternion(matrix);
//            float angle = simd_angle(rotation);
//            NSLog(@"%lf", angle);
//            
//            return true;
//        });
        
        simd_float4x4 matrix = ar_anchor_get_origin_from_anchor_transform(hand_anchor_right);
        simd_quatf rotation = simd_quaternion(matrix);
        float angle = simd_angle(rotation);
        self.value = angle;
    });
    
    _handTrackingProvider = ar_retain(handTrackingProvider);
    return [handTrackingProvider autorelease];
}

@end
