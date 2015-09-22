//
//  CEDatabasePrivateCommon.m
//  CEDatabase
//
//  Created by chance on 14-10-8.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import "CEDatabasePrivateCommon.h"

// Sqlite关键字
NSSet *SqliteKeywords() {
    static NSSet *sqliteKeywords = nil;
    if (!sqliteKeywords) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sqliteKeywords = [NSSet setWithObjects:@"ABORT", @"ACTION", @"ADD", @"AFTER", @"ALL", @"ALTER", @"ANALYZE", @"AND", @"AS", @"ASC", @"ATTACH", @"AUTOINCREMENT", @"BEFORE", @"BEGIN", @"BETWEEN", @"BY", @"CASCADE", @"CASE", @"CAST", @"CHECK", @"COLLATE", @"COLUMN", @"COMMIT", @"CONFLICT", @"CONSTRAINT", @"CREATE", @"CROSS", @"CURRENT_DATE", @"CURRENT_TIME", @"CURRENT_TIMESTAMP", @"DATABASE", @"DEFAULT", @"DEFERRABLE", @"DEFERRED", @"DELETE", @"DESC", @"DETACH", @"DISTINCT", @"DROP", @"EACH", @"ELSE", @"END", @"ESCAPE", @"EXCEPT", @"EXCLUSIVE", @"EXISTS", @"EXPLAIN", @"FAIL", @"FOR", @"FOREIGN", @"FROM", @"FULL", @"GLOB", @"GROUP", @"HAVING", @"IF", @"IGNORE", @"IMMEDIATE", @"IN", @"INDEX", @"INDEXED", @"INITIALLY", @"INNER", @"INSERT", @"INSTEAD", @"INTERSECT", @"INTO", @"IS", @"ISNULL", @"JOIN", @"KEY", @"LEFT", @"LIKE", @"LIMIT", @"MATCH", @"NATURAL", @"NO", @"NOT", @"NOTNULL", @"NULL", @"OF", @"OFFSET", @"ON", @"OR", @"ORDER", @"OUTER", @"PLAN", @"PRAGMA", @"PRIMARY", @"QUERY", @"RAISE", @"RECURSIVE", @"REFERENCES", @"REGEXP", @"REINDEX", @"RELEASE", @"RENAME", @"REPLACE", @"RESTRICT", @"RIGHT", @"ROLLBACK", @"ROW", @"SAVEPOINT", @"SELECT", @"SET", @"TABLE", @"TEMP", @"TEMPORARY", @"THEN", @"TO", @"TRANSACTION", @"TRIGGER", @"UNION", @"UNIQUE", @"UPDATE", @"USING", @"VACUUM", @"VALUES", @"VIEW", @"VIRTUAL", @"WHEN", @"WHERE", @"WITH", @"WITHOUT", @"ROWID", nil];
        });
    }
    return sqliteKeywords;
}


// ObjC类型转换为Sqlite类型字典
NSDictionary *ObjCToSqliteTypeDict() {
    static NSDictionary *objcToSqliteTypeDict = nil;
    if (!objcToSqliteTypeDict) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            objcToSqliteTypeDict =
            @{@"b" : @"BOOLEAN",
              @"c" : @"INTEGER",
              @"s" : @"INTEGER",
              @"i" : @"INTEGER",
              @"l" : @"INTEGER",
              @"q" : @"INTEGER",
              @"d" : @"DOUBLE",
              @"f" : @"FLOAT",
              @"NSString" : @"TEXT",
              @"NSMutableString" : @"TEXT",
              @"NSArray" : @"BLOB",
              @"NSMutableArray" : @"BLOB",
              @"NSDictionary" : @"BLOB",
              @"NSMutableDictionary" : @"BLOB",
              @"NSData" : @"BLOB",
              @"NSMutableData" : @"BLOB",
              @"NSSet" : @"BLOB",
              @"NSMutableSet" : @"BLOB",
              @"NSValue" : @"BLOB",
              @"NSDate" : @"DATE",
              @"NSNumber" : @"REAL"};
        });
    }
    return objcToSqliteTypeDict;
}


// conver string to legal sqlite table name
NSString *ConvertToSqliteTableName(NSString *tableName) {
    if ([SqliteKeywords() containsObject:tableName.uppercaseString]) {
        return [tableName stringByAppendingString:@"__"];
        
    } else {
        return tableName;
    }
}



@implementation ColumnInfo

@end


