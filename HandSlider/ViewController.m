//
//  ViewController.m
//  HandSlider
//
//  Created by Jinwoo Kim on 6/7/24.
//

#import "ViewController.h"
#import "HandSlider.h"

@implementation ViewController

- (void)loadView {
    HandSlider *slider = [HandSlider new];
    self.view = slider;
    [slider release];
}

@end
