#include "Account.hpp"

namespace Financy
{
    Account::Account()
        : m_name(""),
        m_closingDay(1),
        m_limit(1.0f),
        m_bRecoversLimitOnInstallmentPayment(true),
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
        setLimit(
            inData.find("limit") != inData.end() ?
                inData.at("limit").is_number() ?
                    (float) inData.at("limit") : 1.0f
                :
                1.0f
        );
        setRecoversLimitOnInstallmentPayment(
            inData.find("recoversOnInstallmentPayment") != inData.end() ?
                inData.at("recoversOnInstallmentPayment").is_boolean() ? (bool) inData.at("recoversOnInstallmentPayment") : true
            : true
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
            if (purchase->isSubscription())
            {
                result += purchase->getValue();

                continue;
            }

            result += m_bRecoversLimitOnInstallmentPayment ? getRemainingValue(purchase) : purchase->getValue();
        }

        return result;
    }

    float Account::getRemainingLimit()
    {
        return m_limit - getUsedLimit();
    }

    int Account::getPaidInstallments(Purchase* inPurchase)
    {
        int result       = 1;
        int installments = inPurchase->getInstallments();

        QDate date(inPurchase->getDate());

        QDate closingDate(date.year(), date.month(), m_closingDay);
        closingDate = closingDate.addMonths(1);

        QDate currentDate(QDate::currentDate());

        while ((date.daysTo(currentDate) > 0) && (result <= installments))
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
        return inPurchase->getInstallments() - getPaidInstallments(inPurchase);
    }

    float Account::getRemainingValue(Purchase* inPurchase)
    {
        return inPurchase->getValue() - (inPurchase->getInstallmentValue() * getPaidInstallments(inPurchase));
    }

    float Account::getDueAmount()
    {
        float result = 0.0f;

        for(Purchase* purchase : m_purchases)
        {
            result += purchase->getInstallmentValue();
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

    bool Account::recoversLimitOnInstallmentPayment()
    {
        return m_bRecoversLimitOnInstallmentPayment;
    }

    void Account::setRecoversLimitOnInstallmentPayment(bool bInRecoversLimitOnInstallmentPayment)
    {
        m_bRecoversLimitOnInstallmentPayment = bInRecoversLimitOnInstallmentPayment;
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