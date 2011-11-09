//
//  ReportAppsController.m
//  ASiST
//
//  Created by Oliver Drobnik on 02.02.09.
//  Copyright 2009 drobnik.com. All rights reserved.
//

#import "ReportAppsController.h"
#import "GenericReportController.h"
#import "Report_v1.h"
#import "Sale_v1.h"
#import "Country_v1.h"
#import "App.h"
#import "ASiSTAppDelegate.h"
#import "YahooFinance.h"
#import "CountrySummary.h"
#import "ReportCell.h"

@implementation ReportAppsController

@synthesize report;

- (void) setReport:(Report_v1 *)activeReport
{
	report = activeReport;
	
	if (activeReport.isNew)
	{
		[DB newReportRead:activeReport];
	}

	[report hydrate];

	if (report.reportType == ReportTypeFinancial)
	{
		self.title = [report listDescriptionShorter:YES];
	}
	else
	{
		self.title = [report listDescriptionShorter:YES];
	}

	[sortedApps release];
	sortedApps = [[DB appsSortedBySalesWithGrouping:report.appGrouping] retain];

	[self.tableView reloadData];
}


- (id) initWithReport:(Report_v1 *)aReport
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) 
	{
		[self setReport:aReport];

		sumImage = [UIImage imageNamed:@"Sum.png"];
		
		segmentedControl = [[UISegmentedControl alloc] initWithItems:
							[NSArray arrayWithObjects:
							 [UIImage imageNamed:@"up.png"],
							 [UIImage imageNamed:@"down.png"],
							 nil]];
		[segmentedControl addTarget:self action:@selector(upDownPushed:) forControlEvents:UIControlEventValueChanged];
		segmentedControl.frame = CGRectMake(0, 0, 90, 30);
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.momentary = YES;
		
		UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
		
		self.navigationItem.rightBarButtonItem = segmentBarItem;
		[segmentBarItem release];
		
    }
    return self;
}

- (void)dealloc 
{
	[sortedApps release];
	[segmentedControl release];
    [super dealloc];
}


/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */


 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

/*
// The accessory type is the image displayed on the far right of each table cell. In order for the delegate method
// tableView:accessoryButtonClickedForRowWithIndexPath: to be called, you must return the "Detail Disclosure Button" type.
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
{
	if (!indexPath.row)
	{
		return UITableViewCellAccessoryNone;
	}
	else
	{
		return UITableViewCellAccessoryDisclosureIndicator;
	}
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [sortedApps count] + 1; // one extra section for totals over all apps
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// section 0 = totals
	if (section)
	{
		App *tmpApp = [sortedApps objectAtIndex:section - 1];  // minus one because of totals section
		
		if (tmpApp)
		{
			return tmpApp.title;
		}
		else
		{
			return @"Invalid";
		}
	}
	else
	{
		return @"Total Summary";
		
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			return 2;   // summary also has explanation cell
			break;
		default:
		{
			App* sectionApp = [sortedApps objectAtIndex:section-1];
			
			if ([sectionApp inAppPurchases])
			{
				return 4;  // header + sum + app + iap
			}
			else
			{
				return 2;  // header + app
			}
			
			break;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!indexPath.row)
	{
		return 20.0;
	}
	else
	{
		return 50.0;
	}
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier;
	
	if (!indexPath.row)
	{
		CellIdentifier =  @"HeaderCell";
	}
	else
	{
		CellIdentifier =  @"Cell";
	}
    
	ReportCell *cell = (ReportCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ReportCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
    }
    
	
	if (!indexPath.row)
	{
		// headers
		cell.unitsSoldLabel.text = @"Units";
		cell.unitsSoldLabel.font = [UIFont systemFontOfSize:8.0];
		cell.unitsSoldLabel.textAlignment = UITextAlignmentCenter;
		
		cell.unitsRefundedLabel.text = @"Refunds";
		cell.unitsRefundedLabel.font = [UIFont systemFontOfSize:8.0];
		cell.unitsRefundedLabel.textAlignment = UITextAlignmentCenter;
		
		cell.unitsUpdatedLabel.text = @"Updates";
		cell.unitsUpdatedLabel.font = [UIFont systemFontOfSize:8.0];
		cell.unitsUpdatedLabel.textAlignment = UITextAlignmentCenter;
		
		
		cell.royaltyEarnedLabel.text = @"Royalties";
		cell.royaltyEarnedLabel.font = [UIFont systemFontOfSize:8.0];
		cell.royaltyEarnedLabel.textAlignment = UITextAlignmentRight;
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    // Set up the cell...
	//ASiSTAppDelegate *appDelegate = (ASiSTAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (!indexPath.section)   // extra section for totals over all apps
	{
		if (indexPath.row)
		{
			cell.CELL_IMAGE = sumImage;
			
			NSInteger units = [report sumUnitsForProduct:nil transactionType:TransactionTypeSale] +
								[report sumUnitsForProduct:nil transactionType:TransactionTypeIAP];			
			
			double royalties = [report sumRoyaltiesForProduct:nil transactionType:TransactionTypeSale] +
								[report sumRoyaltiesForProduct:nil transactionType:TransactionTypeIAP];

			NSInteger refunds = [report sumRefundsForProduct:nil];
			
			cell.unitsSoldLabel.text = [NSString stringWithFormat:@"%d", units];
			cell.unitsUpdatedLabel.text = [NSString stringWithFormat:@"%d", report.sumUnitsUpdated];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			
			
			
			
			if (refunds)
			{
				cell.unitsRefundedLabel.text = [NSString stringWithFormat:@"%d", refunds];
			}
			else
			{
				cell.unitsRefundedLabel.text = @"";
			}
			
			double convertedRoyalties = [[YahooFinance sharedInstance] convertToCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:royalties fromCurrency:@"EUR"];
			cell.royaltyEarnedLabel.text = [[YahooFinance sharedInstance] formatAsCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:convertedRoyalties];
		}

		
		//cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:0.9];
		return cell;
	}
	
	
	App *rowApp = [sortedApps objectAtIndex:indexPath.section-1];  // minus one because of totals section
	
	
	//NSMutableDictionary *thisDict = [report.summariesByApp objectForKey:[NSNumber numberWithInt:rowApp.apple_identifier]];

	cell.selectionStyle = UITableViewCellSelectionStyleBlue;


	if ([rowApp inAppPurchases])
	{
		switch (indexPath.row) 
		{
			case 0:
				// header
				break;
			case 1:
			{
				// sum IAP + APP
				cell.CELL_IMAGE = sumImage;
				
				NSInteger refunds = [report sumRefundsForProduct:rowApp];
				
				NSInteger appUnits = [report sumUnitsForProduct:rowApp transactionType:TransactionTypeSale];
				NSInteger iapUnits = [report sumUnitsForInAppPurchasesOfApp:rowApp];
				
				NSInteger appUpdates = [report sumUnitsForProduct:rowApp transactionType:TransactionTypeFreeUpdate];
				double appRoyalites = [[YahooFinance sharedInstance] convertToCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:[report sumRoyaltiesForProduct:rowApp transactionType:TransactionTypeSale] fromCurrency:@"EUR"];
				double iapRoyalites = [[YahooFinance sharedInstance] convertToCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:[report sumRoyaltiesForInAppPurchasesOfApp:rowApp] fromCurrency:@"EUR"];
				

				cell.unitsSoldLabel.text = [NSString stringWithFormat:@"%d", appUnits + iapUnits];
				cell.unitsUpdatedLabel.text = [NSString stringWithFormat:@"%d", appUpdates];

				if (refunds)
				{
					cell.unitsRefundedLabel.text = [NSString stringWithFormat:@"%d", refunds];
				}
				else
				{
					cell.unitsRefundedLabel.text = @"";
				}

				cell.royaltyEarnedLabel.text = [[YahooFinance sharedInstance] formatAsCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:appRoyalites + iapRoyalites];
				break;
			}
			case 2:
			{
				// APP
				
				// summary for one app
				cell.CELL_IMAGE = rowApp.iconImageNano;
				
				cell.unitsSoldLabel.text = [NSString stringWithFormat:@"%d", [report sumUnitsForProduct:rowApp transactionType:TransactionTypeSale]];
				cell.unitsUpdatedLabel.text = [NSString stringWithFormat:@"%d", [report sumUnitsForProduct:rowApp transactionType:TransactionTypeFreeUpdate]];
				
				NSInteger refunds = [report sumRefundsForProduct:rowApp];
				if (refunds)
				{
					cell.unitsRefundedLabel.text = [NSString stringWithFormat:@"%d", refunds];
				}
				else
				{
					cell.unitsRefundedLabel.text = @"";
				}
				
				double convertedRoyalties = [[YahooFinance sharedInstance] convertToCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:[report sumRoyaltiesForProduct:rowApp transactionType:TransactionTypeSale] fromCurrency:@"EUR"];
				cell.royaltyEarnedLabel.text = [[YahooFinance sharedInstance] formatAsCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:convertedRoyalties];
				
				break;
			}
			case 3:
			{
				// IAP
				
				cell.CELL_IMAGE = [UIImage imageNamed:@"IAP_nano.png"];
				
				cell.unitsSoldLabel.text = [NSString stringWithFormat:@"%d", [report sumUnitsForInAppPurchasesOfApp:rowApp]];
				cell.unitsUpdatedLabel.text = nil;
				
				NSInteger refunds = [report sumRefundsForInAppPurchasesOfApp:rowApp];
				
				if (refunds)
				{
					cell.unitsRefundedLabel.text = [NSString stringWithFormat:@"%d", refunds];
				}
				else
				{
					cell.unitsRefundedLabel.text = @"";
				}				
				double convertedRoyalties = [[YahooFinance sharedInstance] convertToCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:[report  sumRoyaltiesForInAppPurchasesOfApp:rowApp] fromCurrency:@"EUR"];
				cell.royaltyEarnedLabel.text = [[YahooFinance sharedInstance] formatAsCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:convertedRoyalties];
				
				break;
				
				
			}
				
				
			default:
				break;
		}
		
		
		
		
		return cell;
	}
	else 
	{
		// summary for one app
		cell.CELL_IMAGE = rowApp.iconImageNano;
		
		cell.unitsSoldLabel.text = [NSString stringWithFormat:@"%d", [report  sumUnitsForProduct:rowApp transactionType:TransactionTypeSale]];
		cell.unitsUpdatedLabel.text = [NSString stringWithFormat:@"%d", [report sumUnitsForProduct:rowApp transactionType:TransactionTypeFreeUpdate]];
		NSInteger refunds = [report sumRefundsForProduct:rowApp];
		if (refunds)
		{
			cell.unitsRefundedLabel.text = [NSString stringWithFormat:@"%d", refunds];
		}
		else
		{
			cell.unitsRefundedLabel.text = @"";
		}
		
		double convertedRoyalties = [[YahooFinance sharedInstance] convertToCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:[report sumRoyaltiesForProduct:rowApp transactionType:TransactionTypeSale] fromCurrency:@"EUR"];
		cell.royaltyEarnedLabel.text = [[YahooFinance sharedInstance] formatAsCurrency:[[YahooFinance sharedInstance] mainCurrency] amount:convertedRoyalties];
		
		return cell;
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (!indexPath.row) return;
	
	GenericReportController *genericReportController = [[GenericReportController alloc] initWithReport:self.report];

	switch (indexPath.section) {
		case 0:
		{
			genericReportController.title = @"All Products";
			break;
		}
		default:
		{
			App *app =  [sortedApps objectAtIndex:indexPath.section-1];
			
			if ([app inAppPurchases])
			{
				genericReportController.title = app.title;

				switch (indexPath.row) 
				{
					case 1:
						// app + iap
						genericReportController.filteredApp = app;  // shows both
						break;
					case 2:
						// app
						[genericReportController setFilteredApp:app showApps:YES showIAPs:NO];
						break;
					case 3:
						// iap
						[genericReportController setFilteredApp:app showApps:NO showIAPs:YES];
						break;
					default:
						break;
				}
			}
			else
			{
				// app
				[genericReportController setFilteredApp:app showApps:YES showIAPs:NO];
				break;
			}

		}
	}
	[self.navigationController pushViewController:genericReportController animated:YES];
	[genericReportController release];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */






#pragma mark Actions
- (void) upDownPushed:(id)sender
{
	// cannot use sender for some reason, we get exception when accessing properties
	
	if (segmentedControl.selectedSegmentIndex == 0)
	{
		Report_v1 *newReport = [[Database sharedInstance] reportNewerThan:report];
		[self setReport:newReport];
	}
	else
	{
		Report_v1 *newReport = [[Database sharedInstance] reportOlderThan:report];
		[self setReport:newReport];
	}
}


@end

