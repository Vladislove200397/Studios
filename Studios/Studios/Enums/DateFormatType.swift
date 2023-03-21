//
//  DateFormatType.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 20.03.23.
//

import Foundation

enum FormatTypes: String {
    case EEEEMMMdYYYY = "EEEE, MMM d, yyyy"     //Wednesday, Sep 12, 2018
    case MMddyyyy = "MM/dd/yyyy"               //09/12/2018
    case MMddyyyyHHmm = "MM-dd-yyyy HH:mm"      //09-12-2018 14:11
    case dMMMHHmm = "d MMMM, HH:mm"            //12 September, 2:11
    case MMMMyyyy = "MMMM yyyy"               //September 2018
    case MMMdyyyy = "MMM d, yyyy"             //Sep 12, 2018
    case ddMMyy = "dd.MM.yy"                  //12.09.18
    case HHmm = "HH:mm"                     //14:11
    case ddMMyyyy = "dd-MM-yyyy"            //12-09-2022
    case dd = "dd"
    case E = "E"
}
