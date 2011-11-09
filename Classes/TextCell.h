//
//  TextCell.h
//  iWoman
//
//  Created by Oliver Drobnik on 18.09.08.
//  Copyright 2008 drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextCell : UITableViewCell {
	UILabel		*title;
	UILabel		*value;
}

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *value;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
