//
//  Country.m
//  ASiST
//
//  Created by Oliver Drobnik on 29.12.08.
//  Copyright 2008 drobnik.com. All rights reserved.
//

#import "Country_v1.h"
#import "Database.h"
#import "UIImage+Helpers.h"


// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
//static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
//static sqlite3_stmt *delete_statement = nil;
//static sqlite3_stmt *delete_points_statement = nil;

//static sqlite3_stmt *hydrate_statement = nil;
//static sqlite3_stmt *dehydrate_statement = nil;

@implementation Country_v1

@synthesize iconImage, name, iso2, iso3, appStoreID, usedInReport, language;



// Creates the object with primary key and title is brought into memory.
- (id)initWithISO3:(NSString *)pk database:(sqlite3 *)db 
{
    if (self = [super init]) 
	{
        self.iso3 = pk;
        database = db;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement == nil) 
		{
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT iso2, name, app_store_id, language FROM country WHERE iso3=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
		sqlite3_bind_text(init_statement, 1, [pk UTF8String], -1, SQLITE_TRANSIENT);

        if (sqlite3_step(init_statement) == SQLITE_ROW) 
		{
			self.iso2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
			
			int app_store_id = sqlite3_column_int(init_statement, 2);
			
			if (app_store_id)
			{
				self.appStoreID = app_store_id;
			}
			
			char *lang_text = (char *)sqlite3_column_text(init_statement, 3);
			
			if (lang_text)
			{
				self.language = [NSString stringWithUTF8String:lang_text];
			}
			
			// [self loadImageFromBirne]; // that's done on demand
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
    }
	
    return self;
}

- (void)dealloc 
{
	[iconImage release];
	[name release];
	[iso2 release];
    [iso3 release];
    [super dealloc];
}

- (ReportRegion) reportRegion
{
	ReportRegion region = ReportRegionUnknown;
	NSString *cntry_code = self.iso2;
	
	if ([cntry_code isEqualToString:@"AR"]||
		[cntry_code isEqualToString:@"BR"]||
		[cntry_code isEqualToString:@"CL"]||
		[cntry_code isEqualToString:@"CO"]||
		[cntry_code isEqualToString:@"CR"]||
		[cntry_code isEqualToString:@"DO"]||
		[cntry_code isEqualToString:@"EC"]||
		[cntry_code isEqualToString:@"GT"]||
		[cntry_code isEqualToString:@"JM"]||
		[cntry_code isEqualToString:@"PE"]||
		[cntry_code isEqualToString:@"SV"]||
		[cntry_code isEqualToString:@"US"]||
		[cntry_code isEqualToString:@"UY"]||
		[cntry_code isEqualToString:@"VR"]	||
		[cntry_code isEqualToString:@"VE"]) region=ReportRegionUSA;
	else if ([cntry_code isEqualToString:@"AT"]||
			 [cntry_code isEqualToString:@"BE"]||
			 [cntry_code isEqualToString:@"CZ"]||
			 [cntry_code isEqualToString:@"DE"]||
			 [cntry_code isEqualToString:@"EE"]||
			 [cntry_code isEqualToString:@"ES"]||
			 [cntry_code isEqualToString:@"FI"]||
			 [cntry_code isEqualToString:@"FR"]||
			 [cntry_code isEqualToString:@"GR"]||
			 [cntry_code isEqualToString:@"HU"]||
			 [cntry_code isEqualToString:@"IE"]||
			 [cntry_code isEqualToString:@"IT"]||
			 [cntry_code isEqualToString:@"LT"]||
			 [cntry_code isEqualToString:@"LU"]||
			 [cntry_code isEqualToString:@"LV"]||
			 [cntry_code isEqualToString:@"MT"]||
			 [cntry_code isEqualToString:@"NL"]||
			 [cntry_code isEqualToString:@"PL"]||
			 [cntry_code isEqualToString:@"PT"]||
			 [cntry_code isEqualToString:@"RO"]||
			 [cntry_code isEqualToString:@"SI"]||
			 [cntry_code isEqualToString:@"SK"]) region=ReportRegionEurope;
	else if ([cntry_code isEqualToString:@"CA"]) region=ReportRegionCanada;
	else if ([cntry_code isEqualToString:@"AU"]) region=ReportRegionAustralia;
	else if ([cntry_code isEqualToString:@"NZ"]) region=ReportRegionNewZealand;
	else if ([cntry_code isEqualToString:@"JP"]) region=ReportRegionJapan;
	else if ([cntry_code isEqualToString:@"GB"]) region=ReportRegionUK;
	else if ([cntry_code isEqualToString:@"MX"]) region=ReportRegionMexico;
	else if ([cntry_code isEqualToString:@"CH"]) region=ReportRegionSwitzerland;
	else if ([cntry_code isEqualToString:@"NO"]) region=ReportRegionNorway;
    else if ([cntry_code isEqualToString:@"CN"]) region=ReportRegionChina;
    else if ([cntry_code isEqualToString:@"DK"]) region=ReportRegionDenmark;
    else if ([cntry_code isEqualToString:@"SE"]) region=ReportRegionSweden;
    else if ([cntry_code isEqualToString:@"SG"]) region=ReportRegionSingapore;
    else if ([cntry_code isEqualToString:@"HK"]) region=ReportRegionHongKong;
    else if ([cntry_code isEqualToString:@"TW"]) region=ReportRegionTaiwan;
	
	else region=ReportRegionRestOfWorld;
	
	
	return region;
}


- (void) loadImageFromBirne
{
	// do nothing if we already have an icon
	if (iconImage) return;
	
	// first try the local app directory
	UIImage *tmpImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", iso3]];
	if (tmpImage)
	{
		self.iconImage = tmpImage;
		return;
	}

	// secondly try the app's document directory, maybe we have downloaded it
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.iso3]];
	
	tmpImage = [UIImage imageWithContentsOfFile:path];
	
	if (tmpImage)
	{
		self.iconImage = tmpImage;
		return;
	}

	if (theConnection)
	{	
		return;
	}
	
	// thirdly, download the image from Apple and put it into the document directory
	NSString *URL=[NSString stringWithFormat:@"http://itunes.apple.com/images/flags/50/%@.jpg", [self.iso3 lowercaseString]];
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:600.0];
	theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) 
	{
		
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		if (!receivedData)
		{
			receivedData=[[NSMutableData data] retain];
		}
	}
	else
	{
		// inform the user that the download could not be made
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    //[connection release]; is autoreleased
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	receivedData = nil;
	[theConnection release];
	theConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//NSString *URL;
	//NSMutableURLRequest *theRequest;
	
	
	//NSString *sourceSt = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSASCIIStringEncoding];
	//if (![sourceSt hasPrefix:@"<"])
	{   // PNG received
		UIImage *jpgImage = [[[UIImage alloc] initWithData:receivedData] autorelease];
		UIImage *tmpImage = [jpgImage scaleImageToSize:CGSizeMake(30, 30)];
		
		[theConnection release];
		theConnection = nil;

		
		if (tmpImage)
		{
			self.iconImage = tmpImage;
		
		
			NSData *tmpData = UIImagePNGRepresentation (tmpImage);
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.iso3]];
		
			[tmpData writeToFile:path atomically:YES];
		}
		else
		{
			NSLog(@"Bad data for country image %@", iso3);
		}
	}
}


- (void) setUsedInReport:(BOOL) aBool
{
	usedInReport = aBool;
	
	// if the country is used in a report, we need an icon as well
	[self loadImageFromBirne];
}

- (NSString *)description
{
	return name;
}

@end
