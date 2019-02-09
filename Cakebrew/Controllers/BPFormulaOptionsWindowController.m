//
//  BPFormulaOptionsWindowController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 21/08/14.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.	If not, see <http://www.gnu.org/licenses/>.
//

#import "BPFormulaOptionsWindowController.h"
#import "BPFormula.h"
#import "BPAppDelegate.h"

//these constants must match arraycontroller in XIB (array controller + binding on table columns)
static NSString * const kFormulaOptionCommand = @"formulaOptionCommand";
static NSString * const kIsFormulaOptionCommandApplied = @"isFormulaOptionCommandApplied";
static NSString * const kFormulaOptionDescription = @"formulaOptionDescription";

static NSString * const kFormulaOptionsTitleColumnId = @"title";

@interface BPFormulaOptionsWindowController () <NSTableViewDelegate>

@property (weak) IBOutlet NSTextField *userHelpLabel;
@property (weak) IBOutlet NSTextField *formulaNameLabel;
@property (weak) IBOutlet NSTextField *optionDetailsTextField;
@property (weak) IBOutlet NSTableView *formulaOptionsTableView;
@property (strong) IBOutlet NSArrayController *formulasArrayController;

@property (nonatomic, strong) NSMutableArray *availableOptions;
@property (strong) BPFormula *formula;

@end

@implementation BPFormulaOptionsWindowController

- (void)awakeFromNib {
	
	NSUInteger numberOfFormulaOptions = [self.availableOptions count];
	if (numberOfFormulaOptions > 0) {
		[self.userHelpLabel setStringValue:NSLocalizedString(@"Formula_Options_ClickForDetails", nil)];
	} else {
		[self.userHelpLabel setStringValue:NSLocalizedString(@"Formula_Options_NoOptions", nil)];
	}
	[self.optionDetailsTextField setAccessibilityLabel:NSLocalizedString(@"Formula_Options_VoiceOver_Description", nil)];
	
	//load array controller with array of mutable dictionaries with options
	[self.formulasArrayController addObjects:self.availableOptions];
	
	self.formulaNameLabel.stringValue = self.formula.name;
	
	[self.formulaOptionsTableView reloadData];
	[self.optionDetailsTextField setAccessibilityLabel:NSLocalizedString(@"Formula_Options_VoiceOver", nil)];
}

+ (BPFormulaOptionsWindowController *)runFormula:(BPFormula *)formula withCompletionBlock:(InstalWithOptionsBlock_t)completionBlock
{
	BPFormulaOptionsWindowController *formulaOptionsWindowController;
	formulaOptionsWindowController = [[BPFormulaOptionsWindowController alloc] initWithWindowNibName:@"BPFormulaOptionsWindow"];
	formulaOptionsWindowController.formula = formula;
	formulaOptionsWindowController.installWithOptionsBlock = completionBlock;
	NSMutableArray *availableOptions = [[NSMutableArray alloc] init];
	
	for (BPFormulaOption *option in [formula options]) {
		id optionCommand = option.name;
		id optionDescription = option.explanation ? : @"";
		if (optionCommand) {
			
			// We want to be able to modify content of kWantsToInstallOption within table view
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{ kFormulaOptionCommand : optionCommand,
																								 kIsFormulaOptionCommandApplied : @NO,
																								 kFormulaOptionDescription : optionDescription}];
			[availableOptions addObject:dictionary];
		}
	}
	formulaOptionsWindowController.availableOptions = availableOptions;
	
	
	NSWindow *formulaWindow = formulaOptionsWindowController.window;
	[BPAppDelegateRef setRunningBackgroundTask:YES];
	
	if ([[NSApp mainWindow] respondsToSelector:@selector(beginSheet:completionHandler:)]) {
		[[NSApp mainWindow] beginSheet:formulaWindow completionHandler:^(NSModalResponse returnCode) {
			if (returnCode == NSModalResponseStop) {
				NSArray *options = [formulaOptionsWindowController allSelectedOptions];
				formulaOptionsWindowController.installWithOptionsBlock(options);
			} else {
				[BPAppDelegateRef setRunningBackgroundTask:NO];
			}
			
		}];
	} else {
		[[NSApp mainWindow] beginSheet:formulaWindow completionHandler:^(NSModalResponse returnCode) {
			if(returnCode == NSModalResponseStop) {
				NSArray *options = [formulaOptionsWindowController allSelectedOptions];
				formulaOptionsWindowController.installWithOptionsBlock(options);
			} else {
				[BPAppDelegateRef setRunningBackgroundTask:NO];
			}
		}];
	}
	return formulaOptionsWindowController;
}

/*
 * Return an array with formula options that user wants to use with formula
 */
- (NSArray *)allSelectedOptions {
	NSPredicate *selectedFormulas = [NSPredicate predicateWithFormat:@"%K == %@", kIsFormulaOptionCommandApplied, @YES];
	NSArray *filteredArray = [self.availableOptions filteredArrayUsingPredicate:selectedFormulas];
	NSArray *allOptions = [filteredArray valueForKeyPath:kFormulaOptionCommand];
	return allOptions;
}

- (IBAction)cancel:(id)sender {
	NSWindow *mainWindow = [NSApp mainWindow];
	[mainWindow endSheet:self.window returnCode:NSModalResponseAbort];
}

- (IBAction)install:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:NSLocalizedString(@"Generic_Attention", nil)];
	[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"Confirmation_Install_Formula", nil), self.formula.name]];
	[alert addButtonWithTitle:NSLocalizedString(@"Generic_Yes", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"Generic_Cancel", nil)];
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	
	
	NSInteger returnValue = [alert runModal];
	NSInteger modalResponse = NSModalResponseStop;
	if (returnValue == NSAlertFirstButtonReturn) {
		
	} else {
		modalResponse = NSModalResponseAbort;
	}
	
	NSWindow *mainWindow = [NSApp mainWindow];
	[mainWindow endSheet:self.window returnCode:modalResponse];
}

-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([tableColumn.identifier isEqualToString:kFormulaOptionsTitleColumnId]) {
		[cell setAccessibilityLabel:[[_formulasArrayController.arrangedObjects objectAtIndex:row] valueForKey:kFormulaOptionDescription]];
	}
}

-(NSString*)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{
	return [[_formulasArrayController.arrangedObjects objectAtIndex:row] valueForKey:kFormulaOptionDescription];
}

@end
