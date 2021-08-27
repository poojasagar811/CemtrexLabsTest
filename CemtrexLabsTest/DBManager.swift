//
//  DBManager.swift
//  CemtrexLabsTest
//
//  Created by Pooja's MacBook Pro on 27/08/21.
//

import Foundation
import SQLite3

class DBManager {

    static let shared = DBManager()
    let tableName = "Details"
    
    private init() {
        db = openDatabase()
        createTable()
    }
    
    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?
    
    //MARK: Create DB
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return nil
        } else {
            print("Successfully opened \(fileURL.path)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS \(tableName)(Id TEXT PRIMARY KEY,name TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("\(tableName) table created.")
            } else {
                print("\(tableName) table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    //MARK: Insert Into DB
    func insert(detailsObj: Details) {
        let details = read()
        for details in details {
            if details.id == detailsObj.id {
                return
            }
        }
        let insertStatementString = "INSERT INTO \(tableName) (Id, name) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, ((detailsObj.id) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, ((detailsObj.name) as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    //MARK: Read from DB
    func read() -> [Details] {
        let queryStatementString = "SELECT * FROM \(tableName);"
        var queryStatement: OpaquePointer? = nil
        var detailsObj : [Details] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                detailsObj.append(Details(id: id, name: name))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return detailsObj
    }
    
    func readDetail(detailsObj: Details) -> [Details] {
        let queryStatementString = "SELECT * FROM \(tableName)  WHERE Id = '\(detailsObj.id)';"
        var queryStatement: OpaquePointer? = nil
        var detailsObj : [Details] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                detailsObj.append(Details(id: id, name: name))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return detailsObj
    }
    
    //MARK: Delete from DB
    func deleteByID(detailsObj: Details) {
        if self.readDetail(detailsObj: detailsObj).count != 0 {
            let deleteStatementStirng = "DELETE FROM \(tableName) WHERE Id = '\(detailsObj.id)';"
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(deleteStatement, 1, ((detailsObj.id) as NSString).utf8String, -1, nil)
                
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Successfully deleted row.")
                } else {
                    print("Could not delete row.")
                }
            } else {
                print("DELETE statement could not be prepared")
            }
            sqlite3_finalize(deleteStatement)
        }
    }
    
}
