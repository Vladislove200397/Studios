//
//  typealisHelper.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 6.03.23.
//

import UIKit

typealias VoidBlock = () -> Void
typealias RequestBlock = () -> Void
typealias FirebaseBookingBlock = (FirebaseBookingModel) -> Void
typealias BoolBlock = (Bool) -> Void
typealias ErrorBlock = (Error) -> Void
typealias ArrayIntBlock = ([Int]) -> Void
typealias FirebaseArrayBookingBlock = ([FirebaseBookingModel]) -> Void
typealias StringBlock = (String) -> Void
typealias FirebaseUserBlock = ((FirebaseUser) -> Void)
typealias FirebaseArrayLikedStudioBlock = ([FirebaseLikedStudioModel]) -> Void
typealias ImageBlock = (UIImage) -> Void
typealias URLBlock = (URL) -> Void
