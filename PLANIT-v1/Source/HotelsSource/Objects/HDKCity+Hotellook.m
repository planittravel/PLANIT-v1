#import "PLANIT_v1-Swift.h"
#import "HDKCity+Hotellook.h"
#import "HLPoiManager.h"

@implementation HDKCity (HL)

- (NSArray<HDKLocationPoint *> *)airports
{
    return [HLPoiManager filterPoints:self.points byCategories:@[HDKLocationPointCategory.kAirport]];
}

@end
