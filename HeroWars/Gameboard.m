//
//  Gameboard.m
//  HeroWars
//
//  Created by Max Shashoua on 1/31/15.
//  Copyright (c) 2015 Max Shashoua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Gameboard.h"

@interface Gameboard ()

@end

@implementation Gameboard

NSInteger INCOME_PER_BUILDING = 100;

-(id)initWithLevelNamed:(NSString *)levelFile {
    self = [super init];
    if (self) {
        // parse the level from file and retrieve relevant data
        self.levelParser = [[LevelParser alloc]init];
        [self.levelParser makeGridsFromLevelFile:levelFile];
        self.levelName = self.levelParser.levelName;
        self.width = self.levelParser.width;
        self.height = self.levelParser.height;
        self.players = self.levelParser.players;
        self.playerColors = self.levelParser.playerColors;
        self.tileGrid = self.levelParser.tileGrid;
        self.unitGrid = self.levelParser.unitGrid;
        // set other properties
        self.currentPlayer = 0;
        self.turn = 0;
        self.lastMoveInfo = [[NSMutableArray alloc]init];
        self.funds = [[NSMutableArray alloc]init];
        for (int i = 0; i < [self.playerColors count]; i++) {
            [self.funds addObject:@0];
        }
    }
    return self;
}

//-(void)endTurn {
//    // when turn is over, 1) set all the units to awake. 2) adjust turn variables
//    for (NSMutableArray *row in self.unitGrid) {
//        for (id unitMaybe in row){
//            if ([unitMaybe isKindOfClass:[Unit class]]){
//                Unit *unit = (Unit *)unitMaybe;
//                [unit changeStateTo:@"awake"];
//            }
//        }
//    }
//    self.turn++;
//    self.currentPlayer = (self.currentPlayer) % self.players + 1;
//    [self adjustFundsForPlayer:self.currentPlayer byAmount:[self getIncomeForPlayer:self.currentPlayer]];
//    NSLog(@"Player %d's turn", self.currentPlayer);
//    NSLog(@"Turn %d; Funds = %d", self.turn, [self getFundsForPlayer:self.currentPlayer]);
//}

-(NSInteger)getIncomeForPlayer:(NSInteger)player {
    NSInteger buildings = 0;
    for (NSArray *tileRow in self.tileGrid) {
        for (Tile *tile in tileRow) {
            if ([tile.type isEqualToString:@"building"]) {
                Tile *building = tile;
                if (building.owner == player) {
                    buildings++;
                }
            }
        }
    }
    return buildings * INCOME_PER_BUILDING;
}

-(NSInteger)getFundsForPlayer:(NSInteger)player {
    // returns the players funds
    if (0 < player && player <= self.players) {
        return [self.funds[player - 1] integerValue];
    } else {
        NSLog(@"Error: invalid player number for getFunds");
        return -1;
    }
}

-(void)adjustFundsForPlayer:(NSInteger)player byAmount:(NSInteger)amount {
    // adjusts a players funds by the amount given
    self.funds[player - 1] = [NSNumber numberWithInteger:([self getFundsForPlayer:player] + amount)];
}

-(BOOL)isUnit:(Unit *)a withinRangeOfUnit:(Unit *)b {
    NSInteger dx = a.x - b.x;
    NSInteger dy = a.y - b.y;
    NSInteger distance = abs(dx) + abs(dy);
    if ((distance >= [(NSNumber *)[b.range objectAtIndex:0] integerValue]) &&
        (distance <= [(NSNumber *)[b.range objectAtIndex:1] integerValue])) {
        return YES;
    } else {
        return NO;
    }
}

-(void)moveUnit:(Unit *)unit toTile:(Tile *)tile {
    [self.lastMoveInfo removeAllObjects];
    [self.lastMoveInfo addObject:[NSNumber numberWithInteger:unit.x]];
    [self.lastMoveInfo addObject:[NSNumber numberWithInteger:unit.y]];
    [self.lastMoveInfo addObject:[NSNumber numberWithInteger:tile.x]];
    [self.lastMoveInfo addObject:[NSNumber numberWithInteger:tile.y]];
    self.unitGrid[unit.y - 1][unit.x - 1] = [NSNull null];
    unit.tile = tile;
    unit.x = tile.x;
    unit.y = tile.y;
    self.unitGrid[tile.y - 1][tile.x - 1] = unit;
}

-(Unit *)undoMoveUnit {
    NSInteger x1 = [self.lastMoveInfo[0] integerValue];
    NSInteger y1 = [self.lastMoveInfo[1] integerValue];
    NSInteger x2 = [self.lastMoveInfo[2] integerValue];
    NSInteger y2 = [self.lastMoveInfo[3] integerValue];
    Unit *unit = [self unitAtX:x2 andY:y2];
    self.unitGrid[y1 - 1][x1 - 1] = unit;
    unit.x = x1;
    unit.y = y1;
    self.unitGrid[y2 - 1][x2 - 1] = [NSNull null];
    return unit;
}

-(Tile *)tileAtX:(NSInteger)x andY:(NSInteger)y {
    Tile *tile = [[Tile alloc]init];
    tile = self.tileGrid[y - 1][x - 1];
    return tile;
}

-(Unit *)unitAtX:(NSInteger)x andY:(NSInteger)y {
    Unit *unit = [[Unit alloc]init];
    unit = self.unitGrid[y - 1][x - 1];
    return unit;
}

-(void)removeUnitFromTile:(Tile *)tile {
    Unit *unit = [self unitAtX:tile.x andY:tile.y];
    self.unitGrid[tile.y - 1][tile.x - 1] = [NSNull null];
    NSLog(@"%@ %@ died", unit.teamColor, unit.type);
}

@end