//
//  ReportRootController.m
//  ASiST
//
//  Created by Oliver Drobnik on 17.01.09.
//  Copyright 2009 drobnik.com. All rights reserved.
//

#import "ReportRootController.h"
#import "ReportViewController.h"
#import "ASiSTAppDelegate.h"
#import "Report_v1.h"


@implementation ReportRootController

@synthesize reloadButtonItem;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	report_icon = [[UIImage imageNamed:@"Report_Icon.png"] retain];
	report_icon_new = [[UIImage imageNamed:@"Report_Icon_New.png"] retain];


	// after loading we can get the badges updated via notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newReportNotification:) name:@"NewReportAdded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newReportRead:) name:@"NewReportRead" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchingDone:) name:@"AllDownloadsFinished" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchingStarted:) name:@"SynchingStarted" object:nil];

}



// new Reports cause update of badges
- (void)newReportNotification:(NSNotification *) notification
{
	[self.tableView reloadData];  // to change icon where there are new reports
}

// new Reports cause update of badges
- (void)newReportRead:(NSNotification *) notification
{
	[self.tableView reloadData];  // to change icon where there are new reports
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//[self.tableView reloadData];   // new indicator might have changed
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	switch (indexPath.row) 
	{
		case 0:
			cell.CELL_LABEL = @"Days";
			break;
		case 1:
			cell.CELL_LABEL = @"Weeks";
			break;
		case 2:
			cell.CELL_LABEL = @"Month (Financial)";
			break;
		case 3:
			cell.CELL_LABEL = @"Month (Free)";
			break;
		default:
			break;
	}

	if ([DB hasNewReportsOfType:(ReportType)indexPath.row])
	{
		cell.CELL_IMAGE = report_icon_new;
	}
	else
	{
		cell.CELL_IMAGE = report_icon;
	}
	
	/*
	if ([DB countOfReportsForType:indexPath.row])
	{
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	 */
	
	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	
	 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (![DB countOfReportsForType:indexPath.row])
	{
		return;
	}
	
	
	NSArray *tmpArray = [DB sortedReportsOfType:indexPath.row];
	 
	
	ReportViewController *reportViewController = [[ReportViewController alloc] initWithReportArray:tmpArray reportType:indexPath.row style:UITableViewStylePlain];
	[self.navigationController pushViewController:reportViewController animated:YES];
	[reportViewController release];
}

// The accessory type is the image displayed on the far right of each table cell. In order for the delegate method
// tableView:accessoryButtonClickedForRowWithIndexPath: to be called, you must return the "Detail Disclosure Button" type.
/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
{
	if ([DB countOfReportsForType:indexPath.row])
	{
		return UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		return UITableViewCellAccessoryNone;
	}
}
*/
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


- (void)dealloc {
	// Remove notification observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[reloadButtonItem release];
	[report_icon_new release];
	[report_icon release];
    [super dealloc];
}


#pragma mark Direct Navigation

- (void)gotoReport:(Report_v1 *)reportToShow
{
	NSArray *tmpArray = [DB sortedReportsOfType:reportToShow.reportType];
	
	ReportViewController *reportViewController = [[ReportViewController alloc] initWithReportArray:tmpArray reportType:reportToShow.reportType style:UITableViewStylePlain];
	[self.navigationController pushViewController:reportViewController animated:YES];
	[reportViewController release];
	
	[reportViewController gotoReport:reportToShow];
}

- (void)gotToReportType:(ReportType)typeToShow
{
	NSArray *tmpArray = [DB sortedReportsOfType:typeToShow];
	
	ReportViewController *reportViewController = [[ReportViewController alloc] initWithReportArray:tmpArray reportType:typeToShow style:UITableViewStylePlain];
	[self.navigationController pushViewController:reportViewController animated:YES];
	[reportViewController release];
}

#pragma mark Notifications
- (void)synchingStarted:(NSNotification *)notification
{
	[reloadButtonItem setEnabled:NO];
}

- (void)synchingDone:(NSNotification *)notification
{
	[reloadButtonItem setEnabled:YES];
}

- (void)reloadReports:(id)sender
{
	ASiSTAppDelegate *appDelegate = (ASiSTAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate startSync];
}

@end

