#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <Metal/Metal.h>

#pragma mark - FxRect

typedef struct FxRect {
    int left;
    int bottom;
    int right;
    int top;
} FxRect;

@interface NSValue (FxRectExtensions)
@property (readonly) FxRect fxRectValue;
@property (readonly) FxRect rectValue;
+ (NSValue * _Nonnull)valueWithFxRect:(FxRect)rect;
@end

#pragma mark - FxScheduleInputsRequest

typedef struct FxScheduleInputsRequest {
    FxRect hostRect;
    void * _Nullable internalContext;
} FxScheduleInputsRequest;

#pragma mark - Constants

static NSString * const _Nonnull kFxPropertyKey_MayRemapTime = @"kFxPropertyKey_MayRemapTime";
static NSString * const _Nonnull kFxPropertyKey_PixelTransformSupport = @"kFxPropertyKey_PixelTransformSupport";
static NSString * const _Nonnull kFxPixelTransform_Supported = @"kFxPixelTransform_Supported";
static NSString * const _Nonnull kFxPropertyKey_NeedsFullBuffer = @"kFxPropertyKey_NeedsFullBuffer";

#pragma mark - Protocols for Parameter APIs

@protocol PROAPIAccessing <NSObject>
- (nullable id)apiForProtocol:(Protocol * _Nonnull)protocol NS_SWIFT_NAME(api(for:));
@end

@protocol FxParameterCreationAPI_v5 <NSObject>
- (BOOL)addFloatSliderWithName:(NSString * _Nonnull)name
                   parameterID:(UInt32)parameterID
                  defaultValue:(double)defaultValue
                  parameterMin:(double)parameterMin
                  parameterMax:(double)parameterMax
                     sliderMin:(double)sliderMin
                     sliderMax:(double)sliderMax
                         delta:(double)delta
                parameterFlags:(UInt32)flags;

- (BOOL)addIntSliderWithName:(NSString * _Nonnull)name
                 parameterID:(UInt32)parameterID
                defaultValue:(int)defaultValue
                parameterMin:(int)parameterMin
                parameterMax:(int)parameterMax
                   sliderMin:(int)sliderMin
                   sliderMax:(int)sliderMax
                       delta:(int)delta
              parameterFlags:(UInt32)flags;

- (BOOL)addPopupMenuWithName:(NSString * _Nonnull)name
                 parameterID:(UInt32)parameterID
                defaultValue:(UInt32)defaultValue
                 menuEntries:(NSArray<NSString *> * _Nonnull)entries
              parameterFlags:(UInt32)flags;

- (BOOL)addToggleButtonWithName:(NSString * _Nonnull)name
                    parameterID:(UInt32)parameterID
                   defaultValue:(BOOL)defaultValue
                 parameterFlags:(UInt32)flags;

- (BOOL)startParameterGroup:(NSString * _Nonnull)name
                parameterID:(UInt32)parameterID
             parameterFlags:(UInt32)flags;

- (BOOL)endParameterGroup;

- (BOOL)addParameterGroupWithName:(NSString * _Nonnull)name
                      parameterID:(UInt32)parameterID
                            flags:(UInt32)flags;
@end

@protocol FxParameterRetrievalAPI_v6 <NSObject>
- (BOOL)getFloatValue:(double * _Nonnull)value fromParameter:(UInt32)parameterID atTime:(CMTime)time;
- (BOOL)getIntValue:(int * _Nonnull)value fromParameter:(UInt32)parameterID atTime:(CMTime)time;
- (BOOL)getBoolValue:(BOOL * _Nonnull)value fromParameter:(UInt32)parameterID atTime:(CMTime)time;
@end

@protocol FxRenderEnvironmentAPI_v2 <NSObject>
- (id<MTLDevice> _Nonnull)device;
@end

#pragma mark - FxImageTile & FxImage

@interface FxImageTile : NSObject
@property (readonly) UInt64 deviceRegistryID;
@property (readonly) FxRect tileRect;
@property (readonly) FxRect imageRect;
- (nullable id<MTLTexture>)metalTextureForDevice:(id<MTLDevice> _Nonnull)device NS_SWIFT_NAME(metalTexture(for:));
@end

@interface FxImage : NSObject
@property (readonly) UInt64 deviceRegistryID;
@property (readonly) UInt32 width;
@property (readonly) UInt32 height;
@property (readonly) id<MTLTexture> _Nonnull texture;
@end

#pragma mark - FxPrincipal

@interface FxPrincipal : NSObject
+ (void)startServicePrincipal;
@end
