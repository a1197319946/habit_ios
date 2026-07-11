#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "app_logo" asset catalog image resource.
static NSString * const ACImageNameAppLogo AC_SWIFT_PRIVATE = @"app_logo";

/// The "bunny_success" asset catalog image resource.
static NSString * const ACImageNameBunnySuccess AC_SWIFT_PRIVATE = @"bunny_success";

/// The "header_bg" asset catalog image resource.
static NSString * const ACImageNameHeaderBg AC_SWIFT_PRIVATE = @"header_bg";

/// The "launch_bg" asset catalog image resource.
static NSString * const ACImageNameLaunchBg AC_SWIFT_PRIVATE = @"launch_bg";

/// The "native_launch" asset catalog image resource.
static NSString * const ACImageNameNativeLaunch AC_SWIFT_PRIVATE = @"native_launch";

/// The "native_launch_v2" asset catalog image resource.
static NSString * const ACImageNameNativeLaunchV2 AC_SWIFT_PRIVATE = @"native_launch_v2";

/// The "poster_bg" asset catalog image resource.
static NSString * const ACImageNamePosterBg AC_SWIFT_PRIVATE = @"poster_bg";

/// The "scancode" asset catalog image resource.
static NSString * const ACImageNameScancode AC_SWIFT_PRIVATE = @"scancode";

#undef AC_SWIFT_PRIVATE
