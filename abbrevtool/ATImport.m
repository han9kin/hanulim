/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import "ATImport.h"
#import "HNDataController.h"


@implementation ATImport

- (id)init
{
    self = [super init];

    if (self)
    {
        mPredicateAbbrev    = [[NSPredicate predicateWithFormat:@"abbrev == $ABBREV"] retain];
        mPredicateExpansion = [[NSPredicate predicateWithFormat:@"abbrev == $ABBREV and expansion == $EXPANSION"] retain];
        mFetchReqAbbrev     = [[NSFetchRequest alloc] init];
        mFetchReqExpansion  = [[NSFetchRequest alloc] init];

        [mFetchReqAbbrev setEntity:[NSEntityDescription entityForName:@"Abbrev" inManagedObjectContext:[[HNDataController sharedInstance] managedObjectContext]]];
        [mFetchReqExpansion setEntity:[NSEntityDescription entityForName:@"Expansion" inManagedObjectContext:[[HNDataController sharedInstance] managedObjectContext]]];

        mUsesFilter = NO;
    }

    return self;
}

- (void)dealloc
{
    [mFetchReqAbbrev release];
    [mFetchReqExpansion release];
    [mPredicateAbbrev release];
    [mPredicateExpansion release];

    [super dealloc];
}

- (NSManagedObject *)abbrevForString:(NSString *)aString createIfNotExist:(BOOL)aCreate
{
    NSManagedObjectContext *sContext = [[HNDataController sharedInstance] managedObjectContext];
    NSArray                *sResult;
    NSManagedObject        *sObject;
    NSError                *sError;

    [mFetchReqAbbrev setPredicate:[mPredicateAbbrev predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:aString forKey:@"ABBREV"]]];

    sResult = [sContext executeFetchRequest:mFetchReqAbbrev error:&sError];

    if (sResult)
    {
        if ([sResult count] == 0)
        {
            if (aCreate)
            {
                sObject = [NSEntityDescription insertNewObjectForEntityForName:@"Abbrev" inManagedObjectContext:sContext];

                [sObject setValue:aString forKey:@"abbrev"];

                return sObject;
            }
        }
        else if ([sResult count] == 1)
        {
            return [sResult objectAtIndex:0];
        }
        else
        {
            NSLog(@"Too many abbrev records for %@", aString);
        }
    }
    else
    {
        NSLog(@"Error for fetching abbrev %@", aString);
        NSLog(@"%@", sError);
    }

    return nil;
}

- (NSManagedObject *)categoryForName:(NSString *)aCategory createIfNotExist:(BOOL)aCreate
{
    NSManagedObjectContext *sContext = [[HNDataController sharedInstance] managedObjectContext];
    NSFetchRequest         *sRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSManagedObject        *sCategory;
    NSArray                *sResult;
    NSError                *sError;

    [sRequest setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:sContext]];
    [sRequest setPredicate:[NSPredicate predicateWithFormat:@"category == %@", aCategory]];

    sResult = [sContext executeFetchRequest:sRequest error:&sError];

    if (sResult)
    {
        if ([sResult count] == 0)
        {
            if (aCreate)
            {
                sCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:sContext];

                [sCategory setValue:aCategory forKey:@"category"];

                return sCategory;
            }
        }
        else if ([sResult count] > 0)
        {
            return [sResult objectAtIndex:0];
        }
        else
        {
            NSLog(@"Too many category records for %@", aCategory);
        }
    }
    else
    {
        NSLog(@"Error for fetching category %@", aCategory);
        NSLog(@"%@", sError);
    }

    return nil;
}

- (NSManagedObject *)expansionForAbbrev:(NSManagedObject *)aAbbrev withString:(NSString *)aString
{
    NSManagedObjectContext *sContext = [[HNDataController sharedInstance] managedObjectContext];
    NSArray                *sResult;
    NSError                *sError;

    [mFetchReqExpansion setPredicate:[mPredicateExpansion predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:aAbbrev, @"ABBREV", aString, @"EXPANSION", nil]]];

    sResult = [sContext executeFetchRequest:mFetchReqExpansion error:&sError];

    if (sResult)
    {
        if ([sResult count] == 0)
        {
            return [NSEntityDescription insertNewObjectForEntityForName:@"Expansion" inManagedObjectContext:sContext];
        }
        else if ([sResult count] == 1)
        {
            return [sResult objectAtIndex:0];
        }
        else
        {
            NSLog(@"Too many expansion records for %@:%@", [aAbbrev valueForKey:@"abbrev"], aString);
        }
    }
    else
    {
        NSLog(@"Error for fetching expansion %@:%@", [aAbbrev valueForKey:@"abbrev"], aString);
        NSLog(@"%@", sError);
    }

    return nil;
}

- (BOOL)shouldImportExpansion:(NSString *)aExpansion forAbbrev:(NSString *)aAbbrev
{
    NSRange     sRange;
    NSUInteger  sLen;
    NSUInteger  i;

    sLen = [aAbbrev length];

    for (i = 0; i < sLen; i++)
    {
        sRange = [aExpansion rangeOfString:[aAbbrev substringWithRange:NSMakeRange(i, 1)]];

        if (sRange.location != NSNotFound)
        {
            return NO;
        }
    }

    return YES;
}

- (BOOL)addExpansion:(NSString *)aExpansion annotation:(NSString *)aAnnotation forAbbrev:(NSString *)aAbbrev inCategory:(NSManagedObject *)aCategory
{
    NSManagedObject *sAbbrev;
    NSManagedObject *sExpansion;
    BOOL             sShouldImport;

    if (mUsesFilter)
    {
        sShouldImport = [self shouldImportExpansion:aExpansion forAbbrev:aAbbrev];
    }
    else
    {
        sShouldImport = YES;
    }

    if (sShouldImport)
    {
        sAbbrev    = [self abbrevForString:aAbbrev createIfNotExist:YES];
        sExpansion = [self expansionForAbbrev:sAbbrev withString:aExpansion];

        [sExpansion setValue:sAbbrev forKey:@"abbrev"];
        [sExpansion setValue:aCategory forKey:@"category"];
        [sExpansion setValue:aExpansion forKey:@"expansion"];

        if ([aAnnotation length])
        {
            [sExpansion setValue:aAnnotation forKey:@"annotation"];
        }
    }

    return sShouldImport;
}

- (void)importFromPath:(NSString *)aPath inCategory:(NSManagedObject *)aCategory
{
    NSAutoreleasePool *sPool;
    NSString          *sContents;
    NSArray           *sLines;
    NSString          *sLine;
    NSArray           *sVals;
    NSError           *sError;

    sContents = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:&sError];

    if (!sContents)
    {
        NSLog(@"%@", sError);
    }

    sLines = [sContents componentsSeparatedByString:@"\n"];

    for (sLine in sLines)
    {
        sPool = [[NSAutoreleasePool alloc] init];

        if (![sLine hasPrefix:@"#"])
        {
            sVals = [sLine componentsSeparatedByString:@":"];

            if ([sVals count] == 3)
            {
                mProcessCount++;

                if ([self addExpansion:[sVals objectAtIndex:1] annotation:[sVals objectAtIndex:2] forAbbrev:[sVals objectAtIndex:0] inCategory:aCategory])
                {
                    mImportCount++;
                }

                if ((mProcessCount % 1000) == 0)
                {
                    if (![[[HNDataController sharedInstance] managedObjectContext] save:&sError])
                    {
                        NSLog(@"%@", sError);
                        NSLog(@"%@", [sError userInfo]);
                    }

                    NSLog(@"%d records processed, %d records imported", mProcessCount, mImportCount);
                }
            }
        }

        [sPool release];
    }
}

- (void)doWithArguments:(NSArray *)aArgs
{
    NSEnumerator   *sEnumerator;
    NSString       *sObj;
    NSString       *sOutFile = nil;
    NSMutableArray *sInFiles;
    NSError        *sError;

    sEnumerator = [aArgs objectEnumerator];
    sInFiles    = [NSMutableArray array];

    for (sObj in sEnumerator)
    {
        if ([sObj isEqualToString:@"-o"])
        {
            sOutFile = [sEnumerator nextObject];
        }
        else if ([sObj isEqualToString:@"-f"])
        {
            mUsesFilter = YES;
        }
        else
        {
            [sInFiles addObject:sObj];
        }
    }

    if (sOutFile)
    {
        [[[HNDataController sharedInstance] managedObjectContext] setUndoManager:nil];

        sError = [[HNDataController sharedInstance] addPersistentStoreAtPath:sOutFile];

        if (sError)
        {
            NSLog(@"%@", sError);
        }
        else
        {
            NSManagedObject *sCategory = [self categoryForName:[[sOutFile lastPathComponent] stringByDeletingPathExtension] createIfNotExist:YES];

            mProcessCount = 0;
            mImportCount  = 0;

            for (sObj in sInFiles)
            {
                [self importFromPath:sObj inCategory:sCategory];

                if (![[[HNDataController sharedInstance] managedObjectContext] save:&sError])
                {
                    NSLog(@"%@", sError);
                    NSLog(@"%@", [sError userInfo]);
                }
            }

            NSLog(@"%d records processed, %d records imported", mProcessCount, mImportCount);
        }
    }
}

@end
