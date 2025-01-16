import Foundation

// Перечисление типов транзакций
enum TransactionType {
    case withdraw  // Снятие наличных
    case deposit   // Пополнение счёта
    case recharge  // Пополнение телефона
}

// Структура для хранения информации о транзакции
struct Transaction {
    let type: TransactionType  // Тип транзакции (снятие, пополнение, пополнение телефона)
    let amount: Double         // Сумма транзакции
    let date: Date             // Дата транзакции

    // Возвращает описание транзакции в зависимости от её типа
    var description: String {
        switch type {
        case .withdraw: return "Снятие"           // Если транзакция типа "withdraw", возвращаем "Снятие"
        case .deposit: return "Пополнение"        // Если транзакция типа "deposit", возвращаем "Пополнение"
        case .recharge: return "Пополнение телефона" // Если транзакция типа "recharge", возвращаем "Пополнение телефона"
        }
    }
}

// Класс для работы с банковским счётом
class BankAccount {
    private(set) var balance: Double = 0.0  // Баланс счёта (публичный только для чтения)
    private var transactions: [Transaction] = []  // Массив для хранения списка транзакций

    // Метод для снятия наличных
    func withdrawCash(_ amount: Double) -> Bool {
        // Проверка, что сумма больше 0 и на счёте достаточно средств
        guard amount > 0, balance >= amount else { return false }
        
        balance -= amount  // Уменьшаем баланс на указанную сумму
        transactions.append(Transaction(type: .withdraw, amount: amount, date: Date())) // Добавляем транзакцию в список
        return true  // Возвращаем true, если операция успешна
    }

    // Метод для пополнения счёта наличными
    func depositCash(_ amount: Double) {
        // Проверка, что сумма больше 0
        guard amount > 0 else { return }
        
        balance += amount  // Увеличиваем баланс на указанную сумму
        transactions.append(Transaction(type: .deposit, amount: amount, date: Date()))  // Добавляем транзакцию в список
    }

    // Метод для пополнения телефона
    func rechargePhone(_ amount: Double) -> Bool {
        // Проверка, что сумма больше 0 и на счёте достаточно средств
        guard amount > 0, balance >= amount else { return false }
        
        balance -= amount  // Уменьшаем баланс на сумму пополнения
        transactions.append(Transaction(type: .recharge, amount: amount, date: Date()))  // Добавляем транзакцию в список
        return true  // Возвращаем true, если операция успешна
    }

    // Метод для получения отсортированного списка транзакций по дате
    func getSortedTransactions() -> [Transaction] {
        return transactions.sorted { $0.date > $1.date }  // Сортировка транзакций от самой новой к самой старой
    }
}
