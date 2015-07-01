//
//  GeoJsonParser.h
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-01.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GeoJsonParser : NSObject

+ (NSArray *)overlaysFromFilePath: (NSString *)filePath;
+ (MKPolygon *)overlaysFromPolygons:(NSArray *)polygons id:(NSString *)title;
+ (MKPolygon *)polygonFromPoints:(NSArray *)points interiorPolygons:(NSArray *)polygons;

@end
