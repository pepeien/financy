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

    Purchase::Type Purchase::getTypeValue(const QString& inName)
    {
        if (PURCHASE_TYPES.find(inName.toStdString()) == PURCHASE_TYPES.end())
        {
            return Type::Other;
        }
    
        return PURCHASE_TYPES.at(inName.toStdString());
    }

    QString Purchase::getTypeName(Type inType)
    {
        switch (inType)
        {
        case Type::Utility:
            return "Utilities";
        case Type::Subscription:
            return "Subscriptions";
        case Type::Transport:
            return "Transport";
        case Type::Debt:
            return "Debts";
        case Type::Food:
            return "Food";
        default:
            return "Others";
        }
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
        return getTypeName(m_type);
    }

    void Purchase::fromJSON(const nlohmann::json& inData)
    {
        setId(
            inData.find("id") != inData.end() ?
                inData.at("id").is_number_unsigned() ?
                    (std::uint32_t) inData.at("id") : 0
                :
                0
        );
        setAccountId(
            inData.find("accountId") != inData.end() ?
                inData.at("accountId").is_number_unsigned() ?
                    (std::uint32_t) inData.at("accountId") : 0
                :
                0
        );
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

        if (m_type != Type::Subscription) {
            return;
        }

        setEndDate(
            inData.find("endDate") != inData.end() ?
                QDate::fromString(
                    QString::fromStdString(
                        (std::string) inData.at("endDate")
                    ),
                    "dd/MM/yyyy"
                ) :
                QDate::currentDate()
        );
    }

    nlohmann::ordered_json Purchase::toJSON()
    {
        nlohmann::ordered_json result = {
            { "id",           m_id },
            { "accountId",    m_accountId },
            { "name",         m_name.toStdString() },
            { "description",  m_description.toStdString() },
            { "date",         m_date.toString("dd/MM/yyyy").toStdString() },
            { "type",         m_type },
            { "value",        m_value },
            { "installments", m_installments }
        };

        if (m_type == Type::Subscription)
        {
            result["endDate"] = m_endDate.toString("dd/MM/yyyy").toStdString();
        }

        return result;
    }

    std::uint32_t Purchase::getId()
    {
        return m_id;
    }

    void Purchase::setId(std::uint32_t inId)
    {
        m_id = inId;
    }

    std::uint32_t Purchase::getAccountId()
    {
        return m_accountId;
    }

    void Purchase::setAccountId(std::uint32_t inId)
    {
        m_accountId = inId;
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

    QDate Purchase::getEndDate()
    {
        return m_endDate;
    }

    void Purchase::setEndDate(const QDate& inDate)
    {
        m_endDate = inDate;
    }
}