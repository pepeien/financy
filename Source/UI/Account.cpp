#include "Account.hpp"

#include <iostream>
#include <fstream>

#include <QQmlEngine>

#include "Base.hpp"
#include "Core/Application.hpp"
#include "Core/FileSystem.hpp"
#include "Core/Globals.hpp"
#include "Core/Helper.hpp"
#include "UI/User.hpp"
#include "UI/Internal.hpp"

namespace Financy
{
    Account::Account()
        : QObject(),
        m_didFetchPurchases(false),
        m_id(0),
        m_userId(0),
        m_name(""),
        m_closingDay(MIN_STATEMENT_CLOSING_DAY),
        m_type(Type::Expense),
        m_limit(1.0f),
        m_primaryColor("#FFFFFF"),
        m_secondaryColor("#000000")
    {
        qmlRegisterUncreatableType<Account>(
            "Financy.Types",
            1,
            0,
            "Account",
            "Internal use only"
        );
    }

    Account::Type Account::getTypeValue(const QString& inName)
    {
        if (ACCOUNT_TYPES.find(inName.toStdString()) == ACCOUNT_TYPES.end())
        {
            return Type::Expense;
        }
    
        return ACCOUNT_TYPES.at(inName.toStdString());
    }

    QString Account::getTypeName(Type inType)
    {
        switch (inType)
        {
        case Type::Expense:
        default:
            return "Expense";
        }
    }

    void Account::fromJSON(const nlohmann::json& inData)
    {
        setId(
            inData.find("id") != inData.end() ?
                inData.at("id").is_number_unsigned() ?
                    (std::uint32_t) inData.at("id") : 0
                :
                0
        );
        setUserId(
            inData.find("userId") != inData.end() ?
                inData.at("userId").is_number_unsigned() ?
                    (std::uint32_t) inData.at("userId") : 0
                :
                0
        );

        if (inData.find("sharedUserIds") != inData.end() && inData.at("sharedUserIds").is_array())
        {
            QList<int> sharedUserIds {};

            for (auto& it : inData.at("sharedUserIds").items())
            {
                if (!it.value().is_number_unsigned())
                {
                    continue;
                }

                sharedUserIds.push_back((std::uint32_t) it.value());
            }

            setSharedUserIds(sharedUserIds);
        }

        setName(
            inData.find("name") != inData.end() ?
                QString::fromStdString((std::string) inData.at("name")) :
                ""
        );
        setClosingDay(
            inData.find("closingDay") != inData.end() ?
                inData.at("closingDay").is_number_unsigned() ?
                    (std::uint32_t) inData.at("closingDay") : 1
                :
                1
        );
        setType(
            inData.find("type") != inData.end() ?
                inData.at("type").is_number_unsigned() ? (Type) inData.at("type") : Type::Expense
            : Type::Expense
        );
        setLimit(
            inData.find("limit") != inData.end() ?
                inData.at("limit").is_number() ?
                    (float) inData.at("limit") : 1.0f
                :
                1.0f
        );
        setPrimaryColor(
            inData.find("primaryColor") != inData.end() ?
                QString::fromStdString((std::string) inData.at("primaryColor"))
                :
                "#FFFFFF"
        );
        setSecondaryColor(
            inData.find("secondaryColor") != inData.end() ?
                QString::fromStdString((std::string) inData.at("secondaryColor"))
                :
                "#000000"
        );
    }

    nlohmann::ordered_json Account::toJSON()
    {
        return nlohmann::ordered_json{
            { "id",             m_id },
            { "userId",         m_userId },
            { "sharedUserIds",  m_sharedUserIds },
            { "name",           m_name.toStdString() },
            { "closingDay",     m_closingDay },
            { "type",           m_type },
            { "limit",          m_limit },
            { "primaryColor",   m_primaryColor.name().toStdString() },
            { "secondaryColor", m_secondaryColor.name().toStdString() }
        };
    }

    float Account::getUsedLimit()
    {
        QDate now = Globals::getCurrentDate();

        float result = 0.0f;

        for (Purchase* purchase : m_purchases)
        {
            if (purchase->getDate().daysTo(now) < 0)
            {
                continue;
            }

            if (purchase->getType() == Purchase::Type::Subscription || purchase->getType() == Purchase::Type::Bill)
            {
                result += purchase->getValue();

                continue;
            }

            if (hasFullyPaid(purchase))
            {
                continue;
            }
    
            result += getRemainingValue(purchase);
        }

        return result;
    }

    float Account::getRemainingLimit()
    {
        return m_limit - getUsedLimit();
    }

    const QList<Statement*>& Account::getHistory()
    {
        return m_history;
    }

    bool Account::isOwnedBy(User* inUser)
    {
        if (inUser == nullptr)
        {
            return false;
        }

        return isOwnedBy(inUser->getId());
    }

    bool Account::isOwnedBy(std::uint32_t inUserId)
    {
        return m_userId == inUserId;
    }

    bool Account::isSharingWith(User* inUser)
    {
        if (inUser == nullptr)
        {
            return false;
        }

        return isSharingWith(inUser->getId());
    }

    bool Account::isSharingWith(std::uint32_t inUserId)
    {
        return std::find(
            m_sharedUserIds.begin(),
            m_sharedUserIds.end(),
            inUserId
        ) != m_sharedUserIds.end();
    }

    void Account::shareWith(std::uint32_t inUserId)
    {
        if (isOwnedBy(inUserId) || isSharingWith(inUserId))
        {
            return;
        }

        m_sharedUserIds.push_back(inUserId);
    }

    void Account::withholdFrom(std::uint32_t inUserId)
    {
        if (isOwnedBy(inUserId) || !isSharingWith(inUserId))
        {
            return;
        }

        QList<int> newShareUserIds {};
    
        for (std::uint32_t id : m_sharedUserIds) 
        {
            if (id == inUserId)
            {
                continue;
            }

            newShareUserIds.push_back(id);
        }

        std::vector<std::uint32_t> userPurchases {};

        for (Purchase* purchase : getPurchases())
        {
            userPurchases.push_back(purchase->getId());
        }

        for (std::uint32_t purchaseId : userPurchases)
        {
            deletePurchaseFromMemory(purchaseId);
            deletePurchaseFromFile(purchaseId);
        }

        setSharedUserIds(newShareUserIds);
    }

    bool Account::hasFullyPaid(Purchase* inPurchase)
    {
        QDate now = Globals::getCurrentDate();

        return inPurchase->isFullyPaid(
            now,
            getClosingDay(now)
        );
    }

    std::uint32_t Account::getPaidInstallments(Purchase* inPurchase)
    {
        QDate now = Globals::getCurrentDate();

        return inPurchase->getPaidInstallments(
            now,
            getClosingDay(now)
        );
    }
    
    std::uint32_t Account::getPaidInstallments(Purchase* inPurchase, const QDate& inStatementDate)
    {
        return inPurchase->getPaidInstallments(
            inStatementDate,
            getClosingDay(inStatementDate)
        );
    }

    std::uint32_t Account::getRemainingInstallments(Purchase* inPurchase)
    {
        return std::clamp(
            inPurchase->getInstallments() - getPaidInstallments(inPurchase),
            (std::uint32_t) 0,
            inPurchase->getInstallments()
        );
    }

    float Account::getRemainingValue(Purchase* inPurchase)
    {
        if (hasFullyPaid(inPurchase))
        {
            return 0;
        }

        return inPurchase->getValue() - (inPurchase->getInstallmentValue() * (getPaidInstallments(inPurchase) - 1));
    }

    void Account::createPurchase(
        const QString& inName,
        const QString& inDescription,
        const QString& inDate,
        const QString& inType,
        const QString& inValue,
        const QString& inInstallments
    )
    {
        User* user = Internal::getSelectedUser();

        if (user == nullptr)
        {
            return;
        }

        std::ifstream file(PURCHASE_FILE_NAME);
        nlohmann::ordered_json purchases = FileSystem::doesFileExist(PURCHASE_FILE_NAME) ? 
            nlohmann::ordered_json::parse(file):
            nlohmann::ordered_json::array();

        if (!purchases.is_array())
        {
            return;
        }

        std::uint32_t id = 0;

        if (purchases.size() > 0)
        {
            id = (std::uint32_t) purchases[purchases.size() - 1].at("id");
            id++;
        }

        Purchase* purchase = new Purchase();
        purchase->setId(          id);
        purchase->setUserId(      user->getId());
        purchase->setAccountId(   m_id);
        purchase->setName(        inName);
        purchase->setDescription( inDescription);
        purchase->setDate(        QDate::fromString(inDate, "dd/MM/yyyy"));
        purchase->setType(        Purchase::getTypeValue(inType));
        purchase->setValue(       inValue.toFloat());
        purchase->setInstallments(inInstallments.toInt());

        m_purchases.push_back(purchase);

        sortPurchases();

        refreshHistory();

        writePurchases();
    }

    void Account::editPurchase(
        std::uint32_t inId,
        const QString& inName,
        const QString& inDescription,
        const QString& inDate,
        const QString& inType,
        const QString& inValue,
        const QString& inInstallments
    )
    {
        auto purchaseIterator = std::find_if(
            m_purchases.begin(),
            m_purchases.end(),
            [inId](Purchase* _) { return _->getId() == inId; }
        );

        if (purchaseIterator == m_purchases.end())
        {
            return;
        }

        Purchase* foundPurchase = m_purchases[purchaseIterator - m_purchases.begin()];
        foundPurchase->edit(
            inName,
            inDescription,
            QDate::fromString(inDate, "dd/MM/yyyy"),
            Purchase::getTypeValue(inType),
            inValue.toFloat(),
            inInstallments.toInt()
        );

        sortPurchases();

        refreshHistory();

        writePurchases();
    }

    void Account::cancelPurchase(std::uint32_t inId)
    {
        Purchase* purchase = getPurchase(inId);

        if (purchase == nullptr)
        {
            return;
        }

        purchase->setEndDate(Globals::getCurrentDate());
        purchase->setHasEnded(true);

        refreshHistory();

        emit onEdit();

        writePurchases();
    }

    void Account::deletePurchase(std::uint32_t inId)
    {
        int userCount = m_purchases.size();

        deletePurchaseFromFile(  inId);
        deletePurchaseFromMemory(inId);

        if (userCount == m_purchases.size())
        {
            clearHistory();

            return;
        }

        refreshHistory();
    }

    QList<Statement*> Account::getStatementPurchases(const QDate& inDate, int inUserId)
    {
        QList<Statement*> result{};

        for (Purchase* purchase : getPurchases(inDate, inUserId))
        {
            if (purchase->isRecurring())
            {
                continue;
            }

            auto foundItem = std::find_if(
                result.begin(),
                result.end(),
                [purchase](Statement* _) { return _->getDate().daysTo(purchase->getDate()) == 0; }
            );

            int foundIndex = foundItem - result.begin();

            if (foundItem == result.end())
            {
                foundIndex = result.size();

                result.push_back(new Statement());

                result[foundIndex]->setDate(     purchase->getDate());
                result[foundIndex]->setPurchases({});
            }

            QList<Purchase*> purchases = result[foundIndex]->getPurchases();
            purchases.push_back(purchase);

            result[foundIndex]->setPurchases(purchases);
            result[foundIndex]->setDueAmount(result[foundIndex]->getDueAmount() + purchase->getInstallmentValue());
        }

        return result;
    }

    QList<Purchase*> Account::getStatementSubscriptions(const QDate& inDate, int inUserId)
    {
        QList<Purchase*> result{};

        for (Purchase* purchase : getPurchases(inDate, inUserId))
        {
            if (!purchase->isRecurring())
            {
                continue;
            }

            result.push_back(purchase);
        }

        return result;
    }

    void Account::refreshPurchases()
    {
        if (m_didFetchPurchases)
        {
            return;
        }

        if (!FileSystem::doesFileExist(PURCHASE_FILE_NAME))
        {
            return;
        }

        nlohmann::json purchases = nlohmann::json::parse(std::ifstream(PURCHASE_FILE_NAME));

        if (!purchases.is_array())
        {
            return;
        }

        QList<Purchase*> newPurchases {};

        for (auto& [key, data] : purchases.items())
        {
            if (
                data.find("accountId") == data.end() ||
                data.find("userId") == data.end()
            )
            {
                continue;
            }

            if ((std::uint32_t) data.at("accountId") != m_id)
            {
                continue;
            }

            Purchase* purchase = new Purchase();
            purchase->fromJSON(data);

            newPurchases.push_back(purchase);
        }

        setPurchases(newPurchases);

        m_didFetchPurchases = true;
    }

    void Account::clearPurchases()
    {
        m_purchases.clear();

        emit onEdit();
    }

    void Account::refreshHistory(int inUserId)
    {
        m_history.clear();

        QList<Purchase*> purchases = getPurchases();

        if (purchases.isEmpty())
        {
            return;
        }

        QDate earliestStatement    = getEarliestStatementDate(inUserId);
        QDate latestStatement      = getLatestStatementDate(inUserId);
        QDate currentStatementDate = earliestStatement;

        while(latestStatement.daysTo(currentStatementDate) <= 0)
        {
            Statement* statement = new Statement();
            statement->setDate(currentStatementDate);

            float purchaseDueAmount  = 0.0f;
            float recurringDueAmount = 0.0f;

            for (Purchase* purchase : getPurchases(currentStatementDate, inUserId))
            {
                if (purchase->isRecurring())
                {
                    recurringDueAmount += purchase->getInstallmentValue();

                    continue;
                }
 
                purchaseDueAmount += purchase->getInstallmentValue();
            }

            currentStatementDate = QDate(
                currentStatementDate.year(),
                currentStatementDate.month(),
                getClosingDay(currentStatementDate)
            );
            currentStatementDate = currentStatementDate.addMonths(1);

            bool isFirstEmpty = purchaseDueAmount == 0 && recurringDueAmount == 0 && m_history.size() == 0;
            bool isLastEmpty  = purchaseDueAmount == 0 && latestStatement.daysTo(currentStatementDate) > 0;

            if (isFirstEmpty || isLastEmpty)
            {
                delete statement;

                continue;
            }

            statement->setDueAmount(purchaseDueAmount + recurringDueAmount);

            m_history.push_back(statement);
        }

        sortHistory();

        emit onEdit();
    }

    void Account::clearHistory()
    {
        m_history.clear();

        emit onEdit();
    }

    float Account::getDueAmount()
    {
        return getDueAmount(-1);
    }

    float Account::getDueAmount(int inUserId)
    {
        return getDueAmount(Globals::getCurrentDate(), inUserId);
    }

    float Account::getDueAmount(const QDate& inDate, int inUserId)
    {
        float result = 0.0f;

        for(Purchase* purchase : getPurchases(inDate, inUserId))
        {
            result += purchase->getInstallmentValue();
        }

        return result;
    }

    std::uint32_t Account::getId()
    {
        return m_id;
    }

    void Account::setId(std::uint32_t inId)
    {
        m_id = inId;
    }

    std::uint32_t Account::getUserId()
    {
        return m_userId;
    }

    void Account::setUserId(std::uint32_t inId)
    {
        m_userId = inId;
    }

    QList<int> Account::getSharedUserIds()
    {
        return m_sharedUserIds;
    }

    void Account::setSharedUserIds(const QList<int>& inUserIds)
    {
        m_sharedUserIds = inUserIds;
    }

    QString Account::getName()
    {
        return m_name;
    }

    void Account::setName(const QString& inName)
    {
        m_name = inName;

        emit onEdit();
    }

    std::uint32_t Account::getClosingDay(const QDate& inStatementDate)
    {
        return std::min(
            (std::uint32_t) inStatementDate.daysInMonth(),
            m_closingDay
        );
    }

    std::uint32_t Account::getClosingDay()
    {
        return m_closingDay;
    }

    void Account::setClosingDay(std::uint32_t inClosingDay)
    {
        m_closingDay = std::clamp(
            inClosingDay,
            MIN_STATEMENT_CLOSING_DAY,
            MAX_STATEMENT_CLOSING_DAY
        );
    }

    Account::Type Account::getType()
    {
        return m_type;
    }

    void Account::setType(Type inType)
    {
        m_type = inType;
    }

    float Account::getLimit()
    {
        return m_limit;
    }

    void Account::setLimit(float inLimit)
    {
        m_limit = inLimit;

        emit onEdit();
    }

    QList<Purchase*> Account::getPurchases(const QDate& inDate, int inUserId)
    {
        QList<Purchase*> result {};

        for (Purchase* purchase : getPurchases(inUserId))
        {
            if (purchase == nullptr)
            {
                continue;
            }

            std::uint32_t paidInstallments = purchase->getPaidInstallments(
                inDate,
                getClosingDay(inDate)
            );

            bool isPast   = paidInstallments <= 0;
            bool isFuture = (purchase->isRecurring() && !purchase->hasEnded()) ? false : paidInstallments > purchase->getInstallments();

            if (isPast || isFuture)
            {
                continue;
            }

            result.push_back(purchase);
        }

        std::sort(
            result.begin(),
            result.end(),
            [](Purchase* a, Purchase* b) { return a->getDate().toJulianDay() > b->getDate().toJulianDay(); }
        );

        return result;
    }

    QList<Purchase*> Account::getPurchases(int inUserId)
    {
        User* user = Internal::getSelectedUser();

        if (inUserId < 0 && isOwnedBy(user))
        {
            return m_purchases;
        }

        QList<Purchase*> result {};

        if (user == nullptr)
        {
            return result;
        }

        for (Purchase* purchase : m_purchases)
        {
            if (!purchase->isOwnedBy(inUserId >= 0 ? inUserId : user->getId()))
            {
                continue;
            }

            result.push_back(purchase);
        }

        return result;
    }

    Purchase* Account::getPurchase(std::uint32_t inId)
    {
        QList<Purchase*> purchases = getPurchases();

        for (int i = 0, j = purchases.size() - 1; i <= j; i++, j--)
        {
            if (purchases[i]->getId() == inId)
            {
                return purchases[i];
            }

            if (i == j)
            {
                continue;
            }

            if (purchases[j]->getId() == inId)
            {
                return purchases[j];
            }
        }

        return nullptr;
    }

    void Account::setPurchases(const QList<Purchase*>& inPurchases)
    {
        m_purchases = inPurchases;

        sortPurchases();

        emit onEdit();
    }

    void Account::addPurchases(const QList<Purchase*>& inPurchases)
    {
        for (Purchase* purchase : inPurchases)
        {
            purchase->setAccountId(m_id);

            m_purchases.push_back(purchase);
        }

        sortPurchases();

        refreshHistory();

        writePurchases();
    }

    QColor Account::getPrimaryColor()
    {
        return m_primaryColor;
    }

    void Account::setPrimaryColor(const QColor& inColor)
    {
        m_primaryColor = inColor;

        emit onEdit();
    }

    QColor Account::getSecondaryColor()
    {
        return m_secondaryColor;
    }

    void Account::setSecondaryColor(const QColor& inColor)
    {
        m_secondaryColor = inColor;

        emit onEdit();
    }

    void Account::edit(
        const QString& inName,
        const QString& inClosingDay,
        const QString& inLimit,
        const QString& inType,
        const QColor& inPrimaryColor,
        const QColor& inSecondaryColor
    )
    {
        if (m_name.compare(inName) != 0)
        {
            m_name = inName;
        }

        if (m_closingDay != inClosingDay.toInt())
        {
            m_closingDay = inClosingDay.toInt();
        }

        if (m_limit != inLimit.toInt())
        {
            m_limit = inLimit.toInt();
        }

        Type type = Type::Expense;

        if (m_type != type)
        {
            m_type = type;
        }

        if (m_primaryColor.name().compare(inPrimaryColor.name()) != 0)
        {
            m_primaryColor = inPrimaryColor;
        }

        if (m_secondaryColor.name().compare(inSecondaryColor.name()) != 0)
        {
            m_secondaryColor = inSecondaryColor;
        }

        emit onEdit();
    }

    void Account::remove()
    {
        removeSelf();
        removePurchases();
    }

    void Account::removeSelf()
    {
        if (!FileSystem::doesFileExist(ACCOUNT_FILE_NAME))
        {
            return;
        }

        std::ifstream file(ACCOUNT_FILE_NAME);

        nlohmann::json storedAccounts = nlohmann::json::parse(file);

        if (storedAccounts.size() < 0 || !storedAccounts.is_array())
        {
            return;
        }

        std::uint32_t index  = 0;
        std::size_t lastSize = storedAccounts.size();

        for (auto& it : storedAccounts.items())
        {
            if ((std::uint32_t) it.value().at("id") == m_id)
            {
                storedAccounts.erase(index);

                break;
            }

            index++;
        }

        if (lastSize == storedAccounts.size())
        {
            return;
        }

        std::ofstream stream(ACCOUNT_FILE_NAME);
        stream << std::setw(4) << storedAccounts << std::endl;
    }

    void Account::removePurchases()
    {
        for (Purchase* purchase : getPurchases())
        {
            std::uint32_t id = purchase->getId();

            deletePurchaseFromMemory(id);
            deletePurchaseFromFile(  id);
        }

        m_purchases.clear();
    }

    QDate Account::getEarliestStatementDate(int inUserId)
    {
        QList<Purchase*> purchase = getPurchases(inUserId);

        if (purchase.isEmpty())
        {
            return Globals::getCurrentDate();
        }

        QDate earliestPurchaseDate = purchase[0]->getDate();
        QDate earliestStatementClosingDate(
            earliestPurchaseDate.year(),
            earliestPurchaseDate.month(),
            std::min(
                (std::uint32_t) earliestPurchaseDate.daysInMonth(),
                m_closingDay
            )
        );

        if (earliestStatementClosingDate.daysTo(earliestPurchaseDate) < 0)
        {
            earliestStatementClosingDate = earliestStatementClosingDate.addMonths(-1);
        }

        return earliestStatementClosingDate;
    }

    QDate Account::getLatestStatementDate(int inUserId)
    {
        QDate now = Globals::getCurrentDate();

        bool isOnlyRecurring = true;

        QList<Purchase*> purchases = getPurchases(inUserId);

        for (Purchase* purchase : purchases)
        {
            if (!purchase->isRecurring())
            {
                isOnlyRecurring = false;

                break;
            }

            if (purchase->getEndDate().daysTo(now) < 0)
            {
                isOnlyRecurring = false;

                break;
            }
        }

        if (isOnlyRecurring)
        {
            return QDate(
                now.year(),
                now.month(),
                getClosingDay(now)
            );
        }

        QDate currentStatementDate = getEarliestStatementDate();

        for (Purchase* purchase : purchases)
        {
            std::uint32_t installments = purchase->getInstallments();

            QDate date = purchase->getDate().addMonths(installments == 1 ? 0 : installments);

            if (currentStatementDate.daysTo(date) < 0)
            {
                continue;
            }

            currentStatementDate = date;
        }

        return currentStatementDate;
    }

    void Account::sortPurchases()
    {
        std::sort(
            m_purchases.begin(),
            m_purchases.end(),
            [](Purchase* a, Purchase* b) { return a->getDate().toJulianDay() < b->getDate().toJulianDay(); }
        );
    }

    void Account::writePurchases()
    {
        if (!FileSystem::doesFileExist(PURCHASE_FILE_NAME))
        {
            return;
        }

        std::ifstream file(PURCHASE_FILE_NAME);

        nlohmann::ordered_json purchases = nlohmann::ordered_json::parse(file);

        if (!purchases.is_array())
        {
            return;
        }

        nlohmann::ordered_json newPurchases = nlohmann::ordered_json::array();

        if (purchases.size() == 0)
        {
            for (Purchase* purchase : m_purchases)
            {
                newPurchases.push_back(purchase->toJSON());
            }
        }
        else
        {
            std::vector<std::uint32_t> insertedIds {};

            for (auto& it : purchases.items())
            {
                std::uint32_t id = (std::uint32_t) it.value().at("id");

                auto foundPurchase = std::find_if(
                    m_purchases.begin(),
                    m_purchases.end(),
                    [id](Purchase* _) { return _->getId() == id; }
                );

                if (foundPurchase == m_purchases.end())
                {
                    newPurchases.push_back(it.value());

                    continue;
                }

                insertedIds.push_back(id);

                newPurchases.push_back(m_purchases[foundPurchase - m_purchases.begin()]->toJSON());
            }

            if (insertedIds.size() != m_purchases.size())
            {
                for (Purchase* purchase : m_purchases)
                {
                    if (
                        std::find_if(
                            insertedIds.begin(),
                            insertedIds.end(),
                            [purchase](std::uint32_t _) { return _ == purchase->getId(); }
                        ) != insertedIds.end()
                    )
                    {
                        continue;
                    }

                    newPurchases.push_back(purchase->toJSON());
                }
            }
        }

        std::ofstream stream(PURCHASE_FILE_NAME);
        stream << std::setw(4) << newPurchases << std::endl;
    }

    void Account::sortHistory()
    {
        std::sort(
            m_history.begin(),
            m_history.end(),
            [](Statement* a, Statement* b) { return a->getDate().toJulianDay() < b->getDate().toJulianDay(); }
        );
    }

    void Account::deletePurchaseFromFile(std::uint32_t inId)
    {
        // Remove from file
        if (!FileSystem::doesFileExist(PURCHASE_FILE_NAME))
        {
            return;
        }

        std::ifstream file(PURCHASE_FILE_NAME);

        nlohmann::json storedPurchases = nlohmann::json::parse(file);

        if (storedPurchases.size() < 0 || !storedPurchases.is_array())
        {
            return;
        }

        std::uint32_t index  = 0;
        std::size_t lastSize = storedPurchases.size();

        for (auto& it : storedPurchases.items())
        {
            if ((std::uint32_t) it.value().at("id") != inId)
            {
                index++;

                continue;
            }

            storedPurchases.erase(index);

            break;
        }

        if (lastSize == storedPurchases.size())
        {
            return;
        }

        std::ofstream stream(PURCHASE_FILE_NAME);
        stream << std::setw(4) << storedPurchases << std::endl;
    }

    void Account::deletePurchaseFromMemory(std::uint32_t inId)
    {
        auto iterator = std::find_if(
            m_purchases.begin(),
            m_purchases.end(),
            [=](Purchase* _) { return _->getId() == inId; }
        );

        if (iterator == m_purchases.end())
        {
            return;
        }

        m_purchases.removeAt(iterator - m_purchases.begin());
    }
}