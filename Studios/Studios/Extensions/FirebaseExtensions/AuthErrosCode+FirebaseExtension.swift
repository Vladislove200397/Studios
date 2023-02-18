//
//  AuthErrosCode+Extension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 14.02.23.
//

import FirebaseAuth

extension Error {
    func castToFirebaseError() -> String {
        guard let errorCode = self as? AuthErrorCode else { return ""}
        let errorCodes = AuthErrorCode(errorCode.code)
       return errorCodes.authErrorMessage
    }
}

extension AuthErrorCode {
    var authErrorMessage: String {
        switch self.code {
        case .emailAlreadyInUse:
                return "Выбранный email уже используется с другой учетной записью. Выберите другой email."
            case .userNotFound:
                return "Учетная запись не найдена. \nПожалуйста, проверьте введенные данные и попробуйте еще раз."
            case .userDisabled:
                return "Ваш аккаунт отключен. Пожалуйста, обратитесь в поддержку."
            case .invalidEmail, .invalidSender, .invalidRecipientEmail:
                return "Введите корректный email."
            case .networkError:
                return "Ошибка подключения к сети. \nПопробуйте еще раз."
            case .weakPassword:
                return "Короткий пароль. \nПароль должен содержать не менее 6 символов."
            case .wrongPassword:
                return "Неверный email или пароль."
            default:
                return "Упс... Что-то пошло не так. \nПопробуйте позже."
        }
    }
}

extension User {
    var isEmailVerifiedMessage: String {
        switch self.isEmailVerified {
            case false:    return "Аккаунт не верефицирован, проверьте почтовый ящик."
            default:       return ""
        }
    }
}
