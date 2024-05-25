#include "Account.hpp"

#include <QQmlEngine>

namespace Financy
{
    QList<Statement> Statement::getDateBasedHistory()
    {
        QList<Statement> result;

        for (Purchase* purchase : m_purchases) {
            auto foundItem = std::find_if(
                result.begin(),
                result.end(),
                [purchase](Statement& _) { return _.m_date.daysTo(purchase->getDate()) == 0; }
            );

            int foundIndex = foundItem - result.begin();

            if (foundItem == result.end()) {
                foundIndex = result.size();

                result.push_back({});

                result[foundIndex].m_date      = purchase->getDate();
                result[foundIndex].m_purchases = {};
            }

            result[foundIndex].m_purchases.push_back(purchase);
            result[foundIndex].m_dueAmount += purchase->getInstallmentValue();
        }

        return result;
    }

    Account::Account()
        : QObject(),
        m_name(""),
        m_closingDay(1),
        m_type(Type::Expense),
        m_limit(1.0f),
        m_primaryColor("#FFFFFF"),
        m_secondaryColor("#000000")
    {}

    void Account::fromJSON(const nlohmann::json& inData)
    {
        // Data
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

        if (inData.find("purchases") != inData.end())
        {
            auto& purchases = inData.at("purchases");

            if (purchases.is_array())
            {
                for (auto& it : purchases.items())
                {
                    Purchase* purchase = new Purchase();
                    purchase->fromJSON(it.value());

                    m_purchases.push_back(purchase);
                }
            }
        }

        // Colors
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

    float Account::getUsedLimit()
    {
        float result = 0.0f;

        for (Purchase* purchase : m_purchases)
        {
            if (purchase->getType() == Purchase::Type::Subscription)
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
        return getPaidInstallments(inPurchase) > inPurchase->getInstallments();
    }

    int Account::getPaidInstallments(Purchase* inPurchase)
    {
        return getPaidInstallments(inPurchase, QDate::currentDate());
    }
    
    int Account::getPaidInstallments(Purchase* inPurchase, const QDate& inDate)
    {
        int result       = 1;
        int installments = inPurchase->getInstallments();

        QDate date = inPurchase->getDate();

        QDate closingDate(date.year(), date.month(), m_closingDay);
        closingDate = closingDate.addMonths(1);

        while (date.daysTo(inDate) > 0)
        {
            if (date.daysTo(closingDate) <= 0) {
                closingDate = closingDate.addMonths(1);

                result++;
            }

            date = date.addDays(1);
        }

        return result - 1;
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

    QList<Statement> Account::getHistory()
    {
        QList<Statement> result;

        QDate earliestDate = QDate::currentDate();
        QDate latestDate   = earliestDate;

        for (Purchase* purchase : m_purchases) {
            QDate date = purchase->getDate();

            if (earliestDate.daysTo(date) < 0)
            {
                earliestDate = date;

                continue;
            }

            date = date.addMonths(purchase->getInstallments());

            if (latestDate.daysTo(date) > 0)
            {
                latestDate = date;

                continue;
            }
        }

        QDate statementDate = earliestDate;
        statementDate.setDate(
            statementDate.year(),
            statementDate.month(),
            m_closingDay
        );

        while(statementDate.daysTo(latestDate) > 0)
        {
            Statement statement{};
            statement.m_date      = statementDate;
            statement.m_dueAmount = 0;

            for (Purchase* purchase : m_purchases) {
                int daysToStatement = purchase->getDate()
                    .addMonths(purchase->getInstallments())
                    .daysTo(statementDate);

                if (daysToStatement > 0)
                {
                    continue;
                }

                statement.m_purchases.push_back(purchase);
                statement.m_dueAmount += purchase->getInstallmentValue();
            }

            statementDate = statementDate.addMonths(1);

            result.push_back(statement);
        }

        return result;
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
}