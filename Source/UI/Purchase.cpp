#include "Purchase.hpp"

#include "Base.hpp"
#include "UI/User.hpp"

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
        m_installments(1),
        m_endDate(QDate::currentDate())
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
        case Type::Bill:
            return "Bills";
        default:
            return "Others";
        }
    }

    bool Purchase::isOwnedBy(std::uint32_t inUserId)
    {
        return m_userId == inUserId;
    }

    bool Purchase::isRecurring()
    {
        return m_type == Type::Bill || m_type == Type::Subscription;
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
        setUserId(
            inData.find("userId") != inData.end() ?
                inData.at("userId").is_number_unsigned() ?
                    (std::uint32_t) inData.at("userId") : 0
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
                    (std::uint32_t) inData.at("installments") : 1
                : 1
        );

        if (m_type != Type::Subscription && m_type != Type::Bill) {
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
            { "userId",       m_userId },
            { "accountId",    m_accountId },
            { "name",         m_name.toStdString() },
            { "description",  m_description.toStdString() },
            { "date",         m_date.toString("dd/MM/yyyy").toStdString() },
            { "type",         m_type },
            { "value",        m_value },
            { "installments", m_installments }
        };

        return result;
    }

    bool Purchase::isOwnedBy(User* inUser)
    {
        if (inUser == nullptr)
        {
            return false;
        }

        return isOwnedBy(inUser->getId());
    }

    std::uint32_t Purchase::getId()
    {
        return m_id;
    }

    void Purchase::setId(std::uint32_t inId)
    {
        m_id = inId;
    }

    std::uint32_t Purchase::getUserId()
    {
        return m_userId;
    }

    void Purchase::setUserId(std::uint32_t inId)
    {
        m_userId = inId;
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
        m_name = inName.trimmed();

        emit onEdit();
    }

    QString Purchase::getDescription()
    {
        return m_description;
    }

    void Purchase::setDescription(const QString& inDescription)
    {
        m_description = inDescription.trimmed();

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

    bool Purchase::isFullyPaid(const QDate& inFinalDate, std::uint32_t inStatementClosingDay)
    {
        if (isRecurring())
        {
            return QDate::currentDate().daysTo(getEndDate()) < 0;
        }

        return getPaidInstallments(inFinalDate, inStatementClosingDay) > m_installments;
    }

    std::uint32_t Purchase::getPaidInstallments(const QDate& inFinalDate, std::uint32_t inStatementClosingDay)
    {
        std::uint32_t paidInstallments = 0;

        QDate currentStatementClosingDate(
            m_date.year(),
            m_date.month(),
            std::min(
                (std::uint32_t) m_date.daysInMonth(),
                inStatementClosingDay
            )
        );

        if (currentStatementClosingDate.daysTo(m_date) < 0) {
            currentStatementClosingDate = currentStatementClosingDate.addMonths(-1);
        }

        QDate endDate = isRecurring() ? getEndDate() : inFinalDate;
        endDate = QDate(
            endDate.year(),
            endDate.month(),
            std::min(
                (std::uint32_t) endDate.daysInMonth(),
                inStatementClosingDay
            )
        );

        QDate currentDate = currentStatementClosingDate;

        while (currentStatementClosingDate.daysTo(currentDate) >= 0 && endDate.daysTo(currentDate) <= 0)
        {
            if (currentDate.day() == std::min(inStatementClosingDay, (std::uint32_t) currentDate.daysInMonth())) {
                paidInstallments++;
            }

            currentDate = currentDate.addDays(1);
        }

        return paidInstallments;
    }

    std::uint32_t Purchase::getInstallments()
    {
        return m_installments;
    }

    void Purchase::setInstallments(std::uint32_t inInstallments)
    {
        m_installments = std::clamp(
            inInstallments,
            MIN_INSTALLMENT_COUNT,
            MAX_INSTALLMENT_COUNT
        );

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

    void Purchase::edit(
        const QString& inName,
        const QString& inDescription,
        const QDate& inDate,
        Type inType,
        float inValue,
        std::uint32_t inInstallments
    )
    {
        if (inName.trimmed() != m_name.trimmed())
        {
            m_name = inName.trimmed();
        }

        if (inDescription.trimmed() != m_description.trimmed())
        {
            m_description = inDescription.trimmed();
        }

        if (inDate != m_date)
        {
            m_date = inDate;
        }

        if (inType != m_type)
        {
            m_type = inType;
        }

        if (inValue != m_value)
        {
            m_value = inValue;
        }

        if (inInstallments != m_installments)
        {
            m_installments = inInstallments;
        }

        emit onEdit();
    }
}