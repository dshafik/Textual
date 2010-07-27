#import "ListView.h"

@implementation ListView

@synthesize keyDelegate;
@synthesize textDelegate;

- (NSInteger)countSelectedRows
{
	return [[self selectedRowIndexes] count];
}

- (void)selectItemAtIndex:(NSInteger)index
{
	[self selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	[self scrollRowToVisible:index];
}

- (void)selectRows:(NSArray*)indices
{
	[self selectRows:indices extendSelection:NO];
}

- (void)selectRows:(NSArray*)indices extendSelection:(BOOL)extend
{
	NSMutableIndexSet* set = [NSMutableIndexSet indexSet];
	for (NSNumber* n in indices) {
		[set addIndex:[n integerValue]];
	}
	
	[self selectRowIndexes:set byExtendingSelection:extend];
}

- (void)rightMouseDown:(NSEvent *)e
{
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];
	NSInteger i = [self rowAtPoint:p];
	if (i >= 0) {
		if (![[self selectedRowIndexes] containsIndex:i]) {
			[self selectItemAtIndex:i];
		}
	}
	
	[super rightMouseDown:e];
}

- (void)setFont:(NSFont*)font
{
	for (NSTableColumn* column in [self tableColumns]) {
		[[column dataCell] setFont:font];
	}
	
	NSRect f = [self frame];
	f.size.height = 1e+37;
	CGFloat height = ceil([[[[self tableColumns] safeObjectAtIndex:0] dataCell] cellSizeForBounds:f].height);
	[self setRowHeight:height];
	[self setNeedsDisplay:YES];
}

- (NSFont*)font
{
	return [[[[self tableColumns] safeObjectAtIndex:0] dataCell] font];
}

- (void)keyDown:(NSEvent *)e
{
	if (keyDelegate) {
		switch ([e keyCode]) {
			case 51:
			case 117:	// delete
				if ([self countSelectedRows] > 0) {
					if ([keyDelegate respondsToSelector:@selector(listViewDelete)]) {
						[keyDelegate listViewDelete];
						return;
					}
				}
				break;
			case 126:	// up
			{
				NSIndexSet* set = [self selectedRowIndexes];
				if ([set count] > 0 && [set containsIndex:0]) {
					if ([keyDelegate respondsToSelector:@selector(listViewMoveUp)]) {
						[keyDelegate listViewMoveUp];
						return;
					}
				}
				break;
			}
			case 116:	// page up
			case 121:	// page down
			case 123 ... 125:	// cursor keys
				break;
			default:
				if ([keyDelegate respondsToSelector:@selector(listViewKeyDown:)]) {
					[keyDelegate listViewKeyDown:e];
				}
				break;
		}
	}
	
	[super keyDown:e];
}

- (void)textDidEndEditing:(NSNotification*)note
{
	if ([textDelegate respondsToSelector:@selector(textDidEndEditing:)]) {
		[textDelegate textDidEndEditing:note];
	} else {
		[super textDidEndEditing:note];
	}
}

@end