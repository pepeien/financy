#include "Account.hpp"

#include <iostream>
#include <fstream>

#include <QQmlEngine>

#include "Core/FileSystem.hpp"
#include "Core/Helper.hpp"

namespace Financy
{
    Account::Account()
        : QObject(),
        m_id(0),
        m_name(""),
        m_closingDay(1),
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

        refreshPurchases();
    }

    nlohmann::ordered_json Account::toJSON()
    {
        return nlohmann::ordered_json{
            { "id",             m_id },
            { "userId",         m_userId },
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
        float result = 0.0f;

        for (Purchase* purchase : m_purchases)
        {
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

    bool Account::hasFullyPaid(Purchase* inPurchase)
    {
        return (getPaidInstallments(inPurchase) - 1) > inPurchase->getInstallments();
    }

    int Account::getPaidInstallments(Purchase* inPurchase)
    {
        return getPaidInstallments(inPurchase, QDate::currentDate());
    }
    
    int Account::getPaidInstallments(Purchase* inPurchase, const QDate& inDate)
    {
        int result       = 0;
        int installments = inPurchase->getInstallments();

        QDate date = inPurchase->getDate();

        QDate closingDate(
            date.year(),
            date.month(),
            m_closingDay
        );

        if (inPurchase->getType() == Purchase::Type::Subscription || inPurchase->getType() == Purchase::Type::Bill)
        {
            QDate startDate = inPurchase->getDate();
            QDate endDate   = inPurchase->getEndDate();
            endDate.setDate(
                endDate.year(),
                endDate.month(),
                m_closingDay
            );

            if (inDate.daysTo(startDate) > 0 || inDate.daysTo(endDate) < 0)
            {
                return 0;
            }

            return 1;
        }

        while (date.daysTo(inDate) > 0)
        {
            if (date.daysTo(closingDate) <= 0) {
                closingDate = closingDate.addMonths(1);

                result++;
            }

            date = date.addDays(1);
        }

        return result;
    }

    int Account::getRemainingInstallments(Purchase* inPurchase)
    {
        return std::clamp(
            inPurchase->getInstallments() - getPaidInstallments(inPurchase),
            0,
            inPurchase->getInstallments()
        );
    }

    float Account::getRemainingValue(Purchase* inPurchase)
    {
        if (hasFullyPaid(inPurchase))
        {
            return 0;
        }

        return inPurchase->getValue() - (inPurchase->getInstallmentValue() * getPaidInstallments(inPurchase));
    }

    float Account::getDueAmount()
    {
        float result = 0.0f;

        for(Purchase* purchase : m_purchases)
        {
            if (hasFullyPaid(purchase))
            {
                continue;
            }

            result += purchase->getInstallmentValue();
        }

        return result;
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
        std::ifstream file(PURCHASE_FILE_NAME);
        nlohmann::ordered_json purchases = FileSystem::doesFileExist(PURCHASE_FILE_NAME) ? 
            nlohmann::ordered_json::parse(file):
            nlohmann::ordered_json::array();

        if (!purchases.is_array())
        {
            return;
        }

        Purchase* purchase = new Purchase();
        purchase->setId(          purchases.size());
        purchase->setAccountId(   m_id);
        purchase->setName(        inName);
        purchase->setDescription( inDescription);
        purchase->setDate(        QDate::fromString(inDate, "dd/MM/yyyy"));
        purchase->setType(        Purchase::getTypeValue(inType));
        purchase->setValue(       std::stof(inValue.toStdString()));
        purchase->setInstallments(std::stoi(inInstallments.toStdString()));

        QList<Purchase*> newPurchases = m_purchases;
        newPurchases.push_back(purchase);

        setPurchases(newPurchases);

        refreshHistory();

        emit onEdit();

        // Write
        purchases.push_back(purchase->toJSON());

        std::ofstream stream(PURCHASE_FILE_NAME);
        stream << std::setw(4) << purchases << std::endl;
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

    QString Account::getName()
    {
        return m_name;
    }

    void Account::setName(const QString& inName)
    {
        m_name = inName;

        emit onEdit();
    }

    std::uint32_t Account::getClosingDay()
    {
        return m_closingDay;
    }

    void Account::setClosingDay(std::uint32_t inClosingDay)
    {
        m_closingDay = std::clamp(
            inClosingDay,
            (std::uint32_t) 1,
            (std::uint32_t) 31
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

    QList<Purchase*> Account::getPurchases()
    {
        return m_purchases;
    }

    void Account::setPurchases(const QList<Purchase*>& inPurchases)
    {
        m_purchases = inPurchases;

        std::sort(
            m_purchases.begin(),
            m_purchases.end(),
            [](Purchase* a, Purchase* b) { return a->getDate().toJulianDay() < b->getDate().toJulianDay(); }
        );

        refreshHistory();

        emit onEdit();
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

        if (m_closingDay != std::stoi(inClosingDay.toStdString()))
        {
            m_closingDay = std::stoi(inClosingDay.toStdString());
        }

        if (m_limit != std::stoi(inLimit.toStdString()))
        {
            m_limit = std::stoi(inLimit.toStdString());
        }

        Type type = Type::Expense;

        if (inType.contains("Saving"))
        {
            type = Type::Saving;
        }

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

    void Account::refreshPurchases()
    {
        if (!FileSystem::doesFileExist(PURCHASE_FILE_NAME))
        {
            return;
        }

        nlohmann::json purchases = nlohmann::json::parse(std::ifstream(PURCHASE_FILE_NAME));

        if (!purchases.is_array())
        {
            return;
        }

        QList<Purchase*> newPurchases{};

        for (auto& [key, data] : purchases.items())
        {
            if (data.find("accountId") == data.end() || !data.at("accountId").is_number_unsigned())
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

        refreshHistory();
    }

    void Account::refreshHistory()
    {
        m_history.clear();

        if (m_purchases.isEmpty())
        {
            return;
        }

        QDate earliestDate = m_purchases[0]->getDate();
        QDate latestDate   = earliestDate;

        for (Purchase* purchase : m_purchases)
        {
            QDate date = purchase->getDate().addMonths(purchase->getInstallments());

            if (latestDate.daysTo(date) <= 0)
            {
                continue;
            }

            latestDate = date;
        }

        bool isOnlyRecurring = true;

        for (Purchase* purchase : m_purchases)
        {
            Purchase::Type type = purchase->getType();

            if (type != Purchase::Type::Subscription && type != Purchase::Type::Bill)
            {
                isOnlyRecurring = false;

                break;
            }
        }

        if (isOnlyRecurring)
        {
            latestDate = QDate::currentDate().addMonths(1);
        }

        QDate statementDate = QDate(
            earliestDate.year(),
            earliestDate.month(),
            m_closingDay
        );

        while(latestDate.daysTo(statementDate) <= 0)
        {
            Statement* statement = new Statement();
            statement->setDate(statementDate);

            QList<Purchase*> purchases{};
            QList<Purchase*> subscriptions{};
            float dueAmount = 0.0f;
    
            for (Purchase* purchase : m_purchases) {
                int paidInstallments = getPaidInstallments(
                    purchase,
                    statementDate
                );

                if (paidInstallments <= 0 || paidInstallments > purchase->getInstallments())
                {
                    continue;
                }

                dueAmount += purchase->getInstallmentValue();

                if (purchase->getType() == Purchase::Type::Subscription)
                {
                    subscriptions.push_back(purchase);

                    continue;
                }

                purchases.push_back(purchase);
            }

            statementDate = statementDate.addMonths(1);

            if (purchases.isEmpty() && subscriptions.isEmpty()) {
                delete statement;

                continue;
            }

            statement->setDueAmount(dueAmount);
            statement->setPurchases(purchases);
            statement->setSubscritions(subscriptions);
            statement->refreshDateBasedHistory();

            m_history.push_back(statement);
        }

        std::sort(
            m_history.begin(),
            m_history.end(),
            [](Statement* a, Statement* b) { return a->getDate().toJulianDay() < b->getDate().toJulianDay(); }
        );

        emit onEdit();
    }
}