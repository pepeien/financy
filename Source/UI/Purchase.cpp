#include "Purchase.hpp"

namespace Financy
{
    Purchase::Purchase()
        : m_name(""),
        m_description(""),
        m_date(QDate::currentDate()),
        m_value(0.0f),
        m_installments(1),
        m_bIsSubscription(false)
    {}

    float Purchase::getInstallmentValue()
    {
        return m_value / m_installments;
    }

    void Purchase::fromJSON(const nlohmann::json& inData)
    {
        setName(
            QString::fromStdString(
                inData.find("name") != inData.end() ?
                    (std::string) inData.at("name") :
                    ""
            )
        );

        setDescription(
            QString::fromStdString(
                inData.find("description") != inData.end() ?
                    (std::string) inData.at("description") :
                    ""
            )
        );

        setDate(
            inData.find("date") != inData.end() ?
                QDate::fromString(
                    QString::fromStdString(
                        (std::string) inData.at("date")
                    ),
                    "dd/MM/yyyy"
                ) :
                QDate::currentDate()
        );

        setValue(
            inData.find("value") != inData.end() ?
                inData.at("value").is_number() ?
                    (float) inData.at("value") : 0.0f
                :
                0.0f
        );

        setInstallments(
            inData.find("installments") != inData.end() ?
                inData.at("installments").is_number_unsigned() ?
                    (int) inData.at("installments") : 1
                : 1
        );

        setIsSubscription(
            inData.find("isSubscription") != inData.end() ?
                inData.at("isSubscription").is_boolean() ? (bool) inData.at("isSubscription") : false
            : false
        );
    }

    QString Purchase::getName()
    {
        return m_name;
    }

    void Purchase::setName(const QString& inName)
    {
        m_name = inName;

        onEdit();
    }

    QString Purchase::getDescription()
    {
        return m_description;
    }

    void Purchase::setDescription(const QString& inDescription)
    {
        m_description = inDescription;

        onEdit();
    }

    QDate Purchase::getDate()
    {
        return m_date;
    }

    void Purchase::setDate(const QDate& inDate)
    {
        m_date = inDate;

        onEdit();
    }

    float Purchase::getValue()
    {
        return m_value;
    }

    void Purchase::setValue(float inValue)
    {
        m_value = inValue;

        onEdit();
    }

    int Purchase::getInstallments()
    {
        return m_installments;
    }

    void Purchase::setInstallments(int inInstallments)
    {
        m_installments = inInstallments;

        onEdit();
    }

    bool Purchase::isSubscription()
    {
        return m_bIsSubscription;
    }

    void Purchase::setIsSubscription(bool inIsSubscription)
    {
        m_bIsSubscription = inIsSubscription;
    }
}