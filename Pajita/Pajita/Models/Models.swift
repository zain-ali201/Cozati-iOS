//
//  ExpenseModel.swift
//  Pajita
//
//  Created by Zain Ali on 09/12/2019.
//  Copyright © 2019 Zain Ali. All rights reserved.
//

import UIKit
import ObjectMapper

class ExpenseDTO: Mappable
{
    var id: Int?
    var amountWithVat: Double?
    var amountWithoutVat: Double?
    var totalAmount: Double?
    var validedAmount: Double?
    var totalExpense: Double?
    var country: SelectDTO?
    var description: String?
    var expenseDate: String?
    var expenseStatus: SelectDTO?
    var expenseSummary: ExpenseSummaryDTO?
    var expenseType: SelectDTO?
    var missionId: Int?
    var missionName: String?
    var month: Int?
    var monthLabel: String?
    var resourceId: Int?
    var resourceName: String?
    var vat: String?
    var vatAmount: String?
    var year: Int?
    var status: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        id <- map["id"]
        amountWithVat <- map["amountWithVat"]
        amountWithoutVat <- map["amountWithoutVat"]
        totalAmount <- map["totalAmount"]
        country <- map["country"]
        description <- map["description"]
        expenseDate <- map["expenseDate"]
        expenseStatus <- map["expenseStatus"]
        expenseSummary <- map["expenseSummary"]
        expenseType <- map["expenseType"]
        missionId <- map["missionId"]
        missionName <- map["missionName"]
        month <- map["month"]
        monthLabel <- map["monthLabel"]
        resourceId <- map["resourceId"]
        resourceName <- map["resourceName"]
        vat <- map["vat"]
        vatAmount <- map["vatAmount"]
        year <- map["year"]
        status <- map["status"]
        validedAmount <- map["totalValided"]
        totalExpense <- map["nbExpense"]
    }
}

class SelectDTO: Mappable
{
    var id: Int?
    var code: String?
    var description: String?
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        id <- map["id"]
        code <- map["code"]
        description <- map["description"]
    }
}

class ExpenseSummaryDTO: Mappable
{
    var id: Int?
    var amountWithVat: String?
    var amountWithoutVat: String?
    var comment: String?
    var createdBy: String?
    var expenseStatus: SelectDTO?
    var modifiedBy: String?
    var month : Int?
    var resourceId : Int?
    var resourceName: String?
    var year: Int?
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        id <- map["id"]
        amountWithVat <- map["amountWithVat"]
        amountWithoutVat <- map["amountWithoutVat"]
        comment <- map["comment"]
        createdBy <- map["createdBy"]
        expenseStatus <- map["expenseStatus"]
        month <- map["month"]
        resourceId <- map["resourceId"]
        resourceName <- map["resourceName"]
        modifiedBy <- map["modifiedBy"]
        year <- map["year"]
    }
}

class UserDTO: Mappable
{
    var email: String?
    var firstName: String?
    var lastName: String?
    var permissionList:[String] = []
    var resourceId: Int?
    var roleId: Int?
    var roleNamestring: String?
    var token: String?
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        email <- map["email"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        permissionList <- map["permissionList"]
        resourceId <- map["resourceId"]
        roleId <- map["roleId"]
        roleNamestring <- map["roleNamestring"]
        token <- map["token"]
    }
}

class TimesheetListDTO: Mappable
{
    var timesheetId: Int?
    var resourceId: Int?
    var firstName: String?
    var lastName: String?
    var month: Int?
    var year: Int?
    var monthLabel: String?
    var totalPresence: Double?
    var totalExtraHours: Double?
    var totalExtraHourNight: Double?
    var totalNightShift: Double?
    var statusId: Int?
    var statusCode: String?
    var missionName: String?
    var missionId: Int?
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        timesheetId <- map["timesheetId"]
        resourceId <- map["resourceId"]
        firstName <- map["resourceFirstName"]
        lastName <- map["resourceLastName"]
        month <- map["month"]
        year <- map["year"]
        monthLabel <- map["monthLabel"]
        totalPresence <- map["totalPresence"]
        totalExtraHours <- map["totalExtraHours"]
        totalExtraHourNight <- map["totalExtraHourNight"]
        totalNightShift <- map["totalNightShift"]
        statusId <- map["statusId"]
        statusCode <- map["statusCode"]
        missionId <- map["missionId"]
        missionName <- map["missionName"]
    }
}

class TimesheetDTO: Mappable
{
    var timesheetId: Int?
    var year: Int?
    var resourceId: Int?
    var resourceFirstName: String?
    var resourceLastName: String?
    var missionId: Int?
    var missionName: String?
    var month: Int?
    var monthLabel: String?
    var lineArray: [LineDTO] = []
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        timesheetId <- map["timesheetId"]
        year <- map["year"]
        resourceId <- map["resourceId"]
        resourceFirstName <- map["resourceFirstName"]
        resourceLastName <- map["resourceLastName"]
        missionId <- map["missionId"]
        missionName <- map["missionName"]
        month <- map["month"]
        missionName <- map["missionName"]
        lineArray <- map["lines"]
    }
}

class TimesheetSummary: Mappable
{
    var totalLeaves: Double?
    var totalSickness: Double?
    var totalWorked: Double?
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        totalLeaves <- map["totalLeave"]
        totalSickness <- map["totalSickness"]
        totalWorked <- map["totalWorked"]
    }
}

class LineDTO: Mappable
{
    var id: Int?
    var timesheetId: Int?
    var descp: String?
    var day: Int?
    var dayCode: String?
    var weekend: Bool?
    var holiday: Bool?
    var presence: Double?
    var extraWorkDay: Double?
    var extraWorkNight: Double?
    var nightShift: Double?
    var disabled: Bool?
    
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        id <- map["id"]
        timesheetId <- map["timesheetId"]
        descp <- map["description"]
        day <- map["day"]
        dayCode <- map["dayCode"]
        weekend <- map["weekend"]
        holiday <- map["holiday"]
        presence <- map["presence"]
        extraWorkDay <- map["extraWorkDay"]
        extraWorkNight <- map["extraWorkNight"]
        nightShift <- map["nightShift"]
        disabled <- map["disabled"]
    }
}

class MissionDTO: Mappable
{
    var clientId: Int?
    var clientName: String?
    var endDate: String?
    var finalClientId: Int?
    var finalClientName: String?
    var missionId: Int?
    var missionName: String?
    var missionReference: String?
    var startDate: String?
    var totalAssignedResource: Int?
    
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        clientId <- map["clientId"]
        clientName <- map["clientName"]
        endDate <- map["endDate"]
        finalClientId <- map["finalClientId"]
        finalClientName <- map["finalClientName"]
        missionId <- map["missionId"]
        missionName <- map["missionName"]
        missionReference <- map["missionReference"]
        startDate <- map["startDate"]
        totalAssignedResource <- map["totalAssignedResource"]
    }
}

class LeaveDTO: Mappable
{
    var leaveId: Int?
    var resourceId: Int?
    var resourceFirstName: String?
    var resourceLastName: String?
    var typeCode: String?
    var year: Int?
    var startDate: String?
    var endDate: String?
    var statusId: Int?
    var statusCode: String?
    var typeId: String?
    var title: String?
    var total: Double?
    
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        leaveId <- map["leaveId"]
        resourceId <- map["resourceId"]
        resourceFirstName <- map["resourceFirstName"]
        resourceLastName <- map["resourceLastName"]
        typeCode <- map["typeCode"]
        year <- map["year"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        statusId <- map["statusId"]
        statusCode <- map["statusCode"]
        typeId <- map["typeId"]
        title <- map["title"]
        total <- map["total"]
    }
}

class LeaveDayDTO: Mappable
{
    var id: Int?
    var afternoonValue: Int?
    var date: String?
    var day: Int?
    var dayCode: String?
    var holyday: Bool?
    var morningValue: Int?
    var month: Int?
    var weekend: Bool?
    var year: Int?
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        id <- map["id"]
        afternoonValue <- map["afternoonValue"]
        date <- map["date"]
        dayCode <- map["dayCode"]
        day <- map["day"]
        year <- map["year"]
        holyday <- map["holyday"]
        morningValue <- map["morningValue"]
        month <- map["month"]
        weekend <- map["weekend"]
        year <- map["year"]
    }
}

class LeaveSummaryDTO: Mappable
{
    var typeId: Int?
    var totalRemaining: Int?
    var totalUsed: Int?
    var totalBalance: Int?
    var totalAsked: Int?
    var totalBalanceAfterAsked: Int?
    var resourceId: Int?
    var resourceFirstName: String?
    var resourceLastName: String?
    
    
    required init?(map: Map){

    }
    
    func mapping(map: Map)
    {
        typeId <- map["typeId"]
        totalRemaining <- map["totalRemaining"]
        totalUsed <- map["totalUsed"]
        totalBalance <- map["totalBalance"]
        totalAsked <- map["totalAsked"]
        totalBalanceAfterAsked <- map["totalBalanceAfterAsked"]
        resourceId <- map["resourceId"]
        resourceFirstName <- map["resourceFirstName"]
        resourceLastName <- map["resourceLastName"]
    }
}
