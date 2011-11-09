//
//  PeriodDayDetailCell.h
//  iWoman
//
//  Created by Oliver Drobnik on 19.09.08.
//  Copyright 2008 drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReportCell : UITableViewCell {
	UILabel	*unitsSoldLabel;
	UILabel	*royaltyEarnedLabel;
	UILabel	*unitsUpdatedLabel;
	UILabel	*unitsRefundedLabel;
	UILabel *countryCodeLabel;

}

@property (nonatomic, retain) UILabel *unitsSoldLabel;
@property (nonatomic, retain) UILabel *royaltyEarnedLabel;
@property (nonatomic, retain) UILabel *unitsUpdatedLabel;
@property (nonatomic, retain) UILabel *unitsRefundedLabel;
@property (nonatomic, retain) UILabel *countryCodeLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
