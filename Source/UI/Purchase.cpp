#include "Purchase.hpp"

#include <QQmlEngine>

namespace Financy
{
    Purchase::Purchase()
        : QObject(),
        m_name(""),
        m_description(""),
        m_date(QDate::currentDate()),
        m_type(Type::Other),
        m_value(0.0f),
        m_installments(1)
    {
        qmlRegisterUncreatableType<Purchase>(
            "Financy.Types",
            1,
            0,
            "Purchase",
            "Internal use only"
        );
    }

    bool Purchase::hasDescription()
    {
        return !m_description.isEmpty();
    }

    float Purchase::getInstallmentValue()
    {
        return m_value / m_installments;
    }

    QString Purchase::getTypeName()
    {
        switch (m_type)
        {
        case Type::Utility:
            return "Utilities";
        case Type::Subscription:
            return "Subscriptions";
        case Type::Travel:
            return "Travels";
        case Type::Debt:
            return "Debts";
        case Type::Food:
            return "Food";
        default:
            return "Others";
        }
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

        setType(
            inData.find("type") != inData.end() ?
                inData.at("type").is_number_unsigned() ? (Type) inData.at("type") : Type::Other
            : Type::Other
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
    }

    QString Purchase::getName()
    {
        return m_name;
    }

    void Purchase::setName(const QString& inName)
    {
        m_name = inName;

        emit onEdit();
    }

    QString Purchase::getDescription()
    {
        return m_description;
    }

    void Purchase::setDescription(const QString& inDescription)
    {
        m_description = inDescription;

        emit onEdit();
    }

    QDate Purchase::getDate()
    {
        return m_date;
    }

    void Purchase::setDate(const QDate& inDate)
    {
        m_date = inDate;

        emit onEdit();
    }

    Purchase::Type Purchase::getType()
    {
        return m_type;
    }

    void Purchase::setType(Type inType)
    {
        m_type = inType;
    }

    float Purchase::getValue()
    {
        return m_value;
    }

    void Purchase::setValue(float inValue)
    {
        m_value = inValue;

        emit onEdit();
    }

    int Purchase::getInstallments()
    {
        return m_installments;
    }

    void Purchase::setInstallments(int inInstallments)
    {
        m_installments = inInstallments;

        emit onEdit();
    }
}