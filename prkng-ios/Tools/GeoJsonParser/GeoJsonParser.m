//
//  GeoJsonParser.m
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-01.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

#import "GeoJsonParser.h"

@implementation GeoJsonParser

+ (NSArray *)overlaysFromFilePath: (NSString *)filePath {
    
    NSData *overlayData = [NSData dataWithContentsOfFile:filePath];
    
    NSArray *countries = [[NSJSONSerialization JSONObjectWithData:overlayData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"features"];
    
    NSMutableArray *overlays = [NSMutableArray array];
    
    for (NSDictionary *country in countries) {
        
        NSDictionary *geometry = country[@"geometry"];
        if ([geometry[@"type"] isEqualToString:@"Polygon"]) {
            MKPolygon *polygon = [self overlaysFromPolygons:geometry[@"coordinates"] id:country[@"properties"][@"name"]];
            if (polygon) {
                [overlays addObject:polygon];
            }
            
            
        } else if ([geometry[@"type"] isEqualToString:@"MultiPolygon"]){
            for (NSArray *polygonData in geometry[@"coordinates"]) {
                MKPolygon *polygon = [self overlaysFromPolygons:polygonData id:country[@"properties"][@"name"]];
                if (polygon) {
                    [overlays addObject:polygon];
                }
            }
        } else {
            NSLog(@"Unsupported type: %@", geometry[@"type"]);
        }
    }
    
    return overlays;
    
}

+ (MKPolygon *)overlaysFromPolygons:(NSArray *)polygons id:(NSString *)title
{
    NSMutableArray *interiorPolygons = [NSMutableArray arrayWithCapacity:[polygons count] - 1];
    for (int i = 1; i < [polygons count]; i++) {
        [interiorPolygons addObject:[self polygonFromPoints:polygons[i] interiorPolygons:nil]];
    }
    
    MKPolygon *overlayPolygon = [self polygonFromPoints:polygons[0] interiorPolygons:interiorPolygons];
    overlayPolygon.title = title;
    
    
    return overlayPolygon;
}

+ (MKPolygon *)polygonFromPoints:(NSArray *)points interiorPolygons:(NSArray *)polygons
{
    NSInteger numberOfCoordinates = [points count];
    CLLocationCoordinate2D *polygonPoints = malloc(numberOfCoordinates * sizeof(CLLocationCoordinate2D));
    
    NSInteger index = 0;
    for (NSArray *pointArray in points) {
        polygonPoints[index] = CLLocationCoordinate2DMake([pointArray[1] floatValue], [pointArray[0] floatValue]);
        index++;
    }
    
    MKPolygon *polygon;
    
    if (polygons) {
        polygon = [MKPolygon polygonWithCoordinates:polygonPoints count:numberOfCoordinates interiorPolygons:polygons];
    } else {
        polygon = [MKPolygon polygonWithCoordinates:polygonPoints count:numberOfCoordinates];
    }
    free(polygonPoints);
    
    return polygon;
}

@end
